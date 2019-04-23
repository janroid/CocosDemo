//
//  IPKApplePayManager.h
//  iPoker
//
//  Created by loyalwind on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

NS_ASSUME_NONNULL_BEGIN

@interface IPKApplePayManager : NSObject
SingleInterface(Manager)


/**
 设置发货时需要的的信息

 @param param 包含发货时需要的payCGI , uid , channel, mtkey, skey
 */
+ (void)setPayInfo:(NSDictionary *)param;

/**
 查询商品

 @param products 商品pids
 @param handle 回调
 */
+ (void)queryProduct:(NSDictionary *)products handle:(IPKHandleBridge)handle;

/**
 支付商品
 
 @param param 订单信息, order, productID, payMoney, currencyCode
 @param handle 回调
 */
+ (void)pay:(NSDictionary *)param handle:(IPKHandleBridge)handle;

/**
 恢复购买未发货订单

 @param param 参数，暂时不用
 @param handle 回调
 */
+ (void)consumePurchase:(NSDictionary *)param handle:(IPKHandleBridge)handle;
@end

NS_ASSUME_NONNULL_END
