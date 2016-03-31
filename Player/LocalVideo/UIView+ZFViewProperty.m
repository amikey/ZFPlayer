//
//  UIView+ZFViewProperty.m
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


#import "UIView+ZFViewProperty.h"

@implementation UIView (ZFViewProperty)

- (CGFloat)y{
    return CGRectGetMinY(self.frame);
}

- (CGFloat)maxY{
    return self.y + self.height;
}

- (void)setMaxY:(CGFloat)maxY{
    CGFloat  y = maxY - self.height;
    self.y = y;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint  center = self.center;
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint  center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)x{
    return CGRectGetMinX(self.frame);
}

- (CGFloat)maxX{
    return self.x + self.width;
}

- (void)setMaxX:(CGFloat)maxX{
    CGFloat  x = maxX - self.width;
    self.x = x;
}

- (CGPoint)xy{
    return CGPointMake(self.x, self.y);
}

- (CGFloat)width{
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height{
    return CGRectGetHeight(self.frame);
}

- (CGSize)size{
    return CGSizeMake(self.width, self.height);
}

- (void)setY:(CGFloat)Y{
    CGRect   rc = self.frame;
    rc.origin.y = Y;
    self.frame = rc;
}

- (void)setX:(CGFloat)X{
    CGRect   rc = self.frame;
    rc.origin.x = X;
    self.frame = rc;
}

- (void)setXy:(CGPoint)point{
    CGRect   rc = self.frame;
    rc.origin = point;
    self.frame = rc;
}

- (void)setSize:(CGSize)size{
    CGRect   rc = self.frame;
    rc.size = size;
    self.frame = rc;
}

- (void)setWidth:(CGFloat)width{
    CGRect   rc = self.frame;
    rc.size.width = width;
    self.frame = rc;
}

- (void)setHeight:(CGFloat)height{
    CGRect   rc = self.frame;
    rc.size.height = height;
    self.frame = rc;
}
@end
