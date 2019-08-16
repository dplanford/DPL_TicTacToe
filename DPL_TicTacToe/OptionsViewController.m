//
//  OptionsViewController.m
//  DPL_TicTacToe
//
//  Created by Douglas Lanford on 6/24/17.
//  Copyright © 2017 Douglas Lanford. All rights reserved.
//

#import "OptionsViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "GameBoardViewController.h"


#pragma mark ===========================================
#pragma mark - Local Properties and variables

@interface OptionsViewController () {

    AVAudioPlayer* _selectGameTypeAudioPlayer;
    AVAudioPlayer* _switchAudioPlayer;
}

@property (nonatomic, weak) IBOutlet UIButton* onePlayerButton;
@property (nonatomic, weak) IBOutlet UIButton* twoPlayersButton;
@property (nonatomic, weak) IBOutlet UIButton* computerPlaysItselfButton;
@property (nonatomic, weak) IBOutlet UISlider* computerDifficultySlider;
@property (nonatomic, weak) IBOutlet UISwitch* computerGoesFirstSwitch;

@end


#pragma mark ===========================================
#pragma mark - OptionsViewController implementation

@implementation OptionsViewController

#pragma mark ===========================================
#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    self.onePlayerButton.layer.cornerRadius = 20.0f;
    self.twoPlayersButton.layer.cornerRadius = 20.0f;
    self.computerPlaysItselfButton.layer.cornerRadius = 20.0f;

    // Setup sound effects.
    NSString* path = [NSString stringWithFormat:@"%@/multimedia_button_click_006.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL* soundUrl = [NSURL fileURLWithPath:path];
    _selectGameTypeAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];

    path = [NSString stringWithFormat:@"%@/human_finger_click.mp3", [[NSBundle mainBundle] resourcePath]];
    soundUrl = [NSURL fileURLWithPath:path];
    _switchAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
}


#pragma mark ===========================================
#pragma mark - IBActions

- (IBAction)onePlayerSelected:(id)sender {
    [_selectGameTypeAudioPlayer play];

    GameBoardViewController *gameBoardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameBoardViewController"];
    gameBoardViewController.difficulty = self.computerDifficultySlider.value;
    gameBoardViewController.computerStarts = self.computerGoesFirstSwitch.isOn;
    gameBoardViewController.playState = TTTM_1_PLAYER;
    [self presentViewController:gameBoardViewController animated:YES completion:nil];
}

- (IBAction)twoPlayersSelected:(id)sender {
    [_selectGameTypeAudioPlayer play];

    GameBoardViewController *gameBoardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameBoardViewController"];
    gameBoardViewController.playState = TTTM_2_PLAYER;
    [self presentViewController:gameBoardViewController animated:YES completion:nil];
}

- (IBAction)computerPlaysItselfSelected:(id)sender {
    [_selectGameTypeAudioPlayer play];

    GameBoardViewController *gameBoardViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameBoardViewController"];
    gameBoardViewController.difficulty = self.computerDifficultySlider.value;
    gameBoardViewController.playState = TTTM_NO_PLAYER;
    [self presentViewController:gameBoardViewController animated:YES completion:nil];
}

- (IBAction)computerGoesFirstChanged:(id)sender {
    [_switchAudioPlayer play];
}

@end
