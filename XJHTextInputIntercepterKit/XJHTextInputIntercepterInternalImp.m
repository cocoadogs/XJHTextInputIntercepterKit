//
//  XJHTextInputIntercepterInternalImp.m
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/11/25.
//

#import "XJHTextInputIntercepterInternalImp.h"
#import "XJHTextInputIntercepter.h"

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
    NSString *decimalSeparator = [NSLocale currentLocale].decimalSeparator;
    NSString *englishSeparator = @".";
    if ([string isEqualToString:@""] || [string isEqualToString:@"\n"]) {
        if ([string isEqualToString:@""]) {
            NSString *left = [textField.text substringToIndex:range.location];
            if ([left rangeOfString:decimalSeparator].location == NSNotFound && [left rangeOfString:englishSeparator].location == NSNotFound) {
                textField.hasDecimalPoint = NO;
            } else {
                textField.hasDecimalPoint = YES;
            }
        }
        return YES;
    }
    XJHTextInputIntercepterNumberType type = textField.intercepter.intercepterNumberType;
    switch (type) {
        case XJHTextInputIntercepterNumberTypeDecimal: {
            if ([textField.text rangeOfString:decimalSeparator].location == NSNotFound && [textField.text rangeOfString:englishSeparator].location == NSNotFound) {
                textField.hasDecimalPoint = NO;
            } else {
                textField.hasDecimalPoint = YES;
            }
            textField.zeroAtHead = ({
                BOOL isZeroAtHead = textField.text.length == 0 ? NO :YES;
                if (isZeroAtHead) {
                    NSString *firstCharString = [textField.text substringWithRange:NSMakeRange(0, 1)];
                    isZeroAtHead = [[NSScanner scannerWithString:firstCharString] scanInt:NULL] ? (firstCharString.intValue == 0) : NO;
                }
                isZeroAtHead;
            });
            if (string.length > 0) {
                BOOL isNumber = [[NSScanner scannerWithString:string] scanInt:NULL];
                BOOL isSeperator = [string isEqualToString:decimalSeparator] || [string isEqualToString:englishSeparator];
                if (!isNumber && !isSeperator) {
                    return NO;
                } else {
                    if (textField.text.length == 0) {
                        //输入框全新输入字符
                        if (isSeperator) {
                            return NO;
                        }
                        if (string.intValue == 0) {
                            textField.zeroAtHead = YES;
                            return YES;
                        }
                    }
                    //以下逻辑前提条件是输入框中原先已有内容
                    if (isSeperator) {
                        if (!textField.hasDecimalPoint) {
                            textField.hasDecimalPoint = YES;
                            return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                        } else {
                            return ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                        }
                    } else if (string.intValue == 0) {
                        //此时输入的字符为0
                        if ((textField.zeroAtHead && textField.hasDecimalPoint) || (!textField.zeroAtHead && textField.hasDecimalPoint)) {
                            // 0.01 or 10200.00
                            BOOL isCurrentSeparatorFound = ([textField.text rangeOfString:decimalSeparator].location != NSNotFound);
                            NSRange pointRange = isCurrentSeparatorFound ? [textField.text rangeOfString:decimalSeparator] : [textField.text rangeOfString:englishSeparator];
                            NSInteger distance = range.location - pointRange.location;
                            NSInteger digitsLength = isCurrentSeparatorFound ? [textField.text componentsSeparatedByString:decimalSeparator].lastObject.length : [textField.text componentsSeparatedByString:englishSeparator].lastObject.length;
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
                        if (textField.hasDecimalPoint) {
                            //已经存在小数点，此时需要判断原先的内容中的小数位数
                            BOOL isCurrentSeparatorFound = ([textField.text rangeOfString:decimalSeparator].location != NSNotFound);
                            NSRange pointRange = isCurrentSeparatorFound ? [textField.text rangeOfString:decimalSeparator] : [textField.text rangeOfString:englishSeparator];
                            NSInteger distance = range.location - pointRange.location;
                            NSInteger digitsLength = isCurrentSeparatorFound ? [textField.text componentsSeparatedByString:decimalSeparator].lastObject.length : [textField.text componentsSeparatedByString:englishSeparator].lastObject.length;
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
                }
            }
        }
            break;
        case XJHTextInputIntercepterNumberTypeNumerOnly: {
            if (string.length > 0) {
                BOOL isNumber = [[NSScanner scannerWithString:string] scanInt:NULL];
                if (!isNumber) {
                    return NO;
                } else {
                    return textField.text.length < textField.intercepter.maxInputLength ?: ((void)(!textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "])), NO);
                }
            }
        }
            break;
        default: {
            if ([string isEqualToString:@" "]) {
                return [self handleWhiteSpace:string range:range intputView:textField responder:textField];
            }
        }
            break;
    }
    return YES;
}


#pragma mark - UITextViewDelegate Methods

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
    if ([responder isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)responder;
        return textField.text.length < _maxInputLength;
    }
    if ([responder isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)responder;
        return textView.text.length < _maxInputLength;
    }
    return YES;
}

#pragma mark - NSString Dispatch Methods

- (NSString *)processingTextWithInputString:(NSString *)string intercepter:(XJHTextInputIntercepter *)intercepter {
    NSUInteger acceptLength = intercepter.maxInputLength;
    if (intercepter.isDoubleBytePerChineseCharacter) {
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
        return [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
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
