//
//  UIView+ZFViewProperty.h
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <UIKit/UIKit.h>

@interface UIView (ZFViewProperty)

- (CGFloat)y;

- (CGFloat)centerY;

- (CGFloat)centerX;

- (CGFloat)maxY;

- (CGFloat)x;

- (CGFloat)maxX;

- (CGPoint)xy;

- (CGFloat)width;

- (CGFloat)height;

- (CGSize)size;

- (void)setMaxY:(CGFloat)maxY;

- (void)setMaxX:(CGFloat)maxX;

- (void)setY:(CGFloat)Y;

- (void)setX:(CGFloat)X;

- (void)setCenterX:(CGFloat)centerX;

- (void)setCenterY:(CGFloat)centerY;

- (void)setXy:(CGPoint)point;

- (void)setSize:(CGSize)size;

- (void)setWidth:(CGFloat)width;

- (void)setHeight:(CGFloat)height;

@end
