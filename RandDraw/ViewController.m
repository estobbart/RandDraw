//
//  ViewController.m
//  RandDraw
//
//  Created by Eric Stobbart on 1/16/17.
//  Copyright © 2017 Eric Stobbart. All rights reserved.
//

#import "ViewController.h"


@interface RandDrawView : UIView

@end

@implementation RandDrawView {
  NSValue *_lastKnownPoint;
}

- (CGFloat)_randYPosition {
  return ( (float) arc4random() / 0x100000000 ) * [[UIScreen mainScreen] bounds].size.height;
}

- (CGFloat)_randXPosition {
  return ( (float) arc4random() / 0x100000000 ) * [[UIScreen mainScreen] bounds].size.width;
}

- (NSArray<NSValue *> *)_pointPair {
  static NSMutableArray *result = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    if (!_lastKnownPoint) {
      _lastKnownPoint = [NSValue valueWithCGPoint:CGPointMake([self _randXPosition],
                                                              [self _randYPosition])];
    }
    result = [[NSMutableArray alloc] initWithObjects:[_lastKnownPoint copy], nil];
  });
  if (result.count == 2) {
    [result removeObjectAtIndex:0];
  }
  NSValue *_nextPoint = [NSValue valueWithCGPoint:CGPointMake([self _randXPosition],
                                                              [self _randYPosition])];
  [result addObject:_nextPoint];
  _lastKnownPoint = _nextPoint;
  return result;
  
}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextClearRect(ctx, rect);
  CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
  NSArray <NSValue *> *_points = [self _pointPair];
  CGPoint first = _points[0].CGPointValue;
  CGPoint second = _points[1].CGPointValue;
  CGContextMoveToPoint(ctx, first.x, first.y);
  CGContextAddLineToPoint(ctx, second.x, second.y);
  CGContextStrokePath(ctx);
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView {
  self.view = [[RandDrawView alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  typedef void(^recursiveBlock)(void);
  __weak __block recursiveBlock weakBlock;
  recursiveBlock block = ^{
    [self.view setNeedsDisplay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(250.0f * NSEC_PER_MSEC)),
                   dispatch_get_main_queue(),
                   weakBlock);
  };
  weakBlock = block;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(250.0f * NSEC_PER_MSEC)),
                 dispatch_get_main_queue(),
                 block);
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


@end
