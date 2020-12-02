//
//  XJHTextInputIntercepterDispatcher.m
//  XJHTextInputIntercepterKit
//
//  Created by cocoadogs on 2020/11/24.
//

#import "XJHTextInputIntercepterDispatcher.h"
#import <XJHMultiProxyKit/NSObject+XJHMultiProxyAdditions.h>

@interface XJHTextInputIntercepterDispatcher ()<UITextFieldDelegate, UITextViewDelegate>

@end

@implementation XJHTextInputIntercepterDispatcher

#pragma mark - LifeCycle Methods

- (void)dealloc
{
    NSLog(@"--- XJHTextInputIntercepterDispatcher dealloc ---");
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [XJHProxyExceptLast(UITextFieldDelegate) textField:textField shouldChangeCharactersInRange:range replacementString:string];
    id<UITextFieldDelegate> lastDelegate = self.xjh_multiProxy.lastDelegate;
    return [lastDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [XJHProxyExceptFirst(UITextFieldDelegate) textFieldShouldBeginEditing:textField];
    id<UITextFieldDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [firstDelegate textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [XJHProxy(UITextFieldDelegate) textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [XJHProxyExceptFirst(UITextFieldDelegate) textFieldShouldEndEditing:textField];
    id<UITextFieldDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [firstDelegate textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [XJHProxyExceptFirst(UITextFieldDelegate) textFieldDidEndEditing:textField];
    id<UITextFieldDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [firstDelegate textFieldDidEndEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason API_AVAILABLE(ios(10.0)) {
    [XJHProxyExceptFirst(UITextFieldDelegate) textFieldDidEndEditing:textField reason:reason];
    id<UITextFieldDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textFieldDidEndEditing:reason:)]) {
        [firstDelegate textFieldDidEndEditing:textField reason:reason];
    }
}

- (void)textFieldDidChangeSelection:(UITextField *)textField API_AVAILABLE(ios(13.0), tvos(13.0)) {
    [XJHProxy(UITextFieldDelegate) textFieldDidChangeSelection:textField];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [XJHProxyExceptFirst(UITextFieldDelegate) textFieldShouldClear:textField];
    id<UITextFieldDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [firstDelegate textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [XJHProxyExceptFirst(UITextFieldDelegate) textFieldShouldReturn:textField];
    id<UITextFieldDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [firstDelegate textFieldShouldReturn:textField];
    }
    return YES;
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [XJHProxy(UITextViewDelegate) textView:textView shouldChangeTextInRange:range replacementText:text];
    id<UITextViewDelegate> lastDelegate = self.xjh_multiProxy.lastDelegate;
    return [lastDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [XJHProxyExceptFirst(UITextViewDelegate) textViewShouldBeginEditing:textView];
    id<UITextViewDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        return [firstDelegate textViewShouldBeginEditing:textView];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [XJHProxyExceptFirst(UITextViewDelegate) textViewShouldEndEditing:textView];
    id<UITextViewDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [firstDelegate textViewShouldEndEditing:textView];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [XJHProxy(UITextViewDelegate) textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [XJHProxyExceptFirst(UITextViewDelegate) textViewDidEndEditing:textView];
    id<UITextViewDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [firstDelegate textViewDidEndEditing:textView];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [XJHProxy(UITextViewDelegate) textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [XJHProxy(UITextViewDelegate) textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    [XJHProxyExceptFirst(UITextViewDelegate) textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    id<UITextViewDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:interaction:)]) {
        return [firstDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange interaction:interaction];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0)) {
    [XJHProxyExceptFirst(UITextViewDelegate) textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    id<UITextViewDelegate> firstDelegate = self.xjh_multiProxy.firstDelegate;
    if ([firstDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:interaction:)]) {
        return [firstDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange interaction:interaction];
    }
    return YES;
}

#pragma mark - Setter Methods

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
    textField.delegate = self;
}

- (void)setTextView:(UITextView *)textView {
    _textView = textView;
    textView.delegate = self;
}

@end
