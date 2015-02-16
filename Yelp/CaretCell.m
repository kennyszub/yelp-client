//
//  CaretCell.m
//  Yelp
//
//  Created by Ken Szubzda on 2/15/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "CaretCell.h"

@interface CaretCell ()
@property (weak, nonatomic) IBOutlet UIImageView *caretView;

@end

@implementation CaretCell

- (void)awakeFromNib {
    // Initialization code
    self.caretView.image = [UIImage imageNamed:@"down_arrow"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
