//
//  HPTextView.h
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
	// UITextAlignment is deprecated in iOS 6.0+, use NSTextAlignment instead.
	// Reference: https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
	#define NSTextAlignment UITextAlignment
#endif

@class UMCHPGrowingTextView;
@class UMCHPTextViewInternal;

@protocol HPGrowingTextViewDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(UMCHPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(UMCHPGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(UMCHPGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(UMCHPGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(UMCHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(UMCHPGrowingTextView *)growingTextView;

- (void)growingTextView:(UMCHPGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(UMCHPGrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(UMCHPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(UMCHPGrowingTextView *)growingTextView;
@end

@interface UMCHPGrowingTextView : UIView <UITextViewDelegate> {
	UMCHPTextViewInternal *internalTextView;
	
	int minHeight;
	int maxHeight;
	
	//class properties
	int maxNumberOfLines;
	int minNumberOfLines;
	
	BOOL animateHeightChange;
    NSTimeInterval animationDuration;
	
	//uitextview properties
	NSObject <HPGrowingTextViewDelegate> *__unsafe_unretained delegate;
	NSTextAlignment textAlignment;
	NSRange selectedRange;
	BOOL editable;
	UIDataDetectorTypes dataDetectorTypes;
	UIReturnKeyType returnKeyType;
	UIKeyboardType keyboardType;
    
    UIEdgeInsets contentInset;
}

//real class properties
@property int maxNumberOfLines;
@property int minNumberOfLines;
@property (nonatomic) int maxHeight;
@property (nonatomic) int minHeight;
@property BOOL animateHeightChange;
@property NSTimeInterval animationDuration;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UITextView *internalTextView;	


//uitextview properties
@property(unsafe_unretained) NSObject<HPGrowingTextViewDelegate> *delegate;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic) NSTextAlignment textAlignment;    // default is NSTextAlignmentLeft
@property(nonatomic) NSRange selectedRange;            // only ranges of length 0 are supported
@property(nonatomic,getter=isEditable) BOOL editable;
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (assign) UIEdgeInsets contentInset;
@property (nonatomic) BOOL isScrollable;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
#endif

//uitextview methods
//need others? use .internalTextView
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

// call to force a height change (e.g. after you change max/min lines)
- (void)refreshHeight;

@end
