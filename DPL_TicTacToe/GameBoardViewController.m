//
//  ViewController.m
//  DPL_TicTacToe
//
//  Created by Douglas Lanford on 6/24/17.
//  Copyright © 2017 Douglas Lanford. All rights reserved.
//

#import "GameBoardViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "TicTacToeManager.h"


#pragma mark ====================================
#pragma mark - Local Properties and variables

@interface GameBoardViewController () {

    AVAudioPlayer* _placeOnBoardXAudioPlayer;
    AVAudioPlayer* _placeOnBoardOAudioPlayer;
    AVAudioPlayer* _gameWinAudioPlayer;
    AVAudioPlayer* _gameDrawAudioPlayer;
}

@property (nonatomic, weak) IBOutlet UILabel* currentPlayerLabel;
@property (nonatomic, weak) IBOutlet UILabel* instructionLabel;
@property (nonatomic, weak) IBOutlet UILabel* gameStatusLabel;

@property (nonatomic, weak) IBOutlet UIButton* topLeftButton;
@property (nonatomic, weak) IBOutlet UIButton* topMidButton;
@property (nonatomic, weak) IBOutlet UIButton* topRightButton;
@property (nonatomic, weak) IBOutlet UIButton* midLeftButton;
@property (nonatomic, weak) IBOutlet UIButton* midMidButton;
@property (nonatomic, weak) IBOutlet UIButton* midRightButton;
@property (nonatomic, weak) IBOutlet UIButton* bottomLeftButton;
@property (nonatomic, weak) IBOutlet UIButton* bottomMidButton;
@property (nonatomic, weak) IBOutlet UIButton* bottomRightButton;

@property (nonatomic, weak) IBOutlet UIButton* doneButton;

@property (nonatomic, retain) TicTacToeManager* ticTacToeManager;

@end


#pragma mark ===========================================
#pragma mark - GameBoardViewController implementation

@implementation GameBoardViewController

#pragma mark ===========================================
#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    self.doneButton.layer.cornerRadius = 20.0f;
    self.currentPlayerLabel.text = @"Player X";
    self.gameStatusLabel.text = @"";

    // Create the game manager.
    self.ticTacToeManager = [[TicTacToeManager alloc] initWithDelegate:self];

    // Setup sound effects.
    NSString* path = [NSString stringWithFormat:@"%@/zapsplat_cartoon_pop_small_lid.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL* soundUrl = [NSURL fileURLWithPath:path];
    _placeOnBoardXAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];

    path = [NSString stringWithFormat:@"%@/dustyroom_cartoon_bubble_pop.mp3", [[NSBundle mainBundle] resourcePath]];
    soundUrl = [NSURL fileURLWithPath:path];
    _placeOnBoardOAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];

    path = [NSString stringWithFormat:@"%@/arcade_game_tone_003.mp3", [[NSBundle mainBundle] resourcePath]];
    soundUrl = [NSURL fileURLWithPath:path];
    _gameWinAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];

    path = [NSString stringWithFormat:@"%@/arcade_game_tone_002.mp3", [[NSBundle mainBundle] resourcePath]];
    soundUrl = [NSURL fileURLWithPath:path];
    _gameDrawAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self gameContinuesWithNextState:TTTC_X];
}



#pragma mark ===========================================
#pragma mark - IBActions

- (IBAction)doneButtonSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)cellButtonSelected:(id)sender {
    TicTacToeCell* cell = [self.ticTacToeManager getCellForButton:(UIButton*)sender];
    if (cell == nil) {
        return;
    }

    [self playPlaceOnBoardSound];

    [self.ticTacToeManager fillCellWithState:self.ticTacToeManager.currentPlayer x:cell.posX y:cell.posY];
}


#pragma mark ===========================================
#pragma mark - TicTacToeManagerDelegate methods

- (void)gameWinWithState:(TicTacToeCellState)state {
    self.currentPlayerLabel.text = @"";
    self.instructionLabel.text = @"";
    self.gameStatusLabel.text = [NSString stringWithFormat:@"Player %@ Wins!", (state == TTTC_X ? @"X" : @"O")];
    [_gameWinAudioPlayer play];
}


- (void)gameDraw {
    self.currentPlayerLabel.text = @"";
    self.instructionLabel.text = @"";
    self.gameStatusLabel.text = @"Draw, No Winner...";
    [_gameDrawAudioPlayer play];
}


- (void)gameContinuesWithNextState:(TicTacToeCellState)state {
    self.currentPlayerLabel.text = [NSString stringWithFormat:@"Player %@", (state == TTTC_X ? @"X" : @"O")];
    self.instructionLabel.text = @"Tap a square...";

    if (self.playState == TTTM_1_PLAYER) {
        if (self.computerStarts) {
            if (self.ticTacToeManager.currentPlayer == TTTC_X) {
                [self doComputerSelectInASec];
                return;
            }
        }
        else {
            if (self.ticTacToeManager.currentPlayer == TTTC_O) {
                [self doComputerSelectInASec];
                return;
            }
        }
    }
    else if (self.playState == TTTM_NO_PLAYER) {
        [self doComputerSelectInASec];
        return;
    }

    // a human player is selecting... enable all empty cells.
    for (TicTacToeCell* cell in self.ticTacToeManager.emptyCells) {
        cell.button.enabled = YES;
    }
}


- (UIButton*)getButtonForPositionX:(NSUInteger)posX y:(NSUInteger)posY {
    switch (posX) {
    case 0:
            switch (posY) {
                case 0:
                    return self.topLeftButton;
                case 1:
                    return self.midLeftButton;
                case 2:
                    return self.bottomLeftButton;
                default:
                    return nil;
            }
        case 1:
            switch (posY) {
                case 0:
                    return self.topMidButton;
                case 1:
                    return self.midMidButton;
                case 2:
                    return self.bottomMidButton;
            }
        case 2:
            switch (posY) {
                case 0:
                    return self.topRightButton;
                case 1:
                    return self.midRightButton;
                case 2:
                    return self.bottomRightButton;
            }
    }
    return nil;
}


#pragma mark ===========================================
#pragma mark - Private methods

- (void)doComputerSelectInASec {
    self.instructionLabel.text = @"(Computer)";
    for (TicTacToeCell* cell in self.ticTacToeManager.emptyCells) {
        // disable remaining cells while the computer is "deciding".
        cell.button.enabled = NO;
    }

    // wait for a second to simulate the computer thinking.
    [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:NO block:
     ^(NSTimer * _Nonnull timer) {
         [self playPlaceOnBoardSound];

         dispatch_async(dispatch_get_main_queue(), ^{
             [self.ticTacToeManager doComputerSelectWithDifficulty:self.difficulty];
         });
     }];
}

- (void)playPlaceOnBoardSound {
    if (self.ticTacToeManager.currentPlayer == TTTC_X) {
        [_placeOnBoardXAudioPlayer play];
    } else {
        [_placeOnBoardOAudioPlayer play];
    }
}

@end
