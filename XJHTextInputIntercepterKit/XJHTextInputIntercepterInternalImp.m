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
        if ([self xjh_stringContainsEmojiByUTF8Length:string]) {
            returnValue = YES;
        } else {
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
    }
    return returnValue;
}

+ (BOOL)xjh_stringContainsEmojiByUTF8Length:(NSString *)string {
    NSUInteger stringUtf8Length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (stringUtf8Length >= 4 && (stringUtf8Length / string.length != 3)) {
        return YES;
    }
    return NO;
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
                        if (textField.intercepter.isEmojiAccepted) {
                            return [self shouldChangeInputString:string range:nil textField:textField];
                        } else {
                            if ([NSString xjh_stringContainsEmoji:string]) {
                                return NO;
                            } else {
                                return [self shouldChangeInputString:string range:nil textField:textField];
                            }
                        }
                    } else {
                        UITextRange *startRange= [textField textRangeFromPosition:textField.beginningOfDocument toPosition:markedRange.start];
                        if (textField.intercepter.isEmojiAccepted) {
                            if ([self canContinuesInRange:startRange textField:textField]) {
                                return [self shouldChangeInputString:string range:startRange textField:textField];
                            } else {
                                return NO;
                            }
                        } else {
                            if ([NSString xjh_stringContainsEmoji:string]) {
                                return NO;
                            } else {
                                if ([self canContinuesInRange:startRange textField:textField]) {
                                    return [self shouldChangeInputString:string range:startRange textField:textField];
                                } else {
                                    return NO;
                                }
                            }
                        }
                    }
                } else {
                    if (textField.intercepter.isEmojiAccepted) {
                        return [self shouldChangeInputString:string range:nil textField:textField];
                    } else {
                        if ([NSString xjh_stringContainsEmoji:string]) {
                            return NO;
                        } else {
                            return [self shouldChangeInputString:string range:nil textField:textField];
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
    NSString *origin = textField.text;
    NSString *string = [self processingTextWithInputString:origin intercepter:textField.intercepter];
    if ([origin isEqualToString:string]) {
        !textField.intercepter.inputBlock?:textField.intercepter.inputBlock(textField.intercepter, [string stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    }
    textField.text = string;
}


/// 判断输入字符串是否符合要求
/// @param string 输入字符串
/// @param range 已输入到输入框的文字的range
/// @param textField 输入框
- (BOOL)shouldChangeInputString:(NSString *)string range:(UITextRange *)range textField:(UITextField *)textField {
    if (range) {
        // 处于高亮的中文输入法状态
        NSUInteger alreadyLength = [self actualLengthForString:[textField textInRange:range] intercepter:textField.intercepter];
        return alreadyLength < textField.intercepter.maxInputLength;
    } else {
        NSUInteger alreadyLength = [self actualLengthForString:textField.text intercepter:textField.intercepter];
        if (alreadyLength < textField.intercepter.maxInputLength) {
            NSUInteger appendLength = [self actualLengthForString:string intercepter:textField.intercepter];
            if (alreadyLength + appendLength <= textField.intercepter.maxInputLength) {
                return YES;
            } else {
                !textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
                return NO;
            }
        } else {
            !textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldChangeInputString:(NSString *)string position:(UITextPosition *)position textView:(UITextView *)textView {
    
    return NO;
}

/// 高亮输入状态是否还可以继续输入
/// @param range 高亮选中的之前位置的字符串范围
/// @param textField 输入框
- (BOOL)canContinuesInRange:(UITextRange *)range textField:(UITextField *)textField {
    NSString *origin = [textField textInRange:range];
    NSString *content = [self processingTextWithInputString:origin intercepter:textField.intercepter];
    if (![origin isEqualToString:content]) {
        textField.text = content;
        return NO;
    }
//    return [self processingTextWithInputString:[textField textInRange:range] intercepter:textField.intercepter].length < textField.intercepter.maxInputLength;
    return YES;
}

- (BOOL)canContinuesInRange:(UITextRange *)range textView:(UITextView *)textView {
    NSString *origin = [textView textInRange:range];
    NSString *content = [self processingTextWithInputString:origin intercepter:textView.intercepter];
    if (![origin isEqualToString:content]) {
        textView.text = content;
        return NO;
    }
    return YES;
}

#pragma mark - NSString Dispatch Methods

- (NSString *)processingTextWithInputString:(NSString *)string intercepter:(XJHTextInputIntercepter *)intercepter {
    NSUInteger acceptLength = intercepter.maxInputLength;
    if (intercepter.isDoubleBytePerChineseCharacter) {
        if (intercepter.isEmojiAccepted) {
            // 调用 UTF8 编码处理 一个字符一个字节 一个汉字3个字节 一个表情4个字节
            NSUInteger textBytesLength = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            if (textBytesLength > acceptLength) {
                NSRange range;
                NSUInteger byteLength = 0;
                NSString *text = string;
                for (NSUInteger i = 0; i < string.length && byteLength <= acceptLength; i+= range.length) {
                    range = [string rangeOfComposedCharacterSequenceAtIndex:i];
                    byteLength += strlen([[text substringWithRange:range] UTF8String]);
                    if (byteLength > acceptLength) {
                        NSString *mText = [text substringWithRange:NSMakeRange(0, range.location)];
                        string = mText;
                    }
                }
                !intercepter.beyondBlock?:intercepter.beyondBlock(intercepter, [string stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
            }
        } else {
            // 不允许输入表情 一个字符一个字节 一个汉字2个字节
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSData *data = [string dataUsingEncoding:encoding];
            NSUInteger length = [data length];
            if (length > acceptLength) {
                NSData *subdata = [data subdataWithRange:NSMakeRange(0, acceptLength)];
                NSString *content = [[NSString alloc] initWithData:subdata encoding:encoding];//注意：当截取CharacterCount长度字符时把中文字符截断返回的content会是nil
                if (!content || content.length == 0) {
                    subdata = [data subdataWithRange:NSMakeRange(0, acceptLength - 1)];
                    content =  [[NSString alloc] initWithData:subdata encoding:encoding];
                }
                !intercepter.beyondBlock?:intercepter.beyondBlock(intercepter, [content stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
                string = content;
            }
        }
    } else {
        if (string.length > acceptLength) {
            NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:acceptLength];
            if (range.length == 1) {
                string = [string substringToIndex:acceptLength];
            } else {
                NSRange range = [string rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, acceptLength)];
                string = [string substringWithRange:range];
            }
            !intercepter.beyondBlock?:intercepter.beyondBlock(intercepter, [string stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
        }
    }
    return string;
}

- (NSUInteger)actualLengthForString:(NSString *)string intercepter:(XJHTextInputIntercepter *)intercepter {
    if (intercepter.isDoubleBytePerChineseCharacter) {
        if (intercepter.isEmojiAccepted) {
            // 调用 UTF8 编码处理 一个字符一个字节 一个汉字3个字节 一个表情4个字节
            NSUInteger textBytesLength = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            return textBytesLength;
        } else {
            // 不允许输入表情 一个字符一个字节 一个汉字2个字节
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSData *data = [string dataUsingEncoding:encoding];
            NSUInteger length = [data length];
            return length;
        }
    }
    return string.length;
}

#pragma mark - Setter Methods

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
}

- (void)setTextView:(UITextView *)textView {
    _textView = textView;
}


@end
