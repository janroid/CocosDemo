//
//  IPKApplePayManager.m
//  iPoker
//
//  Created by loyalwind on 2018/12/20.
//

#import "IPKApplePayManager.h"
#import "IPKPayRecordManager.h"
#import "AFNetworking.h"
#import <StoreKit/StoreKit.h>
#import "NSString+Extension.h"

#define DES3Key @"iPoker"

/**
 发货信息模型
 */
@interface IPKDeliveryModel : NSObject
/// 用户ID
@property (nonatomic, copy) NSString *uid;
/// 发货的url
@property (nonatomic, copy) NSString *payCGI;
/// 渠道
@property (nonatomic, copy) NSString *channel;
/// mtkey
@property (nonatomic, copy) NSString *mtkey;
/// skey
@property (nonatomic, copy) NSString *skey;

+ (instancetype)deliveryModelWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

@implementation IPKDeliveryModel
+ (instancetype)deliveryModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        // 赋值属性
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

@end

typedef NS_ENUM(NSInteger, IPKPayResult) {
    IPKPayResultPaySuccess = 1, /**< 支付成功 = 1 */
    IPKPayResultPayCancle = 2,  /**< 支付取消 = 2 */
    IPKPayResultUnsupport = 3,  /**< 不支持 = 3 */
    IPKPayResultDeliveryRequest = 7,/**< 请求发货 = 7 */
    IPKPayResultDeliveryFairlure = 9,/**< 发货失败 = 9 */
    IPKPayResultOthers = 100, /**< 其他 = 100 */
};

@interface IPKApplePayManager ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>
/// 回调block
@property(nonatomic ,copy) IPKHandleBridge handle;
/// itunes 后台的商品
@property (nonatomic, strong) NSArray <SKProduct *> *itcProducts;
/// 包含发货时需要的payCGI(url) , uid , channel, mtkey, skey
@property (nonatomic, strong) IPKDeliveryModel *deliveryModel;
@end


@implementation IPKApplePayManager

SingleImplementation(Manager)

- (instancetype)init
{
    static BOOL hasInited = NO;
    if (hasInited) return self;
    if (self = [super init]){
        hasInited = YES;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - 提供给外部的类方法
+ (void)setPayInfo:(NSDictionary *)param
{
    [IPKApplePayManager sharedManager].deliveryModel = [IPKDeliveryModel deliveryModelWithDict:param];
}

+ (void)queryProduct:(NSDictionary *)products handle:(IPKHandleBridge)handle
{
    [[IPKApplePayManager sharedManager] queryProduct:products handle:handle];
}

+ (void)pay:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    [[IPKApplePayManager sharedManager] pay:param handle:handle];
}

+ (void)consumePurchase:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    [[IPKApplePayManager sharedManager] consumePurchase:param handle:handle];
}

#pragma mark - 内部实际处理事件的对象方法
- (void)queryProduct:(NSDictionary *)products handle:(IPKHandleBridge)handle
{
    NSArray *productIDs = products[@"pids"];
    if([SKPaymentQueue canMakePayments]) {
        if (productIDs.count == 0) {
            handle ? handle(nil) : nil;
            return;
        }
        
        self.handle = handle;
        NSSet *set = [NSSet setWithArray:productIDs];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
    }else{
        NSLog(@"queryProduct, 您没允许应用程序内购买");
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您没允许应用程序内购买，请先在“设置”打开"
//                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
        handle ? handle(@{@"result" : @(IPKPayResultUnsupport)}) : nil;
    }
}

- (void)pay:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    self.handle = handle;
    NSString *productID   = param[@"productID"];
    SKProduct *buyProduct = nil;
    for (SKProduct *product in self.itcProducts) {
        if([product.productIdentifier isEqualToString:productID]){
            buyProduct = product;
            break;
        }
    }
    if (!buyProduct) {
        [self _safeCallHandle:@{@"result" : @(IPKPayResultUnsupport)}];
        return;
    }
    
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:buyProduct];
    
    // 保存到该次交易中，以便后续丢单是可以处理
    NSMutableDictionary *usernameDict = [NSMutableDictionary dictionary];
    usernameDict[@"uid"]     = self.deliveryModel.uid;
    usernameDict[@"orderid"] = param[@"order"];
    NSString *applicationUsername = [usernameDict.toJSONString des3EncryptHexWithKey:DES3Key];
    payment.applicationUsername     = applicationUsername;
    // 支付加入到队列中
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)consumePurchase:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    self.handle = handle;
    /// TODO
}

#pragma mark - SKProductsRequestDelegate 商品详情请求代理
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response
{
    if (response.products.count == 0) {
        [self _safeCallHandle:@{@"result" : @"0"}];
        return;
    }
    // 保存一份，用于都买时进行过滤出来
    self.itcProducts = response.products.copy;
    
    // 包装成lua可使用的参数
    NSMutableDictionary *products = [NSMutableDictionary dictionary];
    for(SKProduct *product in response.products) {
        
        NSString *currency = [product.priceLocale objectForKey:NSLocaleCurrencyCode];   //货币国际名称
        NSString *price = [NSString stringWithFormat:@"%@%@",currency, product.price];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"_price"]           = price;
        dict[@"_currency"]        = currency;

        products[product.productIdentifier] = dict;
    }
    [self _safeCallHandle:@{@"result" : @"1", @"products":products}];
}


#pragma mark - SKPaymentTransactionObserver 支付观察代理
- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in  transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:    //交易完成
                NSLog(@"SKPaymentTransactionStatePurchased");
                [self _completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:       //交易失败
                NSLog(@"SKPaymentTransactionStateFailed");
                [self _failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:     //已经购买过该商品
                NSLog(@"SKPaymentTransactionStateRestored");
                [self _restoreTransaction:transaction];
                break;
            default:
                // For debugging
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
}

#pragma mark - ****************     私有方法        ************
#pragma mark 支付相关
- (void)_completeTransaction:(SKPaymentTransaction *)transaction
{
    NSString *applicationUsername = [transaction.payment.applicationUsername des3DecryptHexWithKey:DES3Key];
    NSDictionary *paymentInfo = applicationUsername.toJSONObject;
    // 不是当前用户，例如之前用户购买了，但是没有发货成功，下次登录进来苹果会自动调这里
    NSString *puid = [NSString stringWithFormat:@"%@",paymentInfo[@"uid"]];
    NSString *duid = [NSString stringWithFormat:@"%@",self.deliveryModel.uid];
    if (![puid isEqualToString:duid]) {
        return;
    }
    
    // 苹果后台交易订单号
    NSString *transcationIdentifier = transaction.transactionIdentifier;
    // 票据
    NSString *receipt = [transaction.transactionReceipt base64EncodedStringWithOptions:kNilOptions];

    // 组装请求发货参数
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    param[@"mod"]   = @"pay";
    param[@"act"]   = @"delivery";
    param[@"uid"]   = self.deliveryModel.uid; // 用户id
    param[@"mtkey"] = self.deliveryModel.mtkey;
    param[@"skey"]  = self.deliveryModel.skey;
    param[@"pid"]   = transcationIdentifier; // 苹果生成订单号
    param[@"receipt"] = receipt; // 苹果开出的票据
    param[@"orderData"] = @{@"orderid":paymentInfo[@"orderid"]}.toJSONString;
    
    // 保存记录，以便恢复购买发货
    IPKPayRecord *payRecord = [IPKPayRecord recordWithTransaction:transaction];
    [IPKPayRecordManager savePayRecord:payRecord];
    
    // 去发货
    [self _gotoDelivery:param transaction:transaction];
}

- (void)_failedTransaction:(SKPaymentTransaction *)transaction
{
    IPKPayResult payState = IPKPayResultOthers;
    switch (transaction.error.code) {
        case SKErrorClientInvalid://用户不允许发起请求
        case SKErrorPaymentNotAllowed://本机器不允许支付
        case SKErrorPaymentInvalid://支付账号无效
        case SKErrorStoreProductNotAvailable://商品在当前店面无效
            NSLog(@"购买无效");
            payState = IPKPayResultUnsupport;
            break;
        case SKErrorPaymentCancelled://用户取消购买
            NSLog(@"用户取消购买");
            payState = IPKPayResultPayCancle;
            break;
        default:
            NSLog(@"failedTransaction error unknown:%@",transaction.error.localizedDescription);
            break;
    }
    
    [self _safeCallHandle:@{@"result":@(payState)}];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)_restoreTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self _safeCallHandle:@{@"result":@(IPKPayResultUnsupport)}];
}

#pragma mark - 发货相关
- (void)_gotoDelivery:(NSDictionary *)param transaction:(SKPaymentTransaction *)transaction
{
    // HTTP请求
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", nil];
    weakSelf(self)
    [manager POST:self.deliveryModel.payCGI parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"ret"] integerValue] == 0){ // 发货成功，回调lua
            [weakSelf _safeCallHandle:@{@"result" : @(IPKPayResultPaySuccess)}];
            // 删除记录
            [IPKPayRecordManager deletePayRecordWithTransaction:transaction];
            // 完成交易，把事务从交易队列中移除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }else{
            [weakSelf _safeCallHandle:@{@"result" : @(IPKPayResultDeliveryFairlure)}];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [weakSelf _safeCallHandle:@{@"result" : @(IPKPayResultDeliveryFairlure), @"error" : error.localizedDescription}];
    }];
}

- (void)_safeCallHandle:(id)param
{
    if (self.handle) {
        self.handle(param);
        self.handle = nil;
    }
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
@end
