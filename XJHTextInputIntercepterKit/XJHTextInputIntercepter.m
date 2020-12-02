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

#pragma mark - UITextField Input Intercepter

@implementation UITextField (XJHTextInputIntercepter)

- (void)setIntercepter:(XJHTextInputIntercepter *)intercepter {
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
    objc_setAssociatedObject(self, @selector(intercepter), intercepter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XJHTextInputIntercepter *)intercepter {
    return objc_getAssociatedObject(self, @selector(intercepter));
}

@end

#pragma mark - XJHTextInputIntercepter Section

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
        _emojiAccepted = NO;
        _maxInputLength = UINT_MAX;
        _doubleBytePerChineseCharacter = NO;
        _maxDecimalDigits = 2;
    }
    return self;
}


#pragma mark - Public Methods

- (void)textInputView:(UIView *)textInputView {
    [XJHTextInputIntercepter textInputView:textInputView setInputIntercepter:self];
}

+ (void)textInputView:(UIView *)textInputView setInputIntercepter:(XJHTextInputIntercepter *)intercepter {
    if ([textInputView isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)textInputView;
        textField.intercepter = intercepter;
        [[NSNotificationCenter defaultCenter] addObserver:intercepter selector:@selector(textInputDidChangeWithNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        [intercepter.dispatcher xjh_addDelegate:textField.delegate];
        textField.delegate = intercepter.imp?:intercepter.internalImp;
        intercepter.internalImp.textField = textField;
        [intercepter.dispatcher xjh_addDelegate:textField.delegate];
        intercepter.dispatcher.textField = textField;
    } else if ([textInputView isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)textInputView;
        textView.intercepter = intercepter;
        [[NSNotificationCenter defaultCenter] addObserver:intercepter selector:@selector(textInputDidChangeWithNotification:) name:UITextViewTextDidChangeNotification object:textView];
        [intercepter.dispatcher xjh_addDelegate:textView.delegate];
        textView.delegate = intercepter.imp?:intercepter.internalImp;
        intercepter.internalImp.textView = textView;
        [intercepter.dispatcher xjh_addDelegate:textView.delegate];
        intercepter.dispatcher.textView = textView;
    }
}

+ (XJHTextInputIntercepter *)textInputView:(UIView *)textInputView beyondBlock:(XJHTextInputIntercepterBlock)beyondBlock {
    XJHTextInputIntercepter *intercepter = [[XJHTextInputIntercepter alloc] init];
    intercepter.beyondBlock = [beyondBlock copy];
    [self textInputView:textInputView setInputIntercepter:intercepter];
    return intercepter;
}

#pragma mark - Notification Methods

- (void)textInputDidChangeWithNotification:(NSNotification *)noti {
    if (![((UIView *)noti.object) isFirstResponder]) {
        return;
    }
    
    BOOL textFieldTextDidChange = [noti.name isEqualToString:UITextFieldTextDidChangeNotification] &&
    [noti.object isKindOfClass:[UITextField class]];
    BOOL textViewTextDidChange = [noti.name isEqualToString:UITextViewTextDidChangeNotification] &&
    [noti.object isKindOfClass:[UITextView class]];
    if (!textFieldTextDidChange && !textViewTextDidChange) {
        return;
    }
    
    if ([noti.name isEqualToString:UITextFieldTextDidChangeNotification]) {
        UITextField *textField = (UITextField *)noti.object;
        !textField.intercepter.inputBlock?:textField.intercepter.inputBlock(textField.intercepter, [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
    } else if ([noti.name isEqualToString:UITextViewTextDidChangeNotification]) {
        UITextView *textView = (UITextView *)noti.object;
        !textView.intercepter.inputBlock?:textView.intercepter.inputBlock(textView.intercepter, [textView.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "]);
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

#pragma mark - Property Methods

- (XJHTextInputIntercepterInternalImp *)internalImp {
    if (!_internalImp) {
        _internalImp = [[XJHTextInputIntercepterInternalImp alloc] init];
    }
    _internalImp.maxInputLength = _maxInputLength;
    _internalImp.maxDecimalDigits = _maxDecimalDigits;
    _internalImp.emojiAccepted = _emojiAccepted;
    return _internalImp;
}

- (XJHTextInputIntercepterDispatcher *)dispatcher {
    if (!_dispatcher) {
        _dispatcher = [[XJHTextInputIntercepterDispatcher alloc] init];
    }
    return _dispatcher;
}

@end
