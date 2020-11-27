//
//  XJHViewController.m
//  XJHTextInputIntercepterKit_Example
//
//  Created by cocoadogs on 2020/11/21.
//  Copyright © 2020 cocoadogs. All rights reserved.
//

#import "XJHViewController.h"
#import "XJHTestViewController.h"
#import "XJHTextViewViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface XJHViewController ()

@property (nonatomic, strong) UIButton *fieldBtn;

@property (nonatomic, strong) UIButton *viewBtn;

@end

@implementation XJHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.fieldBtn];
    [self.view addSubview:self.viewBtn];
    [self.fieldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-30);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    [self.viewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(30);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
}

#pragma mark - Property Methods

- (UIButton *)viewBtn {
    if (!_viewBtn) {
        _viewBtn = [[UIButton alloc] init];
        [_viewBtn setTitle:@"Text View" forState:UIControlStateNormal];
        [_viewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_viewBtn.titleLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular]];
        [_viewBtn setBackgroundColor:[UIColor blackColor]];
        @weakify(self)
        [[_viewBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self presentViewController:[[XJHTextViewViewController alloc] init] animated:YES completion:^{
                
            }];
        }];
    }
    return _viewBtn;
}

- (UIButton *)fieldBtn {
    if (!_fieldBtn) {
        _fieldBtn = [[UIButton alloc] init];
        [_fieldBtn setTitle:@"Text Field" forState:UIControlStateNormal];
        [_fieldBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_fieldBtn.titleLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular]];
        [_fieldBtn setBackgroundColor:[UIColor blackColor]];
        @weakify(self)
        [[_fieldBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self presentViewController:[[XJHTestViewController alloc] init] animated:YES completion:^{
                
            }];
        }];
    }
    return _fieldBtn;
}

@end
