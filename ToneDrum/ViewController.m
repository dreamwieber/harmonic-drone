//
//  ViewController.m
//  ToneDrum
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "ViewController.h"
#import <TheAmazingAudioEngine.h>
#import "TDHarmonicsGenerator.h"

@interface ViewController ()

@property (nonatomic, strong) AEAudioController *audioController; // The Amazing Audio Engine
@property (nonatomic, strong) TDHarmonicsGenerator *harmonicsGenerator;
@property (nonatomic, strong) AEBlockChannel *sineChannel;
@property (nonatomic, strong) NSArray *ratioAmplitudePairs;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ratioAmplitudePairs = @[ @{@1.075 : @.16}, @{@2 : @1.0}, @{@3 : @.2076}, @{@4.025 : @.5254}, @{@5.075 : @.1525}];
    
    self.harmonicsGenerator = [TDHarmonicsGenerator harmonicsGeneratorWithBaseFrequency:60 ratioAmplitudePairs:self.ratioAmplitudePairs];
                               

    AudioStreamBasicDescription audioFormat = [AEAudioController nonInterleavedFloatStereoAudioDescription];

    // Setup the Amazing Audio Engine:
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:audioFormat];
    
    __weak ViewController *weakSelf = self;
    AEBlockChannel *sineChannel = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        
        ViewController *strongSelf = weakSelf;
        
        UInt32 numberOfBuffers = audio->mNumberBuffers;
        
        // copy the sine wave from the scratch buffer to the output buffers
        for (int i = 0; i < numberOfBuffers; i++) {
            audio->mBuffers[i].mDataByteSize = frames * sizeof(float);
            
            float *output = (float *)audio->mBuffers[i].mData;
            
            if (strongSelf->_harmonicsGenerator->_processBlock) {
                strongSelf->_harmonicsGenerator->_processBlock(time, frames, output);
            }
            
        }
    }];
    
    [sineChannel setVolume:.25];
    
    // Add the channel to the audio controller
    [self.audioController addChannels:@[sineChannel]];
    
    // Hold onto the noiseChannel
    self.sineChannel = sineChannel;
    
    // Turn on the audio controller
    NSError *error = NULL;
    [self.audioController start:&error];
    
    if (error) {
        NSLog(@"There was an error starting the controller: %@", error);
    }
    
    int index = 0;
    for (UISlider *ampSlider in self.ampSliders) {
        if (index < self.ratioAmplitudePairs.count) {
            NSDictionary *ratioAmpPair = self.ratioAmplitudePairs[index++];
            float amp = [[[ratioAmpPair allValues] firstObject] floatValue];
            ampSlider.value = amp;
        }
    }
   
}


- (IBAction)ampChanged:(UISlider *)sender {
    [self->_harmonicsGenerator setAmp:sender.value forHarmonic:sender.tag];
}
@end
