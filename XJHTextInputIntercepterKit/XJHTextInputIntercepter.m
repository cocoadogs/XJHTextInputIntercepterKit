//
//  XJHTextInputIntercepter.m
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/10/11.
//

#import "XJHTextInputIntercepter.h"
#import "XJHTextInputIntercepterInternalImp.h"
#import "XJHTextInputIntercepterDispatcher.h"
#import <XJHMultiProxyKit/NSObject+XJHMultiProxyAdditions.h>
#import <objc/runtime.h>

#pragma mark - XJHTextInputIntercepter

@interface XJHTextInputIntercepter ()

@property (nonatomic, strong) XJHTextInputIntercepterInternalImp *internalImp;

@property (nonatomic, strong) XJHTextInputIntercepterDispatcher *dispatcher;

@end

@implementation XJHTextInputIntercepter

#pragma mark - LifeCycle Methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"---%@---dealloc---", NSStringFromClass([self class]));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxInputLength = UINT_MAX;
        _doubleBytePerChineseCharacter = NO;
        _maxDecimalDigits = 2;
    }
    return self;
}

#pragma mark - Notification Methods

- (void)textInputDidChangeWithNotification:(NSNotification *)noti {
    if (![((UIView *)noti.object) isFirstResponder]) {
        return;
    }
    BOOL textViewTextDidChange = [noti.name isEqualToString:UITextViewTextDidChangeNotification] &&
    [noti.object isKindOfClass:[UITextView class]];
    if (!textViewTextDidChange) {
        return;
    }
    if ([noti.name isEqualToString:UITextViewTextDidChangeNotification]) {
        UITextView *textView = (UITextView *)noti.object;
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (textView.text.length > _maxInputLength) {
                textView.text = [textView.text substringToIndex:_maxInputLength];
                !textView.intercepter.beyondBlock?:textView.intercepter.beyondBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
            } else {
                !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
            }
        }
    }
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        if (textField.text.length > _maxInputLength) {
            textField.text = [textField.text substringToIndex:_maxInputLength];
            !textField.intercepter.beyondBlock?:textField.intercepter.beyondBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
        } else {
            !textField.intercepter.inputBlock?:textField.intercepter.inputBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
        }
    }
}

#pragma mark - Setter Methods

- (void)setIntercepterNumberType:(XJHTextInputIntercepterNumberType)intercepterNumberType {
    _intercepterNumberType = intercepterNumberType;
    if (_intercepterNumberType ==  XJHTextInputIntercepterNumberTypeDecimal && (_maxDecimalDigits == 0)) {
        _maxDecimalDigits = 2;
    }
    
    if (_intercepterNumberType != XJHTextInputIntercepterNumberTypeNone) {
        _doubleBytePerChineseCharacter = NO;
    }
}

- (void)setMaxInputLength:(NSUInteger)maxInputLength {
    _maxInputLength = maxInputLength;
    self.internalImp.maxInputLength = maxInputLength;
}

- (void)setMaxDecimalDigits:(NSUInteger)maxDecimalDigits {
    _maxDecimalDigits = maxDecimalDigits;
    self.internalImp.maxDecimalDigits = maxDecimalDigits;
}


#pragma mark - Property Methods

- (XJHTextInputIntercepterInternalImp *)internalImp {
    if (!_internalImp) {
        _internalImp = [[XJHTextInputIntercepterInternalImp alloc] init];
    }
    _internalImp.maxInputLength = _maxInputLength;
    _internalImp.maxDecimalDigits = _maxDecimalDigits;
    return _internalImp;
}

- (XJHTextInputIntercepterDispatcher *)dispatcher {
    if (!_dispatcher) {
        _dispatcher = [[XJHTextInputIntercepterDispatcher alloc] init];
    }
    return _dispatcher;
}

@end

#pragma mark - UITextField Input Intercepter

@implementation UITextField (XJHTextInputIntercepter)

- (void)setIntercepter:(XJHTextInputIntercepter *)intercepter {
    [self addTarget:intercepter action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [intercepter.dispatcher xjh_addDelegate:self.delegate];
    self.delegate = intercepter.imp?:intercepter.internalImp;
    intercepter.internalImp.textField = self;
    [intercepter.dispatcher xjh_addDelegate:self.delegate];
    intercepter.dispatcher.textField = self;
    objc_setAssociatedObject(self, @selector(intercepter), intercepter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XJHTextInputIntercepter *)intercepter {
    return objc_getAssociatedObject(self, @selector(intercepter));
}

- (void)setHasDecimalPoint:(BOOL)hasDecimalPoint {
    objc_setAssociatedObject(self, @selector(hasDecimalPoint), @(hasDecimalPoint), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)hasDecimalPoint {
    return [objc_getAssociatedObject(self, @selector(hasDecimalPoint)) boolValue];
}

- (void)setZeroAtHead:(BOOL)zeroAtHead {
    objc_setAssociatedObject(self, @selector(zeroAtHead), @(zeroAtHead), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)zeroAtHead {
    return [objc_getAssociatedObject(self, @selector(zeroAtHead)) boolValue];
}

@end

#pragma mark - UITextView Input Intercepter

@implementation UITextView (XJHTextInputIntercepter)

- (void)setIntercepter:(XJHTextInputIntercepter *)intercepter {
    [[NSNotificationCenter defaultCenter] addObserver:intercepter selector:@selector(textInputDidChangeWithNotification:) name:UITextViewTextDidChangeNotification object:self];
    [intercepter.dispatcher xjh_addDelegate:self.delegate];
    self.delegate = intercepter.imp?:intercepter.internalImp;
    intercepter.internalImp.textView = self;
    [intercepter.dispatcher xjh_addDelegate:self.delegate];
    intercepter.dispatcher.textView = self;
    objc_setAssociatedObject(self, @selector(intercepter), intercepter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XJHTextInputIntercepter *)intercepter {
    return objc_getAssociatedObject(self, @selector(intercepter));
}

@end

