//
//  UMCCustomToolBar.m
//  UdeskMChatExample
//
//  Created by xuchen on 2018/6/28.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCCustomToolBar.h"
#import "UMCCustomButtonConfig.h"
#import "NSString+UMC.h"

static CGFloat kUdeskCustomButtonHeight = 30;

@interface UMCCustomToolBar()

@property (nonatomic, strong) UIScrollView  *scrollview;
@property (nonatomic, strong) NSArray *customButtonConfigs;
@property (nonatomic, strong) NSMutableArray *customButtons;

@end

@implementation UMCCustomToolBar

- (instancetype)initWithFrame:(CGRect)frame customButtonConfigs:(NSArray<UMCCustomButtonConfig *> *)customButtonConfigs {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _customButtonConfigs = customButtonConfigs;
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.canCancelContentTouches = NO;
    _scrollview.delaysContentTouches = YES;
    _scrollview.backgroundColor = self.backgroundColor;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    [_scrollview setScrollsToTop:NO];
    _scrollview.pagingEnabled = YES;
    [self addSubview:_scrollview];
    
    
    if (!self.customButtonConfigs || self.customButtonConfigs == (id)kCFNull) return ;
    if (!self.customButtonConfigs.count) return;
    if (![self.customButtonConfigs.firstObject isKindOfClass:[UMCCustomButtonConfig class]]) return;
    
    for (UMCCustomButtonConfig *customButton in self.customButtonConfigs) {
        if (![customButton isKindOfClass:[UMCCustomButtonConfig class]]) return;
        
        if (customButton.type == UMCCustomButtonTypeInInputTop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(customButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:customButton.title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor colorWithRed:0.471f  green:0.471f  blue:0.471f alpha:1] forState:UIControlStateNormal];
            button.tag = 9447 + [self.customButtonConfigs indexOfObject:customButton];
            [button.layer setCornerRadius:13];
            [button.layer setMasksToBounds:YES];
            [button.layer setBorderWidth:1];
            [button.layer setBorderColor:[UIColor colorWithRed:0.906f  green:0.906f  blue:0.906f alpha:1].CGColor];
            [self.scrollview addSubview:button];
            [self.customButtons addObject:button];
        }
    }
}

- (void)customButtonAction:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomToolBar:atIndex:)]) {
        [self.delegate didSelectCustomToolBar:self atIndex:button.tag - 9447];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.customButtons.count) return;
    CGFloat scrollViewWidth = CGRectGetWidth(self.frame);
    _scrollview.frame = CGRectMake(0, 0, scrollViewWidth, CGRectGetHeight(self.frame)-1);
    
    CGFloat paddingX = 10;
    CGFloat contentSpace = 20;
    NSMutableArray *array = [NSMutableArray array];
    for (UIButton *button in self.customButtons) {
        
        @try {
            
            NSInteger index = [self.customButtons indexOfObject:button];
            CGSize buttonSize = [button.titleLabel.text umcSizeForFont:button.titleLabel.font size:CGSizeMake(CGFLOAT_MAX, kUdeskCustomButtonHeight) mode:NSLineBreakByTruncatingTail];
            
            UIButton *previousButton;
            if (index-1 < self.customButtons.count && index > 0) {
                previousButton = self.customButtons[index-1];
            }
            
            button.frame = CGRectMake(paddingX + CGRectGetMaxX(previousButton.frame), (CGRectGetHeight(self.scrollview.frame)-kUdeskCustomButtonHeight)/2, buttonSize.width + contentSpace, kUdeskCustomButtonHeight);
            [array addObject:@(CGRectGetWidth(button.frame))];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    UIButton *lastButton = self.customButtons.lastObject;
    [_scrollview setContentSize:CGSizeMake(CGRectGetMaxX(lastButton.frame) + paddingX, CGRectGetHeight(_scrollview.bounds))];
}

- (NSMutableArray *)customButtons {
    if (!_customButtons) {
        _customButtons = [NSMutableArray array];
    }
    return _customButtons;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.9 alpha:1].CGColor);
    
    CGContextMoveToPoint(ctx, 0, 44);
    CGContextAddLineToPoint(ctx, rect.size.width, 44);
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

@end
