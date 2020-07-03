//
//  UMCImagePicker.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCImagePicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UMCUIMacro.h"

@implementation UMCImagePicker

- (void)showWithSourceType:(UIImagePickerControllerSourceType)sourceType viewController:(UIViewController *)viewController {
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    //兼容ipad打不开相册问题，使用队列延迟
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.navigationBar.tintColor = [UIColor blueColor];
        
        NSString *movieType = (NSString *)kUTTypeMovie;
        NSString *imageType = (NSString *)kUTTypeImage;
        NSArray *arrMediaTypes = [NSArray arrayWithObjects:imageType,movieType,nil];
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            arrMediaTypes = [NSArray arrayWithObjects:imageType,nil];
        }
        [imagePickerController setMediaTypes: arrMediaTypes];
        
        imagePickerController.editing = YES;
        imagePickerController.delegate = self;
        imagePickerController.sourceType = sourceType;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        [viewController presentViewController:imagePickerController animated:YES completion:NULL];
    }];
}

- (void)dismissPickerViewController:(UIImagePickerController *)picker {
    
    @udWeakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @udStrongify(self);
        self.FinishNormalImageBlock = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    if (refURL) {
        
        ALAssetsLibrary* assetLibrary = [[ALAssetsLibrary alloc] init];
        @udWeakify(self);
        void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *) = ^(ALAsset *asset) {
            
            @udStrongify(self);
            if (asset != nil) {
                
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString *type = info[UIImagePickerControllerMediaType];
                if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
                    
                    NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
                    
                    if (self.FinishVideoBlock) {
                        self.FinishVideoBlock(videoPath,[rep filename]);
                    }
                }
                else {
                    
                    Byte *imageBuffer = (Byte*)malloc(rep.size);
                    NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:nil];
                    NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
                    
                    NSString *type = [self contentTypeForImageData:imageData];
                    
                    if ([type isEqualToString:@"gif"]) {
                        
                        if (self.FinishGIFImageBlock) {
                            self.FinishGIFImageBlock(imageData);
                        }
                    }
                    else {
                        
                        if (self.FinishNormalImageBlock) {
                            self.FinishNormalImageBlock(info[UIImagePickerControllerOriginalImage]);
                        }
                    }
                }
            }
        };
        
        [assetLibrary assetForURL:refURL
                      resultBlock:ALAssetsLibraryAssetForURLResultBlock
                     failureBlock:^(NSError *error){
                     }];
        
    }
    else {
        
        NSString *type = info[UIImagePickerControllerMediaType];
        if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
            
            NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
            
            if (self.FinishVideoBlock) {
                self.FinishVideoBlock(videoPath,[NSString stringWithFormat:@"%@.mp4",[[NSUUID UUID] UUIDString]]);
            }
        }
        else {
            
            if (self.FinishNormalImageBlock) {
                self.FinishNormalImageBlock(info[UIImagePickerControllerOriginalImage]);
            }
        }
    }
    
    [self dismissPickerViewController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}

//通过图片Data数据第一个字节 来获取图片扩展名
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            if ([data length] < 12) {
                return nil;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

@end
