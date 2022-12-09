//
//  XJHTextInputIntercepterInternalImp.h
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XJHTextInputIntercepterInternalImp : NSObject<UITextFieldDelegate, UITextViewDelegate>

/// 输入的字符串的最大长度
@property (nonatomic, assign) NSUInteger maxInputLength;

/// 小数位数，默认两位
@property (nonatomic, assign) NSUInteger maxDecimalDigits;

@property (nonatomic, weak) UITextField *textField;

@property (nonatomic, weak) UITextView *textView;


@end

NS_ASSUME_NONNULL_END
