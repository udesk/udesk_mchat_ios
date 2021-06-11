//
//  UDPhotoView.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCPhotoView.h"
#import "UMCOneScrollView.h"
#import "UMCBundleHelper.h"
#import "UMCButton.h"

#define Gap 10   //俩照片间黑色间距

@implementation UMCPhotoView {

    NSString *imageUrl;
    UIImage *localImage;
}

#pragma mark - 自己的属性设置一下
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        //设置主滚动创的大小位置
        self.frame = CGRectMake(-Gap, 0, [UIScreen mainScreen].bounds.size.width + Gap + Gap,[UIScreen mainScreen].bounds.size.height);
        
    }
    return self;
}

#pragma mark - 拿到数据时展示

-(void)setPhotoData:(UIImageView *)photoImageView withMessageURL:(NSString *)url {
    
    imageUrl = url;
    localImage = photoImageView.image;
    //传值给单个滚动器
    UMCOneScrollView *oneScroll = [[UMCOneScrollView alloc]init];
    oneScroll.mydelegate = self;
    //自己是数组中第几个图
    //设置位置并添加
    oneScroll.frame = CGRectMake(Gap , 0 ,kUMCPhotoScreenWidth, kUMCPhotoScreenHeight);
    [self addSubview:oneScroll];
    
    [oneScroll setLocalImage:photoImageView withMessageURL:url];
 
    UMCButton *button = [UMCButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kUMCPhotoScreenWidth-45-15, kUMCPhotoScreenHeight-26-15, 45, 26);
    [button setTitle:UMCLocalizedString(@"udesk_save") forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor]];
    [button addTarget:self action:@selector(umcSaveImageAction) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button.layer setCornerRadius:3];
    [button.layer setMasksToBounds:YES];
    [button.layer setBorderWidth:1];
    [button.layer setBorderColor:[UIColor grayColor].CGColor];
    [self addSubview:button];
}

- (void)umcSaveImageAction {
        
    if (localImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageWriteToSavedPhotosAlbum(localImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:UMCLocalizedString(@"udesk_failed_save") delegate:self cancelButtonTitle:nil otherButtonTitles:UMCLocalizedString(@"udesk_sure"), nil];
        [alert show];
#pragma clang diagnostic pop
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = UMCLocalizedString(@"udesk_failed_save");
    }else{
        msg = UMCLocalizedString(@"udesk_success_save");
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:UMCLocalizedString(@"udesk_sure"), nil];
    [alert show];
#pragma clang diagnostic pop
}

#pragma mark - OneScroll的代理方法

//退出图片浏览器
-(void)goBack
{
    //让原始底层UIView死掉
    [self.superview removeFromSuperview];
}


@end
