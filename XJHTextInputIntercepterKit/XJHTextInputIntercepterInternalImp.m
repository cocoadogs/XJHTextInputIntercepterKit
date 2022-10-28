//
//  XJHTextInputIntercepterInternalImp.m
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/11/25.
//

#import "XJHTextInputIntercepterInternalImp.h"
#import "XJHTextInputIntercepter.h"

#pragma mark - NSString Emoji

@interface NSString (XJHTextInputStringEmoji)

+ (BOOL)xjh_stringContainsEmoji:(NSString *)string;

@end

@implementation NSString (XJHTextInputStringType)

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

@end

@implementation XJHTextInputIntercepterInternalImp

- (void)dealloc
{
    NSLog(@"--- XJHTextInputIntercepterInternalImp dealloc ---");
    if (_textField) {
        [_textField removeObserver:self forKeyPath:@"text"];
    }
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
    NSString *decimalSeparator = [NSLocale currentLocale].decimalSeparator;
    switch (type) {
        case XJHTextInputIntercepterNumberTypeDecimal: {
            if ([textField.text rangeOfString:decimalSeparator].location == NSNotFound) {
                textField.hasDecimalPoint = NO;
            } else {
                textField.hasDecimalPoint = YES;
            }
            if ([textField.text rangeOfString:@"0"].location == NSNotFound) {
                textField.zeroAtHead = NO;
            }
            if (string.length > 0) {
                unichar single = [string characterAtIndex:0];//当前输入的字符
                if (('0' <= single && single <= '9') || single == [decimalSeparator characterAtIndex:0]) {
                    if (textField.text.length == 0) {
                        //输入框全新输入字符
                        if (single == [decimalSeparator characterAtIndex:0]) {
                            return NO;
                        }
                        if (single == '0') {
                            textField.zeroAtHead = YES;
                            return YES;
                        }
                    }
                    
                    //以下逻辑前提条件是输入框中原先已有内容
                    if (single == [decimalSeparator characterAtIndex:0]) {
                        if (!textField.hasDecimalPoint) {
                            textField.hasDecimalPoint = YES;
                            return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                        } else {
                            return ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                        }
                    } else if (single == '0') {
                        //此时输入的字符为0
                        textField.zeroAtHead = [textField.text hasPrefix:@"0"];
                        if ((textField.zeroAtHead && textField.hasDecimalPoint) || (!textField.zeroAtHead && textField.hasDecimalPoint)) {
                            // 0.01 or 10200.00
                            NSRange pointRange = [textField.text rangeOfString:decimalSeparator];
                            NSInteger distance = range.location - pointRange.location;
                            NSInteger digitsLength = [textField.text componentsSeparatedByString:decimalSeparator].lastObject.length;
                            if (distance > 0) {
                                //正向输入，正常判断即可
                                if (digitsLength < _maxDecimalDigits) {
                                    return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                } else {
                                    return ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                }
                            } else if (distance == 0) {
                                //移动光标插入位置等于之前内容中小数点的位置，也就是刚好插到小数点之前
                                if (textField.zeroAtHead) {
                                    // 首位是0不是.，不能再输入0
                                    return NO;
                                } else {
                                    return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                }
                            } else {
                                //移动光标的插入位置远离了小数点，并且有可能到第一位了
                                if (range.location == 0) {
                                    //移动光标的插入位置此时就是在首位了，不能再输入0
                                    return NO;
                                } else {
                                    if (textField.zeroAtHead) {
                                        return NO;
                                    } else {
                                        return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                    }
                                }
                            }
                        } else if (!textField.hasDecimalPoint && textField.zeroAtHead) {
                            // 首位是0不是.，不能再输入0
                            return NO;
                        } else {
                            if (range.location == 0) {
                                // 输入框中原先的内容的首位不是0，此时需要查看输入光标插入的位置，在首位之前的话需要判断，0的话不允许输入了
                                return NO;
                            }
                            return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                        }
                    } else {
                        //输入的是正常的数字1-9
                        textField.zeroAtHead = [textField.text hasPrefix:@"0"];
                        if (textField.hasDecimalPoint) {
                            //已经存在小数点，此时需要判断原先的内容中的小数位数
                            NSRange pointRange = [textField.text rangeOfString:decimalSeparator];
                            NSInteger distance = range.location - pointRange.location;
                            NSInteger digitsLength = [textField.text componentsSeparatedByString:decimalSeparator].lastObject.length;
                            if (distance > 0) {
                                //正向输入，正常判断即可
                                if (digitsLength < _maxDecimalDigits) {
                                    return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                } else {
                                    return ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                }
                            } else if (distance == 0) {
                                //移动光标插入位置等于之前内容中小数点的位置，也就是刚好插到小数点之前
                                if (textField.zeroAtHead) {
                                    return NO;
                                } else {
                                    return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                                }
                            } else {
                                //移动光标的插入位置远离了小数点，并且有可能到第一位了
                                return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                            }
                        } else if (!textField.hasDecimalPoint && textField.zeroAtHead) {
                            
                            if (range.location == 0) {
                                return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                            }
                            return NO;
                        } else {
                            return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                        }
                    }
                } else {
                    return NO;
                }
            }
        }
            break;
        case XJHTextInputIntercepterNumberTypeNumerOnly: {
            if (string.length > 0) {
                unichar single = [string characterAtIndex:0];//当前输入的字符
                if ('0' <= single && single <= '9') {
                    return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                } else {
                    return NO;
                }
            }
        }
            break;
        default: {
            if ([string isEqualToString:@" "]) {
                return [self handleWhiteSpace:string range:range intputView:textField responder:textField];
            } else {
                return [self outterShouldChangeInputString:string intercepter:textField.intercepter inputView:textField responder:textField];
            }
        }
            break;
    }
    return YES;
}


#pragma mark - UITextViewDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *origin = textView.text;
    NSString *string = [self processingTextWithInputString:origin intercepter:textView.intercepter];
    if ([origin isEqualToString:string]) {
        !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [string stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    }
    textView.text = string;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        return YES;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // 此处将值传送出去
//        !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
        return NO;
    }
    if ([text isEqualToString:@" "]) {
        return [self handleWhiteSpace:text range:range intputView:textView responder:textView];
    } else {
        return [self outterShouldChangeInputString:text intercepter:textView.intercepter inputView:textView responder:textView];
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

- (BOOL)handleWhiteSpace:(NSString *)whiteSpace range:(NSRange)range intputView:(id<UITextInput>)inputView responder:(UIResponder *)responder {
    /* 在输入单个字符或者粘贴内容时做如下处理，已确定光标应该停留的正确位置，
    没有下段从字符中间插入或者粘贴光标位置会出错 */
    // 首先使用 non-breaking space 代替默认输入的@“ ”空格
    whiteSpace = [whiteSpace stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
    if ([responder isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)responder;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:whiteSpace];
    }
    if ([responder isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)responder;
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:whiteSpace];
    }
    //确定输入或者粘贴字符后光标位置
    UITextPosition *beginning = inputView.beginningOfDocument;
    UITextPosition *cursorLoc = [inputView positionFromPosition:beginning
                                 offset:range.location+whiteSpace.length];
    // 选中文本起使位置和结束为止设置同一位置
    UITextRange *textRange = [inputView textRangeFromPosition:cursorLoc
                                        toPosition:cursorLoc];
    // 选中字符范围（由于textRange范围的起始结束位置一样所以并没有选中字符）
    [inputView setSelectedTextRange:textRange];
    return NO;
}


- (BOOL)outterShouldChangeInputString:(NSString *)string intercepter:(XJHTextInputIntercepter *)intercepter inputView:(id<UITextInput>)inputView responder:(UIResponder *)responder {
    if ([[responder.textInputMode primaryLanguage] isEqualToString:@"zh-Hans"]) {
        UITextRange *markedRange = [inputView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [inputView positionFromPosition:markedRange.start offset:0];
        if (!position) {
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (intercepter.isEmojiAccepted) {
                return [self shouldChangeInputString:string range:nil intercepter:intercepter inputView:inputView];
            } else {
                if ([NSString xjh_stringContainsEmoji:string]) {
                    return NO;
                } else {
                    return [self shouldChangeInputString:string range:nil intercepter:intercepter inputView:inputView];
                }
            }
        } else {
            UITextRange *startRange= [inputView textRangeFromPosition:inputView.beginningOfDocument toPosition:markedRange.start];
            if (intercepter.isEmojiAccepted) {
                if ([self canContinuesInRange:startRange intercepter:intercepter inputView:inputView]) {
                    return [self shouldChangeInputString:string range:startRange intercepter:intercepter inputView:inputView];
                } else {
                    return NO;
                }
            } else {
                if ([NSString xjh_stringContainsEmoji:string]) {
                    return NO;
                } else {
                    if ([self canContinuesInRange:startRange intercepter:intercepter inputView:inputView]) {
                        return [self shouldChangeInputString:string range:startRange intercepter:intercepter inputView:inputView];
                    } else {
                        return NO;
                    }
                }
            }
        }
    } else {
        if (intercepter.isEmojiAccepted) {
            return [self shouldChangeInputString:string range:nil intercepter:intercepter inputView:inputView];
        } else {
            if ([NSString xjh_stringContainsEmoji:string]) {
                return NO;
            } else {
                return [self shouldChangeInputString:string range:nil intercepter:intercepter inputView:inputView];
            }
        }
    }
    return YES;
}


/// 判断输入字符串是否符合要求
/// @param string 输入字符串
/// @param range 已输入到输入框的文字的range
/// @param intercepter 拦截器
/// @param inputView 输入控件
- (BOOL)shouldChangeInputString:(NSString *)string range:(UITextRange *)range intercepter:(XJHTextInputIntercepter *)intercepter inputView:(id<UITextInput>)inputView {
    if (range) {
        // 处于高亮的中文输入法状态
        NSUInteger alreadyLength = [self actualLengthForString:[inputView textInRange:range] intercepter:intercepter];
        return alreadyLength < intercepter.maxInputLength;
    } else {
        NSString *existString = [inputView textInRange:[inputView textRangeFromPosition:inputView.beginningOfDocument toPosition:inputView.endOfDocument]];
        NSUInteger existLength = [self actualLengthForString:existString intercepter:intercepter];
        if (existLength < intercepter.maxInputLength) {
            NSUInteger appendLength = [self actualLengthForString:string intercepter:intercepter];
            if (existLength + appendLength <= intercepter.maxInputLength) {
                return YES;
            } else {
                !intercepter.beyondBlock?:intercepter.beyondBlock(intercepter, [existString stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
                return NO;
            }
        } else {
            !intercepter.beyondBlock?:intercepter.beyondBlock(intercepter, [existString stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
            return NO;
        }
    }
    return YES;
}

/// 高亮输入状态是否还可以继续输入
/// @param range 高亮选中的之前位置的字符串范围
/// @param intercepter 拦截器
/// @param inputView 输入控件
- (BOOL)canContinuesInRange:(UITextRange *)range intercepter:(XJHTextInputIntercepter *)intercepter inputView:(id<UITextInput>)inputView {
    NSString *origin = [inputView textInRange:range];
    NSString *content = [self processingTextWithInputString:origin intercepter:intercepter];
    if (![origin isEqualToString:content]) {
        if ([inputView isKindOfClass:[UITextField class]]) {
            ((UITextField *)inputView).text = content;
        }
        if ([inputView isKindOfClass:[UITextView class]]) {
            ((UITextView *)inputView).text = content;
        }
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
