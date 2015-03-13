//
//  TutorialViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 28.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "TutorialViewController.h"
#import <FAKIonIcons.h>
@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setshowMenuButton];
    [self setupScrollView];
    // Do any additional setup after loading the view.
}


-(void)setupScrollView{
    [self.topScrollView setPagingEnabled:YES];
    [self.topScrollView setUserInteractionEnabled:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Packe einen ScrollView in die Ansicht
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect frame = CGRectMake(0, 0, self.topScrollView.bounds.size.width, self.topScrollView.bounds.size.height);
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"page1"]];
    imageView.frame = frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.topScrollView addSubview:imageView];
    
    // Do any additional setup after loading the view, typically from a nib.
    CGRect frame2 = CGRectMake(self.topScrollView.bounds.size.width, 0, self.topScrollView.bounds.size.width, self.topScrollView.bounds.size.height);
    UIImageView * imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"page2"]];
    imageView2.frame = frame2;
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.topScrollView addSubview:imageView2];
    [self.topScrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.topScrollView setContentSize:CGSizeMake(self.topScrollView.frame.size.width *2, self.topScrollView.frame.size.height)];
    

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setshowMenuButton {
    FAKIonIcons *cogIcon = [FAKIonIcons closeRoundIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(close)];
}

-(void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
