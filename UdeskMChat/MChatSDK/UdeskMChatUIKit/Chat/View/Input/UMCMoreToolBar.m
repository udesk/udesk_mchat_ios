//
//  UMCMoreToolBar.m
//  UdeskMChatExample
//
//  Created by xuchen on 2018/3/20.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCMoreToolBar.h"
#import "UMCButton.h"
#import "UIImage+UMC.h"
#import "UMCBundleHelper.h"
#import "UMCUIMacro.h"
#import "UMCCustomButtonConfig.h"
#import "UMCSDKConfig.h"
#import "UMCImageHelper.h"

// 每行有4个
#define kUdeskPerRowItemCount 4
#define kUdeskPerColum 2
#define kUdeskMoreItemWidth 60
#define kUdeskMoreItemHeight 84

@interface UMCMoreToolBar()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UMCButton *photoButton;
@property (nonatomic, strong) UMCButton *shootButton;
@property (nonatomic, strong) UMCButton *surveyButton;
@property (nonatomic, strong) UMCButton *shootVideoButton;
@property (nonatomic, strong) UMCButton *fileButton;

@property (nonatomic, strong) NSMutableArray *allItems;

@end

@implementation UMCMoreToolBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.delegate = self;
    _scrollview.canCancelContentTouches = NO;
    _scrollview.delaysContentTouches = YES;
    _scrollview.backgroundColor = self.backgroundColor;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    [_scrollview setScrollsToTop:NO];
    _scrollview.pagingEnabled = YES;
    [self addSubview:_scrollview];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 1;
    _pageControl.backgroundColor = self.backgroundColor;
    _pageControl.hidesForSinglePage = YES;
    _pageControl.defersCurrentPageDisplay = YES;
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.545f  green:0.545f  blue:0.545f alpha:1];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.733f  green:0.733f  blue:0.733f alpha:1];
    [self addSubview:_pageControl];
    
    UMCSDKConfig *sdkConfig = [UMCSDKConfig sharedConfig];
    
    if (!sdkConfig.hiddenAlbumButton) {
        _photoButton = [self buttonWithImage:[UIImage umcDefaultChatBarMorePhotoImage] title:UMCLocalizedString(@"udesk_album")];
        _photoButton.tag = 9347 + 0;
        [_scrollview addSubview:_photoButton];
        [self.allItems addObject:_photoButton];
    }
    
    if (!sdkConfig.hiddenCameraButton) {
        _shootButton = [self buttonWithImage:[UIImage umcDefaultChatBarMoreCameraImage] title:UMCLocalizedString(@"udesk_shooting")];
        _shootButton.tag = 9347 + 1;
        [_scrollview addSubview:_shootButton];
        [self.allItems addObject:_shootButton];
    }
    
    if (!sdkConfig.hiddenCameraButton) {
        _shootVideoButton = [self buttonWithImage:[UIImage umcDefaultChatBarMoreSmallVideoImage] title:UMCLocalizedString(@"udesk_shooting_video")];
        _shootVideoButton.tag = 9347 + 3;
        [_scrollview addSubview:_shootVideoButton];
        [self.allItems addObject:_shootVideoButton];
    }
    
    if (!sdkConfig.hiddenFileButton) {
        _fileButton = [self buttonWithImage:[UIImage umcDefaultChatBarMoreFile] title:UMCLocalizedString(@"udesk_file")];
        _fileButton.tag = 9347 + 4;
        [_scrollview addSubview:_fileButton];
        [self.allItems addObject:_fileButton];
    }
}

- (UMCButton *)buttonWithImage:(UIImage *)image title:(NSString *)title {
    
    UMCButton *button = [UMCButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(itemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.471f  green:0.471f  blue:0.471f alpha:1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11.0];
    
    if (image) {
        button.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 15, 0);
        button.titleEdgeInsets = UIEdgeInsetsMake(45, -60, -20, 0);
    }
    
    return button;
}

- (void)setEnableSurvey:(BOOL)enableSurvey {
    _enableSurvey = enableSurvey;
    
    if (_enableSurvey) {
        [self appendSurveyButton];
    }
}

- (void)setCustomMenuItems:(NSArray *)customMenuItems {

    if (!customMenuItems || customMenuItems == (id)kCFNull) return ;
    if (![customMenuItems isKindOfClass:[NSArray class]]) return ;
    if (!customMenuItems.count) return;
    if (![customMenuItems.firstObject isKindOfClass:[UMCCustomButtonConfig class]]) return;

    //没有在更多view里的自定义按钮
    NSArray *types = [customMenuItems valueForKey:@"type"];
    if (![types containsObject:@1]) return;

    _customMenuItems = customMenuItems;

    for (UMCCustomButtonConfig *customButton in customMenuItems) {
        if (![customButton isKindOfClass:[UMCCustomButtonConfig class]]) return;

        if (customButton.type == UMCCustomButtonTypeInMoreView) {

            UMCButton *button = [self buttonWithImage:[UMCImageHelper imageResize:customButton.image toSize:CGSizeMake(60, 60)] title:customButton.title];
            button.tag = 9347 + [customMenuItems indexOfObject:customButton] + 5;
            [_scrollview addSubview:button];
            [self.allItems addObject:button];
        }
    }
}

- (void)appendSurveyButton {
    
    _surveyButton = [self buttonWithImage:[UIImage umcDefaultChatBarMoreSurveyImage] title:UMCLocalizedString(@"udesk_survey")];
    _surveyButton.tag = 9347 + 2;
    [_scrollview addSubview:_surveyButton];
    [self.allItems addObject:_surveyButton];
    [self setNeedsLayout];
}

- (void)removeSurveyButton {
    
    [self.surveyButton removeFromSuperview];
    if ([self.allItems containsObject:self.surveyButton]) {
        [self.allItems removeObject:self.surveyButton];
    }
}

- (void)itemButtonAction:(UMCButton *)button {
    
    NSInteger index = button.tag - 9347;
    if (index > 4) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomMoreMenuItem:atIndex:)]) {
            [self.delegate didSelectCustomMoreMenuItem:self atIndex:index-5];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMoreMenuItem:itemType:)]) {
        [self.delegate didSelectMoreMenuItem:self itemType:button.tag - 9347];
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    @try {
     
        //每页宽度
        CGFloat pageWidth = scrollView.frame.size.width;
        //根据当前的坐标与页宽计算当前页码
        NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
        [self.pageControl setCurrentPage:currentPage];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.allItems.count) return;
    
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 20, CGRectGetWidth(self.frame), 20);
    _pageControl.numberOfPages = (self.allItems.count / (kUdeskPerRowItemCount * 2) + (self.allItems.count % (kUdeskPerRowItemCount * 2) ? 1 : 0));
    
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(_pageControl.frame));
    [_scrollview setContentSize:CGSizeMake(((self.allItems.count / (kUdeskPerRowItemCount * 2) + (self.allItems.count % (kUdeskPerRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(_scrollview.bounds))];
    
    CGFloat paddingX = (kUMCScreenWidth-(kUdeskMoreItemWidth * 4))/5;
    CGFloat paddingY = 20;
    for (UMCButton *button in self.allItems) {
        NSInteger index = [self.allItems indexOfObject:button];
        NSInteger page = index / (kUdeskPerRowItemCount * kUdeskPerColum);
        
        CGRect itemFrame = CGRectMake((index % kUdeskPerRowItemCount) * (kUdeskMoreItemWidth + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / kUdeskPerRowItemCount) - kUdeskPerColum * page) * (kUdeskMoreItemHeight + paddingY) + paddingY, kUdeskMoreItemWidth, kUdeskMoreItemHeight);
        
        button.frame = itemFrame;
    }
}

#pragma mark - lazy
- (NSMutableArray *)allItems {
    if (!_allItems) {
        _allItems = [NSMutableArray array];
    }
    return _allItems;
}

@end
