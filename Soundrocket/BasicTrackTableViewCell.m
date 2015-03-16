//
//  BasicTrackTableViewCell.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "BasicTrackTableViewCell.h"
#import "SRStylesheet.h"
#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <UIImageView+AFNetworking.h>
#import "Playlist.h"
@implementation BasicTrackTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setupUI];
    [self setupData];
    self.userNameLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.userNameLabel addTarget:self action:@selector(userButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)userButtonPressed:(id)sender {
    if([self.data  respondsToSelector:@selector(user)]){
        User * user = (User*)[self.data performSelector:@selector(user) withObject:nil];
        [self.delegate userButtonPressedWithUserID:user.id];
    }
}

-(void)setData:(id)data {
    _data = data;
    [self setupData];
}


-(void)setupData {
    if ([self.data isKindOfClass:[Track class]]) {
        [self setupCellWithTrack:(Track*)self.data];
    } else if([self.data isKindOfClass:[TrackRespost class]]) {
        [self setupCellWithRepost:(TrackRespost*)self.data];
    } else if([self.data isKindOfClass:[Playlist class]]){
        [self setupCellWithPlaylist:(Playlist*)self.data];
    } else if([self.data isKindOfClass:[PlaylistRespost class]]){
        [self setupCellWithPlaylistRepost:(PlaylistRespost*)self.data];
    }
}

#pragma mark - Setup Functions
-(void)setupCellWithTrack:(Track*)track {
    
    [self.userNameLabel setTitle:track.user.username forState:UIControlStateNormal];
    self.trackNameLabel.text = track.title;
    
    if (track.artwork_url) {
        NSString  *largeUrl = [track.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
        [self.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
    } else {
        [self.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
    }
    
    FAKIonIcons *playIcon = [FAKIonIcons playIconWithSize:10];
    NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.playback_count]];
    [playbackcount appendAttributedString:[playIcon attributedString]];
    
    FAKIonIcons *likeIcon = [FAKIonIcons heartIconWithSize:10];
    NSMutableAttributedString * likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.favoritings_count]];
    [likecount appendAttributedString:[likeIcon attributedString]];
    
    FAKIonIcons *commentIcon = [FAKIonIcons chatboxIconWithSize:10];
    NSMutableAttributedString * commentCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.comment_count]];
    [commentCount  appendAttributedString:[commentIcon attributedString]];
    
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:likecount];
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:commentCount];
    self.playbackCountLabel.attributedText = playbackcount;
    
    [self.repostedImageView setImage:[UIImage imageNamed:@"upload"]];
}

-(void)setupCellWithRepost:(TrackRespost*)trackRepost {
    FAKFontAwesome *retweetIcon = [FAKFontAwesome retweetIconWithSize:10];
    [self.respostedLabel setAttributedText:[retweetIcon attributedString]];
    self.respostedLabel.clipsToBounds = YES;
    self.respostedLabel.layer.cornerRadius = 10;
    self.respostedLabel.backgroundColor = [UIColor darkGrayColor];
    
    TrackRespost * track = (TrackRespost*)trackRepost;
    [self.userNameLabel setTitle:track.user.username forState:UIControlStateNormal];
    self.trackNameLabel.text = track.title;
    if (track.artwork_url) {
        NSString  *largeUrl = [track.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
        [self.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
    } else {
        [self.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
    }
    
    FAKIonIcons *starIcon = [FAKIonIcons playIconWithSize:10];
    NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.playback_count]];
    [playbackcount appendAttributedString:[starIcon attributedString]];
    
    
    FAKIonIcons *likeIcon = [FAKIonIcons heartIconWithSize:10];
    NSMutableAttributedString * likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.favoritings_count]];
    [likecount appendAttributedString:[likeIcon attributedString]];
    
    FAKIonIcons *commentIcon = [FAKIonIcons chatboxIconWithSize:10];
    NSMutableAttributedString * commentCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.comment_count]];
    [commentCount  appendAttributedString:[commentIcon attributedString]];
    
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:likecount];
    [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
    [playbackcount appendAttributedString:commentCount];
    self.playbackCountLabel.attributedText = playbackcount;
    
    
    [self.repostedImageView setImage:[UIImage imageNamed:@"repost"]];
}

-(void)setupCellWithPlaylist:(Playlist*)playlist {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self.userNameLabel setTitle:playlist.user.username forState:UIControlStateNormal];

    self.trackNameLabel.text = playlist.title;
    if (playlist.artwork_url) {
        NSString  *largeUrl = [playlist.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
        [self.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
    } else {
        [self.artworkImage setImageWithURL:[NSURL URLWithString:playlist.user.avatar_url] placeholderImage:nil];
    }
    
    // Private not private etc
    FAKFontAwesome * lockIcon = [FAKFontAwesome lockIconWithSize:10];
    NSMutableAttributedString * lockString = [[NSMutableAttributedString alloc]init];
    if ([playlist.sharing isEqualToString:@"private"]) {
        lockString = [[lockIcon attributedString]mutableCopy];
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ Tracks",playlist.track_count]]];
        
    } else {
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ Tracks",playlist.track_count]]];
    }
    self.playbackCountLabel.attributedText = lockString;
    [self.repostedImageView setImage:[UIImage imageNamed:@"list"]];
    self.firstLayerViewPlaylist.hidden = NO;
    self.secondLayerViewPlaylist.hidden = NO;
    
}

-(void)setupCellWithPlaylistRepost:(PlaylistRespost*)playlistRepost {
    
    FAKFontAwesome *retweetIcon = [FAKFontAwesome retweetIconWithSize:10];
    [self.respostedLabel setAttributedText:[retweetIcon attributedString]];
    self.respostedLabel.clipsToBounds = YES;
    self.respostedLabel.layer.cornerRadius = 10;
    self.respostedLabel.backgroundColor = [UIColor darkGrayColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self.userNameLabel setTitle:playlistRepost.user.username forState:UIControlStateNormal];

    self.trackNameLabel.text = playlistRepost.title;
    if (playlistRepost.artwork_url) {
        NSString  *largeUrl = [playlistRepost.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
        [self.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
    } else {
        [self.artworkImage setImageWithURL:[NSURL URLWithString:playlistRepost.user.avatar_url] placeholderImage:nil];
    }
    
    // Private not private etc
    FAKFontAwesome * lockIcon = [FAKFontAwesome lockIconWithSize:10];
    NSMutableAttributedString * lockString = [[NSMutableAttributedString alloc]init];
    if ([playlistRepost.sharing isEqualToString:@"private"]) {
        lockString = [[lockIcon attributedString]mutableCopy];
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ Tracks",playlistRepost.track_count]]];
        
    } else {
        [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ Tracks",playlistRepost.track_count]]];
    }
    self.playbackCountLabel.attributedText = lockString;
    
    [self.repostedImageView setImage:[UIImage imageNamed:@"repost"]];
    self.firstLayerViewPlaylist.hidden = NO;
    self.secondLayerViewPlaylist.hidden = NO;
}

-(void)setupUI {
    self.artworkImage.clipsToBounds = YES;
    self.artworkImage.layer.cornerRadius = 25;
    self.artworkImage.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.artworkImage.layer.borderWidth = 1.0;
    
    self.firstLayerViewPlaylist.clipsToBounds = YES;
    self.firstLayerViewPlaylist.layer.cornerRadius = 25;
    self.firstLayerViewPlaylist.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.firstLayerViewPlaylist.layer.borderWidth = 1.0;
    [self.firstLayerViewPlaylist setHidden:YES];
    
    self.secondLayerViewPlaylist.clipsToBounds = YES;
    self.secondLayerViewPlaylist.layer.cornerRadius = 25;
    self.secondLayerViewPlaylist.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.secondLayerViewPlaylist.layer.borderWidth = 1.0;
    [self.secondLayerViewPlaylist setHidden:YES];
    
    [self.userNameLabel setTitleColor:[SRStylesheet mainColor] forState:UIControlStateNormal];
}

-(void)prepareForReuse {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.artworkImage.image = nil;
    [self.userNameLabel setTitle:@"" forState:UIControlStateNormal];
    self.firstLayerViewPlaylist.hidden = YES;
    self.secondLayerViewPlaylist.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
    [self.respostedLabel setText:@""];
    [self.respostedLabel setBackgroundColor:[UIColor clearColor]];
}

@end
