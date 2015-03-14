//
//  AboutTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKFontAwesome.h>
#import "AboutTableViewController.h"
#import <RESideMenu.h>
#import <FAKIonIcons.h>
#import "SRStylesheet.h"
@interface AboutTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *poweredBySoundcloudLabel;

@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.poweredByLabel.textColor = [SRStylesheet whiteColor];
    NSAttributedString *attributedString =
    [[NSAttributedString alloc]
     initWithString:@"Soundrocket"
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:45],
       NSForegroundColorAttributeName : [SRStylesheet whiteColor],
       NSKernAttributeName : @(-4.0f)
       }];
    
    self.soundrocketNameLabel.attributedText = attributedString;
    [self.navigationItem setTitle:@"About"];
    [self.logoImageView.layer setMinificationFilter:kCAFilterTrilinear];
    NSMutableAttributedString * websiteIcon = [[[FAKIonIcons earthIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * contactIcon = [[[FAKIonIcons ios7EmailIconWithSize:14]attributedString]mutableCopy];
    NSMutableAttributedString * libariesIcon = [[[FAKFontAwesome cubesIconWithSize:14]attributedString]mutableCopy];
    
     NSMutableAttributedString * starIcon = [[[FAKIonIcons ios7StarIconWithSize:14]attributedString]mutableCopy];

    [websiteIcon appendAttributedString:[[NSAttributedString alloc]initWithString:@"   My website"]];
    [contactIcon appendAttributedString:[[NSAttributedString alloc]initWithString:@"   Contact me"]];
    [libariesIcon appendAttributedString:[[NSAttributedString alloc]initWithString:@"   Libaries i used"]];
    [starIcon appendAttributedString:[[NSAttributedString alloc]initWithString:@"   Rate this App"]];

    self.webSiteLabel.attributedText =  websiteIcon;
    self.contactLabel.attributedText =  contactIcon;
    self.libariesLabel.attributedText =  libariesIcon;
    self.rateThisAppLabel.attributedText = starIcon;
    
    
    // Build Number
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    self.versionLabel.text = versionBuildString;
    [self setshowMenuButton];
    // App name
    //self.appNameLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    [self setHelpButton];
}

-(void)setHelpButton {
    FAKIonIcons *cogIcon = [FAKIonIcons helpCircledIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showHelp)];
}

-(void)showHelp {
    [self performSegueWithIdentifier:@"showHelp" sender:nil];
}
-(void)showMenu {
    [self presentLeftMenuViewController:nil];
    
}
- (IBAction)showMenuButtonPressed:(id)sender {
    [self showMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%li",(long)indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [self rateThisAppPressed];
    } else if (indexPath.row == 2) {
        [self websitePressed];
    } else if(indexPath.row == 3){
        [self feedbackPressed];
    }
}

-(void)rateThisAppPressed {
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id957116901"];
    [[UIApplication sharedApplication]openURL:url];
}
-(void)feedbackPressed {
    NSURL * url = [NSURL URLWithString:@"mailto:sebastian.boldt.1989@googlemail.com"];
    [[UIApplication sharedApplication]openURL:url];
    
}

-(void)websitePressed {
    NSURL * url = [NSURL URLWithString:@"http://sebastianboldt.com"];
    [[UIApplication sharedApplication]openURL:url];
}
@end
