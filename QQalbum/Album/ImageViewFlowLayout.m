//
//  ImageViewFlowLayout.m
//  QQalbum
//
//  Created by Dimoo on 16/6/13.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "ImageViewFlowLayout.h"
static NSString * const CollectionViewKeyPath = @"collectionView";

@interface ImageViewFlowLayout ()<UIGestureRecognizerDelegate>{
    NSIndexPath *selectedIndexPath;
    BOOL isCanSend;
}
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end
@implementation ImageViewFlowLayout

- (void)dealloc {
    [self removeObserver:self forKeyPath:CollectionViewKeyPath];
    [self.panGestureRecognizer removeObserver:self forKeyPath:@"delegate"];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    [self addObserver:self forKeyPath:CollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setupCollectionView {
    if(_panGestureRecognizer == nil){
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_panGestureRecognizer addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:nil];
        _panGestureRecognizer.delegate = self;
    }
    for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:_panGestureRecognizer];
        }
    }
    
    [self.collectionView addGestureRecognizer:_panGestureRecognizer];
}


- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture{
    if(self.collectionView.allowsSelection == NO){
        return;
    }
    CGPoint currentPoint = [gesture locationInView:[gesture view]];
//    NSLog(@"%f",currentPoint.y);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:currentPoint];
            if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(cellWillMove:)]) {
                [self.sendDelegate cellWillMove:indexPath];
            }
            selectedIndexPath = indexPath;
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(cellDidChange:)]) {
                [self.sendDelegate cellDidChange:[gesture translationInView:[gesture view]].y];
            }
            
            if ([gesture translationInView:[gesture view]].y<0) {
                if (fabs([gesture translationInView:[gesture view]].y) < self.collectionView.frame.size.height/2) {
                    if (!isCanSend) {;
                        if (self.sendDelegate&&[self.sendDelegate respondsToSelector:@selector(canSendImage:)]) {
                            [self.sendDelegate canSendImage:isCanSend];
                        }
                        isCanSend = YES;
                    }
                }else{
                    if (isCanSend) {
                        if (self.sendDelegate&&[self.sendDelegate respondsToSelector:@selector(canSendImage:)]) {
                            [self.sendDelegate canSendImage:isCanSend];
                        }
                        isCanSend = NO;
                    }
                }
            }
            
            if (!selectedIndexPath) return;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            
            if ([gesture translationInView:[gesture view]].y>0) {
                if (self.sendDelegate&&[self.sendDelegate respondsToSelector:@selector(cancelMoveCell:)]) {
                    [self.sendDelegate cancelMoveCell:gesture];
                }
            }else{
                if (fabs([gesture translationInView:[gesture view]].y) < self.collectionView.frame.size.height/2) {
                    if (self.sendDelegate&&[self.sendDelegate respondsToSelector:@selector(cancelMoveCell:)]) {
                        [self.sendDelegate cancelMoveCell:gesture];
                    }
                }else{
                    if (self.sendDelegate && [self.sendDelegate respondsToSelector:@selector(sendImage:panGestureRecognizer:)]) {
                        [self.sendDelegate sendImage:selectedIndexPath panGestureRecognizer:gesture];
                    }
                }
            }
            selectedIndexPath = nil;
            break;
        }
            
        default:
            break;
    }

}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint velocity = [self.panGestureRecognizer velocityInView:[self.panGestureRecognizer view]];
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical && fabs(velocity.x) > fabs(velocity.y)) {
            return YES;
        }else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && fabs(velocity.y) > fabs(velocity.x)){
            return YES;
        }
    }
    return NO;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray *attributesInRect = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    if (selectedIndexPath) {
        __block NSInteger selectedAttributesIndex = NSNotFound;
        
        [attributesInRect enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
            if ([attributes.indexPath isEqual:selectedIndexPath]) {
                selectedAttributesIndex = idx;
                *stop = YES;
            }
        }];
        
        if (selectedAttributesIndex != NSNotFound) {
            UICollectionViewLayoutAttributes *selectedAttributes = [self layoutAttributesForItemAtIndexPath:selectedIndexPath];
            [attributesInRect replaceObjectAtIndex:selectedAttributesIndex withObject:selectedAttributes];
        }
    }
    
    return attributesInRect;
}

#pragma mark - Key-Value Observing methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:CollectionViewKeyPath]) {
        if (self.collectionView != nil) {
            [self setupCollectionView];
        }
    }else if ([keyPath isEqualToString:@"delegate"] && [object isEqual:self.panGestureRecognizer]){
        NSAssert([[change objectForKey:NSKeyValueChangeNewKey] isEqual:self], @"The delegate of the PanGestureRecogniser must be the layout object");
    }
}

@end
