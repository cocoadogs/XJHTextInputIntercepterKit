//
//  XJHViewController.m
//  XJHTextInputIntercepterKit_Example
//
//  Created by cocoadogs on 2020/11/21.
//  Copyright © 2020 cocoadogs. All rights reserved.
//

#import "XJHViewController.h"
#import "XJHTestViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>

@interface XJHViewController ()

@property (nonatomic, strong) UIButton *showBtn;

@end

@implementation XJHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.showBtn];
    [self.showBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
}

#pragma mark - Property Methods

- (UIButton *)showBtn {
    if (!_showBtn) {
        _showBtn = [[UIButton alloc] init];
        [_showBtn setTitle:@"Test" forState:UIControlStateNormal];
        [_showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_showBtn.titleLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightRegular]];
        [_showBtn setBackgroundColor:[UIColor blackColor]];
        @weakify(self)
        [[_showBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self presentViewController:[[XJHTestViewController alloc] init] animated:YES completion:^{
                
            }];
        }];
    }
    return _showBtn;
}

@end
