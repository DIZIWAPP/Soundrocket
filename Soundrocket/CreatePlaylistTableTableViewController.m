//
//  CreatePlaylistTableTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "CreatePlaylistTableTableViewController.h"
#import <MBProgressHUD.h>
#import "SoundtraceClient.h"
#import <SVProgressHUD.h>
#import "CredentialStore.h"
@interface CreatePlaylistTableTableViewController ()
@property(nonatomic,strong) CredentialStore * store;
@end

@implementation CreatePlaylistTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.store = [[CredentialStore alloc]init];

    
    if (self.playlist) {
        self.nameOfPlaylistTextField.text = self.playlist.title;
        if ([self.playlist.sharing isEqualToString:@"public"]) {
            [self.sharingSwitch setOn:YES];
        } else {
            [self.sharingSwitch setOn:NO];
        }
        [self.createPlaylistButton setTitle:@"Update Playlist" forState:UIControlStateNormal];
    } else {
        UIBarButtonItem * cancelIcon = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
        self.navigationItem.leftBarButtonItem = cancelIcon;
        [self.createPlaylistButton setTitle:@"Create Playlist" forState:UIControlStateNormal];
    }
}

-(void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Creates a completly new Playlist
 *
 *  @param name   name of Playlist
 *  @param public public or private ?
 */
-(void)createPlaylistWithName:(NSString*)name  andSharingoption:(BOOL)public{

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.nameOfPlaylistTextField resignFirstResponder];
    [SVProgressHUD showWithStatus:@"Creating playlist"];
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    NSMutableDictionary * playlist = [[NSMutableDictionary alloc]init];
    [playlist setObject:name forKey:@"title"];

    if (public) {
        [playlist setObject:@"public" forKey:@"sharing"];
    } else {
        [playlist setObject:@"private" forKey:@"sharing"];

    }
    
    [paramters setObject:playlist forKey:@"playlist"];
    [[SoundtraceClient sharedClient] POST:@"/playlists" parameters:paramters
     
     
     success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
         [self dismissViewControllerAnimated:YES completion:^(){
             [self.createPlaylistDelegate playlistCreated];
             [SVProgressHUD showSuccessWithStatus:@"Created Playlist"];

         }];
     }
     
        failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
         [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
         
     }];
}
/**
 *  Updates a Playlist
 *
 *  @param name   name of Playlist
 *  @param public public or private
 */
-(void)updatePlaylistWithName:(NSString*)name  andSharingoption:(BOOL)public{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self.nameOfPlaylistTextField resignFirstResponder];
    [SVProgressHUD showWithStatus:@"Updating playlist"];
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    NSMutableDictionary * playlist = [[NSMutableDictionary alloc]init];
    [playlist setObject:name forKey:@"title"];
    
    if (public) {
        [playlist setObject:@"public" forKey:@"sharing"];
    } else {
        [playlist setObject:@"private" forKey:@"sharing"];
        
    }
    
    [paramters setObject:playlist forKey:@"playlist"];
    [[SoundtraceClient sharedClient] PUT:[NSString stringWithFormat:@"/playlists/%@",self.playlist.id] parameters:paramters
     
     
     success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
         [self.navigationController popViewControllerAnimated:YES];
         [SVProgressHUD showSuccessWithStatus:@"Updated Playlist"];
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
         [[UIApplication sharedApplication] endIgnoringInteractionEvents];

     }];
}

- (IBAction)createPlaylistButtonPressed:(id)sender {
    if (self.playlist) {
        [self updatePlaylistWithName:self.nameOfPlaylistTextField.text andSharingoption:self.sharingSwitch.on];
    } else {
        [self createPlaylistWithName:self.nameOfPlaylistTextField.text andSharingoption:self.sharingSwitch.on];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.playlist) {
        return @"Update Playlist";
    } else {
        return @"Create Playlist";
    }
}
@end
