//
//  ViewController.h
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(UISlider) NSArray *ampSliders;

- (IBAction)ampChanged:(UISlider *)sender;

@end
