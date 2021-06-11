//
//  WHC_BaseOperation.m
//  WHCNetWorkKit
//
//  Created by 吴海超 on 15/11/6.
//  Copyright © 2015年 吴海超. All rights reserved.
//

/*
 *  qq:712641411
 *  gitHub:https://github.com/netyouli
 *  csdn:http://blog.csdn.net/windwhc/article/category/3117381
 */

#import "UMC_WHC_BaseOperation.h"
#import "UMC_WHC_HttpManager.h"

NSTimeInterval const kUMCWHCRequestTimeout = 30;
NSTimeInterval const kUMCWHCDownloadSpeedDuring = 1.5;
CGFloat        const kUMCWHCWriteSizeLenght = 1024 * 1024;
NSString  * const  kUMCWHCDomain = @"WHC_HTTP_OPERATION";
NSString  * const  kUMCWHCInvainUrlError = @"无效的url:%@";
NSString  * const  kUMCWHCCalculateFolderSpaceAvailableFailError = @"计算文件夹存储空间失败";
NSString  * const  kUMCWHCErrorCode = @"错误码:%ld";
NSString  * const  kUMCWHCFreeDiskSapceError = @"磁盘可用空间不足需要存储空间:%llu";
NSString  * const  kUMCWHCRequestRange = @"bytes=%lld-";
NSString  * const  kUMCWHCUploadCode = @"WHC";

@interface UMC_WHC_BaseOperation () {
    NSTimer * _speedTimer;
}

@end

@implementation UMC_WHC_BaseOperation

#pragma mark - 重写属性方法 -
- (void)setStrUrl:(NSString *)strUrl {
    _strUrl = strUrl.copy;
    NSString * newUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)_strUrl,
                                                                                              (CFStringRef)@"!$&'()*-,-./:;=?@_~%#[]",
                                                                                              NULL,
                                                                                              kCFStringEncodingUTF8));
    _urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:newUrl]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = kUMCWHCRequestTimeout;
        _requestType = UMC_WHCHttpRequestGet;
        _requestStatus = UMC_WHCHttpRequestNone;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _responseData = [NSMutableData data];
    }
    return self;
}

- (void)dealloc{
    [self cancelledRequest];
}


#pragma mark - 重写队列操作方法 -

- (void)start {
    if ([NSURLConnection canHandleRequest:self.urlRequest]) {
        self.urlRequest.timeoutInterval = self.timeoutInterval;
        self.urlRequest.cachePolicy = self.cachePolicy;
        [_urlRequest setValue:self.contentType forHTTPHeaderField: @"Content-Type"];
        switch (self.requestType) {
            case UMC_WHCHttpRequestGet:
            case UMC_WHCHttpRequestFileDownload:{
                [_urlRequest setHTTPMethod:@"GET"];
            }
                break;
            case UMC_WHCHttpRequestPost:
            case UMC_WHCHttpRequestFileUpload:{
                [_urlRequest setHTTPMethod:@"POST"];
                if([UMC_WHC_HttpManager shared].cookie && [UMC_WHC_HttpManager shared].cookie.length > 0) {
                    [_urlRequest setValue:[UMC_WHC_HttpManager shared].cookie forHTTPHeaderField:@"Cookie"];
                }
                if (self.postParam != nil) {
                    NSData * paramData = nil;
                    if ([self.postParam isKindOfClass:[NSData class]]) {
                        paramData = (NSData *)self.postParam;
                    }else if ([self.postParam isKindOfClass:[NSString class]]) {
                        paramData = [((NSString *)self.postParam) dataUsingEncoding:self.encoderType allowLossyConversion:YES];
                    }
                    if (paramData) {
                        [_urlRequest setHTTPBody:paramData];
                        [_urlRequest setValue:[NSString stringWithFormat:@"%zd", paramData.length] forHTTPHeaderField: @"Content-Length"];
                    }
                }
            }
                break;
            default:
                break;
        }
        if(self.urlConnection == nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            });
            self.urlConnection = [[NSURLConnection alloc]initWithRequest:_urlRequest delegate:self startImmediately:NO];
        }
    }else {
        [self handleReqeustError:nil code:UMC_WHCGeneralError];
    }
}

- (BOOL)isExecuting {
    return _requestStatus == UMC_WHCHttpRequestExecuting;
}

- (BOOL)isCancelled {
    return _requestStatus == UMC_WHCHttpRequestCanceled ||
    _requestStatus == UMC_WHCHttpRequestFinished;
}

- (BOOL)isFinished {
    return _requestStatus == UMC_WHCHttpRequestFinished;
}

- (BOOL)isConcurrent{
    return YES;
}


#pragma mark - 公共方法 -

- (void)calculateNetworkSpeed {
    float downloadSpeed = (float)_orderTimeDataLenght / (kUMCWHCDownloadSpeedDuring * 1024.0);
    _networkSpeed = [NSString stringWithFormat:@"%.1fKB/s", downloadSpeed];
    if (downloadSpeed >= 1024.0) {
        downloadSpeed = ((float)_orderTimeDataLenght / 1024.0) / (kUMCWHCDownloadSpeedDuring * 1024.0);
        _networkSpeed = [NSString stringWithFormat:@"%.1fMB/s",downloadSpeed];
    }
    _orderTimeDataLenght = 0;
}


- (void)clearResponseData {
    [self.responseData resetBytesInRange:NSMakeRange(0, self.responseData.length)];
    [self.responseData setLength:0];
}

- (void)startRequest {
    NSRunLoop * urnLoop = [NSRunLoop currentRunLoop];
    [_urlConnection scheduleInRunLoop:urnLoop forMode:NSDefaultRunLoopMode];
    [self willChangeValueForKey:@"isExecuting"];
    _requestStatus = UMC_WHCHttpRequestExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    [_urlConnection start];
    [urnLoop run];
}

- (void)addDependOperation:(UMC_WHC_BaseOperation *)operation {
    [self addDependency:operation];
}

- (void)startSpeedTimer {
    if (!_speedTimer && (_requestType == UMC_WHCHttpRequestFileUpload ||
                         _requestType == UMC_WHCHttpRequestFileDownload ||
                         _requestType == UMC_WHCHttpRequestGet)) {
        _speedTimer = [NSTimer scheduledTimerWithTimeInterval:kUMCWHCDownloadSpeedDuring
                                                       target:self
                                                     selector:@selector(calculateNetworkSpeed)
                                                     userInfo:nil
                                                      repeats:YES];
        [self calculateNetworkSpeed];
    }
}

- (BOOL)handleResponseError:(NSURLResponse * )response {
    BOOL isError = NO;
    NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
    if(headerResponse.statusCode >= 400){
        isError = YES;
        self.requestStatus = UMC_WHCHttpRequestFinished;
        if (self.requestType != UMC_WHCHttpRequestFileDownload) {
            [self cancelledRequest];
            NSError * error = [NSError errorWithDomain:kUMCWHCDomain
                                                  code:UMC_WHCGeneralError
                                              userInfo:@{NSLocalizedDescriptionKey:
                                                             [NSString stringWithFormat:kUMCWHCErrorCode,
                                                              (long)headerResponse.statusCode]}];
            NSLog(@"UdeskSDK：%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.didFinishedBlock) {
                    self.didFinishedBlock(self, nil , error , NO);
                    self.didFinishedBlock = nil;
                }else if (self.delegate &&
                          [self.delegate respondsToSelector:@selector(WHCDownloadDidFinished:data:error:success:)]) {
                    if (headerResponse.statusCode == 404) {
                        [[UMC_WHC_HttpManager shared].failedUrls addObject: self.strUrl];
                    }
                    [self.delegate WHCDownloadDidFinished:(UMC_WHC_DownloadOperation *)self data:nil error:error success:NO];
                }
            });
        }
    }else {
        _responseDataLenght = headerResponse.expectedContentLength;
        [self startSpeedTimer];
    }
    return isError;
}

- (void)endRequest {
    self.didFinishedBlock = nil;
    self.progressBlock = nil;
    [self cancelledRequest];
}

- (void)cancelledRequest{
    if (_urlConnection) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
        _requestStatus = UMC_WHCHttpRequestFinished;
        [self willChangeValueForKey:@"isCancelled"];
        [self willChangeValueForKey:@"isFinished"];
        [_urlConnection cancel];
        _urlConnection = nil;
        [self didChangeValueForKey:@"isCancelled"];
        [self didChangeValueForKey:@"isFinished"];
        if (_requestType == UMC_WHCHttpRequestFileUpload ||
            _requestType == UMC_WHCHttpRequestFileDownload) {
            if (_speedTimer) {
                [_speedTimer invalidate];
                [_speedTimer fire];
                _speedTimer = nil;
            }
        }
    }
}

- (void)handleReqeustError:(NSError *)error code:(NSInteger)code {
    if(error == nil){
        error = [[NSError alloc]initWithDomain:kUMCWHCDomain
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:kUMCWHCInvainUrlError,self.strUrl]}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock (self, nil, error , NO);
            self.didFinishedBlock = nil;
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(WHCDownloadDidFinished:data:error:success:)]) {
            [self.delegate WHCDownloadDidFinished:(UMC_WHC_DownloadOperation *)self data:nil error:error success:NO];
        }
    });
    
}

@end
