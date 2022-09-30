//
//  XJHTextInputIntercepter.h
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/10/11.
//

#import <UIKit/UIKit.h>
@class XJHTextInputIntercepter;

NS_ASSUME_NONNULL_BEGIN

typedef void(^XJHTextInputIntercepterBlock)(XJHTextInputIntercepter *intercepter, NSString *string);

typedef NS_ENUM(NSUInteger, XJHTextInputIntercepterNumberType) {
    /// 非数字
    XJHTextInputIntercepterNumberTypeNone = 0,
    /// 只允许数字
    XJHTextInputIntercepterNumberTypeNumerOnly,
    /// 分数（默认两位小数）
    XJHTextInputIntercepterNumberTypeDecimal
};

@interface XJHTextInputIntercepter : NSObject

/// 拦截器实现实例，如果外部不传入则使用内建的实例
@property (nonatomic, strong) id imp;

/// 输入的字符串的最大长度
@property (nonatomic, assign) NSUInteger maxInputLength;

/// 小数位数，默认两位
@property (nonatomic, assign) NSUInteger maxDecimalDigits;

/// 输入完成回调
@property (nonatomic, copy) XJHTextInputIntercepterBlock inputBlock;

/// 输入超限回调
@property (nonatomic, copy) XJHTextInputIntercepterBlock beyondBlock;

/// 是否允许输入emoji表情
@property (nonatomic, assign, getter=isEmojiAccepted) BOOL emojiAccepted;

/// 拦截类型
/* XJHTextInputIntercepterNumberTypeNone 默认
 * XJHTextInputIntercepterNumberTypeNumerOnly 只允许输入数字，emojiAccepted、maxDecimalDigits不起作用
 * XJHTextInputIntercepterNumberTypeDecimal 分数，emojiAccepted不起作用，maxDecimalDigits 小数位数，默认两位
 */
@property (nonatomic, assign) XJHTextInputIntercepterNumberType intercepterNumberType;

/// 一个汉字是否是两个字节
/* doubleBytePerChineseCharacter 为 NO
 * 字母、数字、汉字都是一个字节 表情是两个字节
 * doubleBytePerChineseCharacter 为 YES
 * 不允许输入表情 一个汉字代表两个字节
 * 允许输入表情 一个汉字代表三个字节 表情代表四个字节
 */
@property (nonatomic, assign, getter=isDoubleBytePerChineseCharacter) BOOL doubleBytePerChineseCharacter;


@end


@interface UITextField (XJHTextInputIntercepter)

@property (nonatomic, strong) XJHTextInputIntercepter *intercepter;

/// 是否有小数点
@property (nonatomic, assign) BOOL hasDecimalPoint;

/// 首位是否为零
@property (nonatomic, assign) BOOL zeroAtHead;

@end

@interface UITextView (XJHTextInputIntercepter)

@property (nonatomic, strong) XJHTextInputIntercepter *intercepter;

@end

NS_ASSUME_NONNULL_END
