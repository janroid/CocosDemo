/****************************************************************************
 Copyright (c) 2014-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "platform/CCPlatformConfig.h"

// Webview not available on tvOS
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) && !defined(CC_TARGET_OS_TVOS)

#include "ui/UIWebViewImpl-ios.h"
#include "renderer/CCRenderer.h"
#include "base/CCDirector.h"
#include "platform/CCGLView.h"
#include "platform/ios/CCEAGLView-ios.h"
#include "platform/CCFileUtils.h"
#include "ui/UIWebView.h"
#import <WebKit/WebKit.h>

static std::string getFixedBaseUrl(const std::string& baseUrl)
{
    std::string fixedBaseUrl;
    if (baseUrl.empty() || baseUrl.at(0) != '/') {
        fixedBaseUrl = [[[NSBundle mainBundle] resourcePath] UTF8String];
        fixedBaseUrl += "/";
        fixedBaseUrl += baseUrl;
    }
    else {
        fixedBaseUrl = baseUrl;
    }
    
    size_t pos = 0;
    while ((pos = fixedBaseUrl.find(" ")) != std::string::npos) {
        fixedBaseUrl.replace(pos, 1, "%20");
    }
    
    if (fixedBaseUrl.at(fixedBaseUrl.length() - 1) != '/') {
        fixedBaseUrl += "/";
    }
    
    return fixedBaseUrl;
}
// 是否iOS9之后，本想iOS8就开始使用，但是 WKWebKit在iOS8上很多bug和坑
static inline BOOL isiOS9Later(){
    static BOOL iOS9Later = [UIDevice currentDevice].systemVersion.floatValue >= 9.0;
    return iOS9Later;
//    return NO;
}

@interface UIWebViewWrapper : NSObject
@property (nonatomic) std::function<bool(std::string url)> shouldStartLoading;
@property (nonatomic) std::function<void(std::string url)> didFinishLoading;
@property (nonatomic) std::function<void(std::string url)> didFailLoading;
@property (nonatomic) std::function<void(std::string url)> onJsCallback;

@property(nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property(nonatomic, readonly, getter=canGoForward) BOOL canGoForward;

+ (instancetype)newWebViewWrapper;

- (void)setVisible:(bool)visible;

- (void)setBounces:(bool)bounces;

- (void)setOpacityWebView:(float)opacity;

- (float)getOpacityWebView;

- (void)setBackgroundTransparent;

- (void)setFrameWithX:(float)x y:(float)y width:(float)width height:(float)height;

- (void)setJavascriptInterfaceScheme:(const std::string &)scheme;

- (void)loadData:(const std::string &)data MIMEType:(const std::string &)MIMEType textEncodingName:(const std::string &)encodingName baseURL:(const std::string &)baseURL;

- (void)loadHTMLString:(const std::string &)string baseURL:(const std::string &)baseURL;

- (void)loadUrl:(const std::string &)urlString cleanCachedData:(BOOL) needCleanCachedData;

- (void)loadFile:(const std::string &)filePath;

- (void)stopLoading;

- (void)reload;

- (void)evaluateJS:(const std::string &)js;

- (void)goBack;

- (void)goForward;

- (void)setScalesPageToFit:(const bool)scalesPageToFit;
@end


@interface UIWebViewWrapper () <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property(nonatomic, retain) UIWebView *uiWebView;
@property(nonatomic, retain) WKWebView *wkWebView;
@property(nonatomic, copy) NSString *jsScheme;
- (UIView *)view;
@end

@implementation UIWebViewWrapper {
    
}

+ (instancetype) newWebViewWrapper {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uiWebView = nil;
        self.wkWebView = nil;
        self.shouldStartLoading = nullptr;
        self.didFinishLoading = nullptr;
        self.didFailLoading = nullptr;
    }
    return self;
}

- (void)dealloc
{
    if (isiOS9Later()) {
        _wkWebView.navigationDelegate = nil;
        _wkWebView.UIDelegate = nil;
        [_wkWebView removeFromSuperview];
        _wkWebView = nil;
    }else {
        _uiWebView.delegate = nil;
        [_uiWebView removeFromSuperview];
        _uiWebView = nil;
    }
    self.jsScheme = nil;
}
#pragma mark - 懒加载
- (UIView *)view
{
    if (isiOS9Later()){
        return self.wkWebView;
    }else {
        return self.uiWebView;
    };
}
- (UIWebView *)uiWebView
{
    if (!_uiWebView) {
        _uiWebView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _uiWebView.delegate = self;
        if (@available(iOS 11.0, *)){ // iOS11 解决SafeArea的问题
            _uiWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self setupWebView];
    }
    return _uiWebView;
}
- (WKWebView *)wkWebView
{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        if (@available(iOS 11.0, *)){ // iOS11 解决SafeArea的问题
            _wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self setupWebView];
    }
    return _wkWebView;
}
- (void)setupWebView {
    if (!self.view.superview) {
        auto view = cocos2d::Director::getInstance()->getOpenGLView();
        auto eaglview = (__bridge CCEAGLView *) view->getEAGLView();
        [eaglview addSubview:self.view];
    }
}
#pragma mark - Public method
- (void)setVisible:(bool)visible {
    self.view.hidden = !visible;
}

- (void)setBounces:(bool)bounces {
    if (isiOS9Later()) {
        self.wkWebView.scrollView.bounces = bounces;
    }else {
        self.uiWebView.scrollView.bounces = bounces;
    }
}

- (void)setOpacityWebView:(float)opacity {
    self.view.alpha = opacity;
    self.view.opaque = NO;
}

-(float) getOpacityWebView{
    return self.view.alpha;
}

-(void) setBackgroundTransparent{
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)setFrameWithX:(float)x y:(float)y width:(float)width height:(float)height {
    CGRect newFrame = CGRectMake(x, y, width, height);
    if (!CGRectEqualToRect(self.view.frame, newFrame)) {
        self.view.frame = newFrame;
    }
}

- (void)setJavascriptInterfaceScheme:(const std::string &)scheme {
    self.jsScheme = @(scheme.c_str());
}

- (void)loadData:(const std::string &)data MIMEType:(const std::string &)MIMEType textEncodingName:(const std::string &)encodingName baseURL:(const std::string &)baseURL
{
    if(isiOS9Later()){
        [self.wkWebView loadData:[NSData dataWithBytes:data.c_str() length:data.length()]
                        MIMEType:@(MIMEType.c_str())
           characterEncodingName:@(encodingName.c_str())
                         baseURL:[NSURL URLWithString:@(getFixedBaseUrl(baseURL).c_str())]];
    }else {
        [self.uiWebView loadData:[NSData dataWithBytes:data.c_str() length:data.length()]
                        MIMEType:@(MIMEType.c_str())
                textEncodingName:@(encodingName.c_str())
                         baseURL:[NSURL URLWithString:@(getFixedBaseUrl(baseURL).c_str())]];
    }
}

- (void)loadHTMLString:(const std::string &)string baseURL:(const std::string &)baseURL {
    if (isiOS9Later()) {
        [self.wkWebView loadHTMLString:@(string.c_str()) baseURL:[NSURL URLWithString:@(getFixedBaseUrl(baseURL).c_str())]];
    }else {
        [self.uiWebView loadHTMLString:@(string.c_str()) baseURL:[NSURL URLWithString:@(getFixedBaseUrl(baseURL).c_str())]];
    }
}

- (void)loadUrl:(const std::string &)urlString cleanCachedData:(BOOL) needCleanCachedData {
    NSURL *url = [NSURL URLWithString:@(urlString.c_str())];
    //到时可能需要stringByAddingPercentEscapesUsingEncoding:或者stringByAddingPercentEncodingWithAllowedCharacters:，其他字符转成%编码格式
    NSURLRequest *request = nil;
    if (needCleanCachedData){
        request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    }else {
        request = [NSURLRequest requestWithURL:url];
    }
    if (isiOS9Later()) {
        [self.wkWebView loadRequest:request];
    }else {
        [self.uiWebView loadRequest:request];
    }
}

- (void)loadFile:(const std::string &)filePath {
    NSURL *url = [NSURL fileURLWithPath:@(filePath.c_str())];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    if(isiOS9Later()){
        [self.wkWebView loadRequest:request];
    }else {
        [self.uiWebView loadRequest:request];
    }
}

- (void)stopLoading
{
    if(isiOS9Later()){
        [self.wkWebView stopLoading];
    }else {
        [self.uiWebView stopLoading];
    }
}

- (void)reload
{
    if(isiOS9Later()){
        [self.wkWebView reload];
    }else {
        [self.uiWebView reload];
    }
}

- (BOOL)canGoForward
{
    if(isiOS9Later()){
        return self.wkWebView.canGoForward;
    }else {
        return self.uiWebView.canGoForward;
    }
}

- (BOOL)canGoBack
{
    if(isiOS9Later()){
        return self.wkWebView.canGoBack;
    }else {
        return self.uiWebView.canGoBack;
    }
}

- (void)goBack
{
    if(isiOS9Later()){
        [self.wkWebView goBack];
    }else {
        [self.uiWebView goBack];
    }
}

- (void)goForward
{
    if(isiOS9Later()){
        [self.wkWebView goForward];
    }else {
        [self.uiWebView goForward];
    }
}

- (void)evaluateJS:(const std::string &)js
{
    if(isiOS9Later()){
        [self.wkWebView evaluateJavaScript:@(js.c_str()) completionHandler:nil];
    }else {
        [self.uiWebView stringByEvaluatingJavaScriptFromString:@(js.c_str())];
    }
}

- (void)setScalesPageToFit:(const bool)scalesPageToFit
{
    if(isiOS9Later()){
        NSLog(@"WKWebView 不支持 scalesPageToFit");
    }else {
        self.uiWebView.scalesPageToFit = scalesPageToFit;
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    NSLog(@"shouldStartLoadWithRequest--%@",url);
    if ([[[request URL] scheme] isEqualToString:self.jsScheme]) {
        self.onJsCallback([url UTF8String]);
        return NO;
    }
    if (self.shouldStartLoading && url) {
        return self.shouldStartLoading([url UTF8String]);
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.didFinishLoading) {
        NSString *url = [[webView.request URL] absoluteString];
        self.didFinishLoading([url UTF8String]);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError--%@",error.localizedDescription);
    if (self.didFailLoading) {
        NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        if (url) {
            self.didFailLoading([url UTF8String]);
        }
    }
}

#pragma mark - WKNavigationDelegate
// 打开url时会询问是否允许或者取消导航
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSLog(@"decidePolicyForNavigationAction--%@",url);
    if ([url.scheme isEqualToString:self.jsScheme]) {
        self.onJsCallback(url.absoluteString.UTF8String);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    bool isAllow = true;
    if (self.shouldStartLoading && url.absoluteString) {
        isAllow = self.shouldStartLoading(url.absoluteString.UTF8String);
    }
    decisionHandler(isAllow ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

// 响应url时会询问是否允许或者取消
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
//    NSString *url = navigationResponse.response.URL.absoluteString;
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 开始导航，及开始加载网页显示
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{

}

// 导航出错时调用，及加载网页出错了
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailProvisionalNavigation--%@",error.localizedDescription);
    if (self.didFailLoading) {
        NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        if (url) {
            self.didFailLoading(url.UTF8String);
        }
    }
}

// 网页内容开始显示在页面时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
}

// 网页内容全部显示在页面时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.didFinishLoading) {
        const char *curl = webView.URL.absoluteString.UTF8String;
        self.didFinishLoading(curl);
    }
}

// 网页内容显示在页面过程中出错时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailNavigation--%@",error.localizedDescription);
    if (self.didFailLoading) {
        NSString *url = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        if (url) {
            self.didFailLoading(url.UTF8String);
        }
    }
}
#pragma mark - WKUIDelegate
///处理alert事件
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField){
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end

namespace cocos2d {
namespace experimental {
    namespace ui{

WebViewImpl::WebViewImpl(WebView *webView)
        : _uiWebViewWrapper([UIWebViewWrapper newWebViewWrapper]),
        _webView(webView) {
            
    _uiWebViewWrapper.shouldStartLoading = [this](std::string url) {
        if (this->_webView->_onShouldStartLoading) {
            return this->_webView->_onShouldStartLoading(this->_webView, url);
        }
        return true;
    };
    _uiWebViewWrapper.didFinishLoading = [this](std::string url) {
        if (this->_webView->_onDidFinishLoading) {
            this->_webView->_onDidFinishLoading(this->_webView, url);
        }
    };
    _uiWebViewWrapper.didFailLoading = [this](std::string url) {
        if (this->_webView->_onDidFailLoading) {
            this->_webView->_onDidFailLoading(this->_webView, url);
        }
    };
    _uiWebViewWrapper.onJsCallback = [this](std::string url) {
        if (this->_webView->_onJSCallback) {
            this->_webView->_onJSCallback(this->_webView, url);
        }
    };
}

WebViewImpl::~WebViewImpl(){
//    [_uiWebViewWrapper release];
    _uiWebViewWrapper = nullptr;
}

void WebViewImpl::setJavascriptInterfaceScheme(const std::string &scheme) {
    [_uiWebViewWrapper setJavascriptInterfaceScheme:scheme];
}

void WebViewImpl::loadData(const Data &data,
                           const std::string &MIMEType,
                           const std::string &encoding,
                           const std::string &baseURL) {
    
    std::string dataString(reinterpret_cast<char *>(data.getBytes()), static_cast<unsigned int>(data.getSize()));
    [_uiWebViewWrapper loadData:dataString MIMEType:MIMEType textEncodingName:encoding baseURL:baseURL];
}

void WebViewImpl::loadHTMLString(const std::string &string, const std::string &baseURL) {
    [_uiWebViewWrapper loadHTMLString:string baseURL:baseURL];
}

void WebViewImpl::loadURL(const std::string &url) {
    this->loadURL(url, false);
}

void WebViewImpl::loadURL(const std::string &url, bool cleanCachedData) {
    [_uiWebViewWrapper loadUrl:url cleanCachedData:cleanCachedData];
}

void WebViewImpl::loadFile(const std::string &fileName) {
    auto fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(fileName);
    [_uiWebViewWrapper loadFile:fullPath];
}

void WebViewImpl::stopLoading() {
    [_uiWebViewWrapper stopLoading];
}

void WebViewImpl::reload() {
    [_uiWebViewWrapper reload];
}

bool WebViewImpl::canGoBack() {
    return _uiWebViewWrapper.canGoBack;
}

bool WebViewImpl::canGoForward() {
    return _uiWebViewWrapper.canGoForward;
}

void WebViewImpl::goBack() {
    [_uiWebViewWrapper goBack];
}

void WebViewImpl::goForward() {
    [_uiWebViewWrapper goForward];
}

void WebViewImpl::evaluateJS(const std::string &js) {
    [_uiWebViewWrapper evaluateJS:js];
}

void WebViewImpl::setBounces(bool bounces) {
    [_uiWebViewWrapper setBounces:bounces];
}

void WebViewImpl::setScalesPageToFit(const bool scalesPageToFit) {
    [_uiWebViewWrapper setScalesPageToFit:scalesPageToFit];
}

void WebViewImpl::draw(cocos2d::Renderer *renderer, cocos2d::Mat4 const &transform, uint32_t flags) {
    if (flags & cocos2d::Node::FLAGS_TRANSFORM_DIRTY) {
        
        auto director = cocos2d::Director::getInstance();
        auto glView = director->getOpenGLView();
        auto frameSize = glView->getFrameSize();
        
//        auto scaleFactor = [static_cast<CCEAGLView *>(glView->getEAGLView()) contentScaleFactor];
        auto scaleFactor = [(__bridge CCEAGLView *)glView->getEAGLView() contentScaleFactor];

        auto winSize = director->getWinSize();

        auto leftBottom = this->_webView->convertToWorldSpace(cocos2d::Vec2::ZERO);
        auto rightTop = this->_webView->convertToWorldSpace(cocos2d::Vec2(this->_webView->getContentSize().width, this->_webView->getContentSize().height));

        auto x = (frameSize.width / 2 + (leftBottom.x - winSize.width / 2) * glView->getScaleX()) / scaleFactor;
        auto y = (frameSize.height / 2 - (rightTop.y - winSize.height / 2) * glView->getScaleY()) / scaleFactor;
        auto width = (rightTop.x - leftBottom.x) * glView->getScaleX() / scaleFactor;
        auto height = (rightTop.y - leftBottom.y) * glView->getScaleY() / scaleFactor;

        [_uiWebViewWrapper setFrameWithX:x
                                      y:y
                                  width:width
                                 height:height];
    }
}

void WebViewImpl::setVisible(bool visible){
    [_uiWebViewWrapper setVisible:visible];
}
        
void WebViewImpl::setOpacityWebView(float opacity){
    [_uiWebViewWrapper setOpacityWebView: opacity];
}
        
float WebViewImpl::getOpacityWebView() const{
    return [_uiWebViewWrapper getOpacityWebView];
}

void WebViewImpl::setBackgroundTransparent(){
    [_uiWebViewWrapper setBackgroundTransparent];
}

        
    } // namespace ui
} // namespace experimental
} //namespace cocos2d

#endif // CC_TARGET_PLATFORM == CC_PLATFORM_IOS
