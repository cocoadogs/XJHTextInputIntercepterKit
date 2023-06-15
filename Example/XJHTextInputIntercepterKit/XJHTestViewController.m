//
//  XJHTestViewController.m
//  XJHTextInputIntercepterKit_Example
//
//  Created by cocoadogs on 2020/11/25.
//  Copyright © 2020 cocoadogs. All rights reserved.
//

#import "XJHTestViewController.h"
#import <XJHTextInputIntercepterKit/XJHTextInputIntercepter.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface XJHTestViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation XJHTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.leading.equalTo(self.view).offset(20);
        make.height.mas_equalTo(44);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 44));
        make.bottom.equalTo(self.textField.mas_top).offset(-12);
    }];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:recognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)dealloc
{
    NSLog(@"--- XJHTestViewController dealloc ---");
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"--- UITextField 输入 = %@ ---", textField.text);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

#pragma mark - Private Methods

- (void)tapAction {
    [self.view endEditing:YES];
}

#pragma mark - Property Methods

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
//        _textField.delegate = self;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.borderStyle = UITextBorderStyleLine;
//        _textField.keyboardType = UIKeyboardTypeDecimalPad;
        _textField.textColor = [UIColor blackColor];
        _textField.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"测试" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14 weight:UIFontWeightRegular], NSForegroundColorAttributeName:[UIColor grayColor]}];
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeyDone;
        XJHTextInputIntercepter *intercepter = [[XJHTextInputIntercepter alloc] init];
        
//        intercepter.intercepterNumberType = XJHTextInputIntercepterNumberTypeDecimal;
//        intercepter.maxInputLength = 5;
//        intercepter.maxDecimalDigits = 1;
        
        intercepter.intercepterNumberType = XJHTextInputIntercepterNumberTypeNone;
        intercepter.maxInputLength = 10;
        
        intercepter.beyondBlock = ^(XJHTextInputIntercepter * _Nonnull intercepter, NSString * _Nonnull string) {
            NSLog(@"--- textField超出最长长度了，结果 = %@ ---", string);
        };
        intercepter.inputBlock = ^(XJHTextInputIntercepter * _Nonnull intercepter, NSString * _Nonnull string) {
            NSLog(@"--- textField输入结果 = %@ ---", string);
        };
        _textField.intercepter = intercepter;
    }
    return _textField;
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
