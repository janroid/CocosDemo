//
//  IPKPayRecordManager.m
//  iPoker
//
//  Created by loyalwind on 2018/3/13.
//

#import "IPKPayRecordManager.h"
//#import "PKLanguageConfig.h"

#define NSUSERDEFAULTS [NSUserDefaults standardUserDefaults]

@interface IPKPayRecord ()
@property (nonatomic, copy) NSString *orderid;
@property (nonatomic, copy) NSString *pdealno;
@property (nonatomic, strong) NSData *receipt;
@property (nonatomic, copy) NSString *uid;
@end

@implementation IPKPayRecord

+ (instancetype)recordWithTransaction:(SKPaymentTransaction *)transaction
{
    return [[self alloc] initWithTransaction:transaction];
}
- (instancetype)initWithTransaction:(SKPaymentTransaction *)transaction
{
    if (self = [super init]) {
        NSDictionary *dict = transaction.payment.applicationUsername.toJSONObject;
        self.pdealno = transaction.transactionIdentifier;
        self.receipt = transaction.transactionReceipt;
        self.orderid = [dict[@"orderid"] stringValue];
        self.uid     = [dict[@"uid"] stringValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.orderid forKey:@"orderid"];
    [aCoder encodeObject:self.pdealno forKey:@"pdealno"];
    [aCoder encodeObject:self.receipt forKey:@"receipt"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]){
        self.orderid = [aDecoder decodeObjectForKey:@"orderid"];
        self.pdealno = [aDecoder decodeObjectForKey:@"pdealno"];
        self.receipt = [aDecoder decodeObjectForKey:@"receipt"];
        self.uid     = [aDecoder decodeObjectForKey:@"uid"];
    }
    return self;
}

- (NSDictionary *)model2Dictionary
{
    return @{
             @"orderid" : self.orderid,
             @"pdealno" : self.pdealno,
             @"receipt" : self.receipt,
             @"uid"     : self.uid,
             };
}
- (BOOL)isValid
{
    if(self.pdealno.length == 0 || self.uid.length == 0 || self.orderid.length == 0 || self.receipt == nil){
        return NO;
    }
    return YES;
}
@end


@implementation IPKPayRecordManager
static inline NSString * iPokerPaymentDataKey(NSString *uid){
    NSString *areaIdentify = [IPKPayRecordManager _fetchAreaID];
    // 返回一个用户保存该用户在该平台支付记录对应的的key
    return [NSString stringWithFormat:@"paymentData_%@_%@",areaIdentify,uid];
}
+ (void)savePayRecord:(IPKPayRecord *)payRecord
{
    if (!payRecord || payRecord.uid.length == 0) return;
    
    NSMutableArray *payRecords = nil;
    NSData *localdata = [NSUSERDEFAULTS objectForKey:iPokerPaymentDataKey(payRecord.uid)];
    
    if(localdata == nil){
        payRecords = [NSMutableArray array];
    }else{
        payRecords = [NSKeyedUnarchiver unarchiveObjectWithData:localdata];
    }
    BOOL needSave = YES;
    for (IPKPayRecord *tempRecord in payRecords) {
        if ([tempRecord.pdealno isEqualToString:payRecord.pdealno]) {
            // 该条记录已经保存过了，就是支付完成时就保存了，但是后来发货失败了，或者中途程序退出，导致该条记录没有回调删除
            needSave = NO;
            break;
        }
    }
    // 需要新增保存记录
    if (needSave) {
        [payRecords addObject:payRecord];
        NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:payRecords];
        [NSUSERDEFAULTS setObject:newData forKey:iPokerPaymentDataKey(payRecord.uid)];
        [NSUSERDEFAULTS synchronize];
    }
}

+ (NSMutableArray <IPKPayRecord *> *)deletePayRecordForUserID:(NSString *)uid pdealno:(NSString *)pdealno
{
    if (pdealno.length == 0 || uid.length == 0) return nil;
    
    NSMutableArray <IPKPayRecord *> *payRecords = [self fetchPayRecordForUserID:uid];
    
    if (payRecords.count == 0) return nil;
    
    for (IPKPayRecord *payRecord in payRecords) {
        if ([payRecord.pdealno isEqualToString:pdealno]) {
            // 移除对应的记录
            [payRecords removeObject:payRecord];
            // 保存起来
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:payRecords];
            [NSUSERDEFAULTS setObject:data forKey:iPokerPaymentDataKey(payRecord.uid)];
            [NSUSERDEFAULTS synchronize];
            break;
        }
    }
    // 剩余的记录返回出去
    return payRecords;
}

+ (NSMutableArray <IPKPayRecord *> *)deletePayRecordWithTransaction:(SKPaymentTransaction *)transaction
{
    NSDictionary *param = transaction.payment.applicationUsername.toJSONObject;
    return [self deletePayRecordForUserID:param[@"uid"] pdealno:transaction.transactionIdentifier];
}

+ (NSMutableArray <IPKPayRecord *> *)fetchPayRecordForUserID:(NSString *)uid
{
    NSData *localdata = [NSUSERDEFAULTS objectForKey:iPokerPaymentDataKey(uid)];
    if(localdata == nil) return nil;
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:localdata];
}

#pragma mark - privite 私有方法
+ (NSString *)_fetchAreaID
{
    IPKArea code = IPKAreaFB_VN;// TODO:等做成全球包时这里改成对应的语言
//    IPKArea   = [PKLanguageConfig getApplicationLanguage];
    NSString *areaIdentify = @"IPKAreaFB_ZW";
    switch (code) {
        case IPKAreaFB_ZW:/**< 台湾 */
            areaIdentify = @"IPKAreaFB_ZW";
            break;
        case IPKAreaFB_TL: /**< 泰语 */
            areaIdentify = @"IPKAreaFB_TL";
            break;
        case IPKAreaFB_ID:/**< 印尼 */
            areaIdentify = @"IPKAreaFB_ID";
            break;
        case IPKAreaFB_VN: /**< 越南 */
            areaIdentify = @"IPKAreaFB_VN";
            break;
        case IPKAreaFB_AR:/**< 阿语 */
            areaIdentify = @"IPKAreaFB_AR";
            break;
        case IPKAreaFB_FR:/**< 法语 */
            areaIdentify = @"IPKAreaFB_FR";
            break;
        default:
            break;
    }
    return areaIdentify;
}
@end
