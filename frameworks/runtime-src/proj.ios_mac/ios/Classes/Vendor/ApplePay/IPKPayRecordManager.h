//
//  IPKPayRecordManager.h
//  iPoker
//
//  Created by loyalwind on 2018/3/13.
//  处理支付记录相关的


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IPKPayRecord : NSObject <NSCoding>
/** 公司后台交易订单号 */
@property (nonatomic, copy, readonly) NSString *orderid;
/** 苹果后台交易订单号 */
@property (nonatomic, copy, readonly) NSString *pdealno;
/** 票据 */
@property (nonatomic, strong, readonly) NSData *receipt;
/** 支付该订单的用户ID */
@property (nonatomic, copy, readonly) NSString *uid;

/**
 根据一个支付事务返回一条记录
 @param transaction 支付事务
 */
+ (instancetype)recordWithTransaction:(SKPaymentTransaction *)transaction;
/**
 根据一个支付事务返回一条记录
 @param transaction 支付事务
 */
- (instancetype)initWithTransaction:(SKPaymentTransaction *)transaction;
/**
 苹果支付订单信息模型转字典
 */
- (NSDictionary *)model2Dictionary;
/**
 该条记录是否有效
 */
- (BOOL)isValid;
@end


/**
 处理支付记录的工具类
 */
@interface IPKPayRecordManager :NSObject

/**
 保存一条记录
 */
+ (void)savePayRecord:(IPKPayRecord *)payRecord;

/**
 删除指定用户的事务号为 pdealno 的记录,并把剩余的记录放回出去
 @return 剩余的记录
 */
+ (NSMutableArray <IPKPayRecord *> *)deletePayRecordForUserID:(NSString *)uid pdealno:(NSString *)pdealno;

/**
 根据支付事务上传对应的记录，并把剩余的记录放回出去

 @param transaction 交易支付事务
 @return 剩余的记录
 */
+ (NSMutableArray <IPKPayRecord *> *)deletePayRecordWithTransaction:(SKPaymentTransaction *)transaction;

/**
 获取保存的所有记录

 @param uid 用户id
 @return 保存的所有记录
 */
+ (NSMutableArray <IPKPayRecord *> *)fetchPayRecordForUserID:(NSString *)uid;
@end

