//
//  IPKUploadManager.m
//  iPoker
//
//  Created by boyaa on 2018/12/20.
//

#import "IPKUploadManager.h"
#import "AFNetworking.h"

@implementation IPKUploadManager
SingleImplementation(Manager)

+ (void)upload:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:param[@"file"]]) {
        handle ? handle (nil): nil;
        return;
    }

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error = nil;
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:file] name:@"upload" fileName:@"icon.jpg" mimeType:@"image/jpeg" error:&error];
            //        [formData appendPartWithFileData:data name:@"upload" fileName:@"icon.jpg" mimeType:@"image/jpeg"];
    } error:nil];
//
//    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
//
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//
//    NSURLSessionUploadTask *uploadTask;
//
//    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
//            // This is not called back on the main queue.
//            // You are responsible for dispatching to the main queue for UI updates
//    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, responseObject);
//        }
//        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
//    }];
//
//    [uploadTask resume];
}
+ (void)umError:(NSDictionary *)param
{
    
}
@end
