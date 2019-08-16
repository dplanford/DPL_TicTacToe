//
//  ViewController.h
//  DPL_TicTacToe
//
//  Created by Douglas Lanford on 6/24/17.
//  Copyright © 2017 Douglas Lanford. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TicTacToeManager.h"


@interface GameBoardViewController : UIViewController<TicTacToeManagerDelegate>

@property (nonatomic, assign) TicTacToePlayState playState;
@property (nonatomic, assign) float difficulty;
@property (nonatomic, assign) BOOL computerStarts;

@end

