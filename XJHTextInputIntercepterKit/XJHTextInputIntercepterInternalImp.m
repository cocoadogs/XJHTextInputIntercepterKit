//
//  XJHTextInputIntercepterInternalImp.m
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/11/25.
//

#import "XJHTextInputIntercepterInternalImp.h"
#import "XJHTextInputIntercepter.h"

#pragma mark - NSString Input Type

typedef NS_ENUM(NSUInteger, XJHTextInputStringType) {
    XJHTextInputStringTypeNumber,
    XJHTextInputStringTypeLetter,
    XJHTextInputStringTypeChinese,
    XJHTextInputStringTypeEmoji
};

@interface NSString (XJHTextInputStringType)

- (BOOL)xjh_stringIsType:(XJHTextInputStringType)type;

- (BOOL)xjh_stringContainsEmoji;

- (NSString *)xjh_trimHeadAndTail;

+ (BOOL)xjh_stringContainsEmoji:(NSString *)string;

@end

@implementation NSString (XJHTextInputStringType)

- (BOOL)xjh_stringIsType:(XJHTextInputStringType)type {
    return [self xjh_matchRegularWithType:type];
}

- (BOOL)xjh_stringContainsEmoji {
    if ([self xjh_matchRegularWithType:XJHTextInputStringTypeEmoji]) {
        return YES;
    }
    if ([NSString xjh_stringContainsEmoji:self]) {
        return YES;
    }
    return NO;
}

- (NSString *)xjh_trimHeadAndTail {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

+ (BOOL)xjh_stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    if (string.length > 0) {
        [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
         ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
             const unichar hs = [substring characterAtIndex:0];
             // surrogate pair
             if (0xd800 <= hs && hs <= 0xdbff){
                 if (substring.length > 1){
                     const unichar ls = [substring characterAtIndex:1];
                     const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                     if (0x1d000 <= uc && uc <= 0x1f77f){
                         returnValue = YES;
                     }
                 }
             }
             else if (substring.length > 1){
                 const unichar ls = [substring characterAtIndex:1];
                 if (ls == 0x20e3 || ls == 0xfe0f){
                     returnValue = YES;
                 }
             }else{
                 // non surrogate
                 if (0x2100 <= hs && hs <= 0x27ff){
                     returnValue = YES;
                 }else if (0x2B05 <= hs && hs <= 0x2b07){
                     returnValue = YES;
                 }else if (0x2934 <= hs && hs <= 0x2935){
                     returnValue = YES;
                 }else if (0x3297 <= hs && hs <= 0x3299){
                     returnValue = YES;
                 }
                 else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50){
                     returnValue = YES;
                 }
             }
        }];
    }
    return returnValue;
}

- (BOOL)xjh_matchRegularWithType:(XJHTextInputStringType)type {
    NSString *regularString = @"";
    switch (type) {
        case XJHTextInputStringTypeNumber:
            regularString = @"^[0-9]+$";
            break;
        case XJHTextInputStringTypeLetter:
            regularString = @"^[A-Za-z]+$";
            break;
        case XJHTextInputStringTypeChinese:
            regularString = @"^[\u4e00-\u9fa5]+$";
            break;
        case XJHTextInputStringTypeEmoji:
            regularString = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
            break;
        default:
            break;
    }
    NSPredicate *regularTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularString];
    return [regularTest evaluateWithObject:self];
}

@end

@implementation XJHTextInputIntercepterInternalImp

- (void)dealloc
{
    NSLog(@"--- XJHTextInputIntercepterInternalImp dealloc ---");
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self didEndEdting:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason API_AVAILABLE(ios(10.0)) {
    [self didEndEdting:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] || [string isEqualToString:@"\n"]) {
        return YES;
    }
    XJHTextInputIntercepterNumberType type = textField.intercepter.intercepterNumberType;
    switch (type) {
        case XJHTextInputIntercepterNumberTypeNumerOnly: {
            if (string.length > 0) {
                unichar single = [string characterAtIndex:0];//当前输入的字符
                if ('0' <= single && single <= '9') {
                    if (textField.text.length < textField.intercepter.maxInputLength) {
                        return YES;
                    } else {
                        !textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
                        return NO;
                    }
                } else {
                    return NO;
                }
            }
        }
            break;
        case XJHTextInputIntercepterNumberTypeDecimal: {
            if ([textField.text rangeOfString:@"."].location == NSNotFound) {
                textField.hasDecimalPoint = NO;
            } else {
                textField.hasDecimalPoint = YES;
            }
            if ([textField.text rangeOfString:@"0"].location == NSNotFound) {
                textField.zeroAtHead = NO;
            }
            if (string.length > 0) {
                unichar single = [string characterAtIndex:0];//当前输入的字符
                if (('0' <= single && single <= '9') || single == '.') {
                    if (textField.text.length == 0) {
                        if (single == '.') {
                            return NO;
                        }
                        if (single == '0') {
                            textField.zeroAtHead = YES;
                            return YES;
                        }
                    }
                    
                    if (single == '.') {
                        if (!textField.hasDecimalPoint) {
                            textField.hasDecimalPoint = YES;
                            return YES;
                        } else {
                            return NO;
                        }
                    } else if (single == '0') {
                        if ((textField.zeroAtHead && textField.hasDecimalPoint) || (!textField.zeroAtHead && textField.hasDecimalPoint)) {
                            // 0.01 or 10200.00
                            NSRange pointRange = [textField.text rangeOfString:@"."];
                            NSUInteger length = range.location - pointRange.location;
                            if (length <= _maxDecimalDigits) {
                                return YES;
                            } else {
                                return NO;
                            }
                        } else if (!textField.hasDecimalPoint && textField.zeroAtHead) {
                            // 首位是0不是.，不能再输入0
                            return NO;
                        } else {
                            return YES;
                        }
                    } else {
                        if (textField.hasDecimalPoint) {
                            NSRange pointRange = [textField.text rangeOfString:@"."];
                            NSUInteger length = range.location - pointRange.location;
                            if (length <= _maxDecimalDigits) {
                                return YES;
                            } else {
                                return NO;
                            }
                        } else if (!textField.hasDecimalPoint && textField.zeroAtHead) {
                            return NO;
                        } else {
                            return YES;
                        }
                    }
                } else {
                    return NO;
                }
            }
        }
            break;
        default: {
            if ([string isEqualToString:@" "]) {
                /* 在输入单个字符或者粘贴内容时做如下处理，已确定光标应该停留的正确位置，
                没有下段从字符中间插入或者粘贴光标位置会出错 */
                // 首先使用 non-breaking space 代替默认输入的@“ ”空格
                string = [string stringByReplacingOccurrencesOfString:@" "
                                 withString:@"\u00a0"];
                textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                 withString:string];
                //确定输入或者粘贴字符后光标位置
                UITextPosition *beginning = textField.beginningOfDocument;
                UITextPosition *cursorLoc = [textField positionFromPosition:beginning
                                             offset:range.location+string.length];
                // 选中文本起使位置和结束为止设置同一位置
                UITextRange *textRange = [textField textRangeFromPosition:cursorLoc
                                                    toPosition:cursorLoc];
                // 选中字符范围（由于textRange范围的起始结束位置一样所以并没有选中字符）
                [textField setSelectedTextRange:textRange];
                
                return NO;
            } else {
                if ([[textField.textInputMode primaryLanguage] isEqualToString:@"zh-Hans"]) {
                    UITextRange *markedRange = [textField markedTextRange];
                    //获取高亮部分
                    UITextPosition *position = [textField positionFromPosition:markedRange.start offset:0];
                    if (!position) {
                        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                        if (textField.text.length < textField.intercepter.maxInputLength) {
                            return YES;
                        } else {
                            !textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
                            return NO;
                        }
                    } else {
                        UITextRange *startRange= [textField textRangeFromPosition:textField.beginningOfDocument toPosition:markedRange.start];
                        
                        if ([textField textInRange:startRange].length < textField.intercepter.maxInputLength) {
                            return YES;
                        } else {
                            !textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [[textField textInRange:startRange] stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
                            return NO;
                        }
                    }
                }
            }
        }
            break;
    }
    return YES;
}


#pragma mark - UITextViewDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length <= textView.intercepter.maxInputLength) {
        !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    } else {
        NSString *subString = [textView.text substringToIndex:textView.intercepter.maxInputLength];
        textView.text = subString;
        !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [subString stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // 此处将值传送出去
        !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
        return NO;
    }
    if ([text isEqualToString:@" "]) {
        /* 在输入单个字符或者粘贴内容时做如下处理，已确定光标应该停留的正确位置，
        没有下段从字符中间插入或者粘贴光标位置会出错 */
        // 首先使用 non-breaking space 代替默认输入的@“ ”空格
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
        textView.text = [textView.text stringByReplacingCharactersInRange:range
                                         withString:text];
        //确定输入或者粘贴字符后光标位置
        UITextPosition *beginning = textView.beginningOfDocument;
        UITextPosition *cursorLoc = [textView positionFromPosition:beginning
                                     offset:range.location+text.length];
        // 选中文本起使位置和结束为止设置同一位置
        UITextRange *textRange = [textView textRangeFromPosition:cursorLoc
                                            toPosition:cursorLoc];
        // 选中字符范围（由于textRange范围的起始结束位置一样所以并没有选中字符）
        [textView setSelectedTextRange:textRange];
        
        return NO;
    } else {
        if (textView.text.length < textView.intercepter.maxInputLength) {
            return YES;
        } else {
            !textView.intercepter.beyondBlock?:textView.intercepter.beyondBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
            return NO;
        }
    }
    return YES;
}

#pragma mark - Private Methods

- (void)didEndEdting:(UITextField *)textField {
    if (textField.text.length <= textField.intercepter.maxInputLength) {
        !textField.intercepter.inputBlock?:textField.intercepter.inputBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    } else {
        NSString *subString = [textField.text substringToIndex:textField.intercepter.maxInputLength];
        textField.text = subString;
        !textField.intercepter.inputBlock?:textField.intercepter.inputBlock(textField.intercepter, [subString stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    }
}

#pragma mark - Setter Methods

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
}

- (void)setTextView:(UITextView *)textView {
    _textView = textView;
}


@end
