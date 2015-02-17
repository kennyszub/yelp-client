//
//  BusinessDetailsController.m
//  Yelp
//
//  Created by Ken Szubzda on 2/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "BusinessDetailsController.h"
#import "UIImageView+AFNetworking.h"

@interface BusinessDetailsController ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *sampleReviewLabel;
@end

@implementation BusinessDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // fix autolayout bug that doesn't wrap label
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    
    // round the corners of the thumbnail
    self.thumbImageView.layer.cornerRadius = 3;
    self.thumbImageView.clipsToBounds = YES;
    self.title = self.business.name;
    [self setBusinessViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBusinessViews {
    self.business.imageUrl = [self.business.imageUrl stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"o.jpg"];

    [self.thumbImageView setImageWithURL:[NSURL URLWithString:self.business.imageUrl]];
    self.nameLabel.text = self.business.name;
    [self.ratingImageView setImageWithURL:[NSURL URLWithString:self.business.ratingImageUrl]];
    self.ratingLabel.text = [NSString stringWithFormat:@"%ld Reviews", self.business.numReviews];
    self.addressLabel.text = self.business.address;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.business.distance];
    self.categoryLabel.text = self.business.categories;
    self.sampleReviewLabel.text = self.business.sampleReview;
}


@end
