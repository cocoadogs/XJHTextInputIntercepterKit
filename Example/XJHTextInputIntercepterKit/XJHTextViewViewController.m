//
//  XJHTextViewViewController.m
//  XJHTextInputIntercepterKit_Example
//
//  Created by cocoadogs on 2020/11/27.
//  Copyright © 2020 cocoadogs. All rights reserved.
//

#import "XJHTextViewViewController.h"
#import <XJHTextInputIntercepterKit/XJHTextInputIntercepter.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface XJHTextViewViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation XJHTextViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.leading.equalTo(self.view).offset(20);
        make.bottom.equalTo(self.view.mas_centerY).offset(-10);
        make.height.mas_equalTo(100);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 44));
        make.top.equalTo(self.view.mas_centerY).offset(10);
    }];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSLog(@"--- UITextView 输入 = %@ ---", text);
    return YES;
}

#pragma mark - Property Methods

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.textColor = [UIColor blackColor];
        _textView.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _textView.layer.borderColor = [UIColor blackColor].CGColor;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.cornerRadius = 4.0f;
        XJHTextInputIntercepter *intercepter = [[XJHTextInputIntercepter alloc] init];
//        intercepter.intercepterNumberType = XJHTextInputIntercepterNumberTypeDecimal;
        intercepter.maxInputLength = 10;
        intercepter.beyondBlock = ^(XJHTextInputIntercepter * _Nonnull intercepter, NSString * _Nonnull string) {
            NSLog(@"--- 超出最长长度了，结果 = %@ ---", string);
        };
        intercepter.inputBlock = ^(XJHTextInputIntercepter * _Nonnull intercepter, NSString * _Nonnull string) {
            NSLog(@"--- 输入结果 = %@ ---", string);
        };
        [intercepter textInputView:_textView];
    }
    return _textView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setTitle:@"Close" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeBtn.titleLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular]];
        [_closeBtn setBackgroundColor:[UIColor blackColor]];
        @weakify(self)
        [[_closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            self.navigationController?[self.navigationController popViewControllerAnimated:YES]:[self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }
    return _closeBtn;
}

@end
