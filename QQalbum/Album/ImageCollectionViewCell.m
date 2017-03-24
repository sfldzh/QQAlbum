//
//  ImageCollectionViewCell.m
//  QQalbum
//
//  Created by Dimoo on 16/6/12.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#define ButtonSize 20
@interface ImageCollectionViewCell()<CAAnimationDelegate>
@property (nonatomic,assign) BOOL isSelected;

@end

@implementation ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor lightGrayColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self addViews];
    }
    return self;
}

- (void)addViews{
    [self addSubview:self.imageView];
    [self.imageView addSubview:self.promptLabel];
    [self addSubview:self.flagImage];
    [self addSubview:self.selectButton];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)flagImage{
    if (!_flagImage) {
        _flagImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _flagImage.contentMode = UIViewContentModeScaleAspectFit;
        _flagImage.clipsToBounds = YES;
    }
    return _flagImage;
}

- (UILabel *)promptLabel{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _promptLabel.backgroundColor = [UIColor grayColor];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _promptLabel.layer.masksToBounds = YES;
        _promptLabel.text = @"松手发送";
        _promptLabel.hidden = YES;
    }
    return _promptLabel;
}

- (UIButton *)selectButton{
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _selectButton.layer.borderWidth = 1.5;
        _selectButton.layer.cornerRadius = ButtonSize/2.0;
        _selectButton.layer.masksToBounds = YES;
        [_selectButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)setContentImage:(UIImage *)contentImage{
    self.imageView.image = contentImage;
}

- (void)setButtonPosition:(CGFloat)buttonPosition{
    CGFloat startX = 0;
    CGFloat endX = self.bounds.size.width -(ButtonSize+10);
    
    CGFloat piont = 0;
    if (buttonPosition-ButtonSize-10 <= startX) {
        piont = startX;
    }else if(buttonPosition-ButtonSize-10 >= endX){
        piont = endX;
    }else{
        piont = buttonPosition-ButtonSize -10;
    }
    self.selectButton.frame = CGRectMake(piont, 5, ButtonSize, ButtonSize);
}

- (void)setIsFinish:(BOOL)isFinish{
    if (isFinish) {
        self.selectButton.frame = CGRectMake(self.bounds.size.width -(ButtonSize+10), 5, ButtonSize, ButtonSize);
    }else{
        self.selectButton.frame = CGRectMake(10, 5, ButtonSize, ButtonSize);
    }
    _isFinish = isFinish;
}



- (void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    self.isSelected = !(selectIndex==0);
    [self.selectButton setTitle:selectIndex == 0?@"":[NSString stringWithFormat:@"%@",@(selectIndex)] forState:UIControlStateNormal];
    _selectButton.backgroundColor = selectIndex == 0?[UIColor colorWithWhite:0.0 alpha:0.4]:[UIColor colorWithRed:102.0/255.0 green:206.0/255.0 blue:248.0/255.0 alpha:1.0];
}

- (void)selectButton:(UIButton*)button{
    if (self.isSelected) {
        if (self.selectedBlock) {
            self.isSelected = !self.isSelected;
            self.selectedBlock(self.indexPath,self.isSelected,self);
        }
    }else{
        BOOL canSelect;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(canSelect)]) {
            canSelect = [self.delegate canSelect];
        }
        if (canSelect) {
            self.isSelected = !self.isSelected;
            if (self.selectedBlock) {
                self.selectedBlock(self.indexPath,self.isSelected,self);
            }
        }
        [self selectAnimationWithButton:button];
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didClickSelectButton)]) {
        [self.delegate didClickSelectButton];
    }
}


/**
 TODO:选中动画

 @param button 按钮
 */
- (void)selectAnimationWithButton:(UIButton *)button{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    popAnimation.delegate = self;
    popAnimation.duration = 0.6;
    popAnimation.values = @[@(1.0),@(1.25),@(0.95),@(1.1),@(1.0)];
    popAnimation.keyTimes = @[@(0.0),@(0.25),@(0.5),@(0.75),@(1.0)];
    popAnimation.calculationMode = kCAAnimationLinear;
    [button.layer addAnimation:popAnimation forKey:@"popAnimation"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.imageView.superview == self) {
        self.imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        self.flagImage.frame = CGRectMake(5, self.bounds.size.height-20, 20, 15);
        self.promptLabel.frame = CGRectMake(self.imageView.frame.size.width/2-33, 5, 66, 20);
        self.promptLabel.layer.cornerRadius = self.promptLabel.frame.size.height/2;
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.selectButton.layer removeAnimationForKey:@"popAnimation"];
}

@end
