//
//  ImageCollectionViewCell.m
//  QQalbum
//
//  Created by Dimoo on 16/6/12.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#define ButtonSize 20
@interface ImageCollectionViewCell()

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
        [_selectButton setImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateSelected];
        [_selectButton setImage:[UIImage imageNamed:@"CheckmarkUnselected"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)setContentImage:(UIImage *)contentImage{
    self.imageView.image = contentImage;
}

- (void)setButtonPosition:(CGFloat)buttonPosition{
//    NSLog(@"buttonPosition:%f\n",buttonPosition);
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

- (void)setIsSelected:(BOOL)isSelected{
    self.selectButton.selected = isSelected;
}

- (void)selectButton:(UIButton*)button{
    if (button.selected) {
        button.selected = !button.selected;
        if (self.selectedBlock) {
            self.selectedBlock(self.indexPath,button.selected,self);
        }
    }else{
        BOOL canSelect;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(canSelect)]) {
            canSelect = [self.delegate canSelect];
        }
        if (canSelect) {
            button.selected = !button.selected;
            if (self.selectedBlock) {
                self.selectedBlock(self.indexPath,button.selected,self);
            }
        }
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didClickSelectButton)]) {
        [self.delegate didClickSelectButton];
    }
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



@end
