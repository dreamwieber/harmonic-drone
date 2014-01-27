//
//  ADSR.m
//  ShapedNoise
//
//  Created by Gregory Wieber on 1/25/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "ADSR.h"

typedef NS_ENUM(NSInteger, ADSRPhase) {
    ADSRPhaseNone,
    ADSRPhaseAttack,
    ADSRPhaseDecay,
    ADSRPhaseSustain,
    ADSRPhaseRelease
};

@interface ADSR () {
    @public
    ADSRPhase _phase; // whether we're currently attacking, decaying, etc
    float _amplitude; // what the audio is multiplied by.
    
    // times in samples
    double _currentPhaseElapsedTime; //e.g., how long we've been attacking, decaying, etc
    // how much each phase increments/decrements per sample
    double _attackIncrement;
    double _decayDecrement;
    double _releaseDecrement;
    
}

@end

@implementation ADSR

+ (id)ADSRWithAttack:(NSTimeInterval)attack
               decay:(NSTimeInterval)decay
             sustain:(float)sustain
             release:(NSTimeInterval)release
{
    ADSR *adsr = [ADSR new];
    
    if (adsr) {
        
        adsr->_amplitude = 0;
        adsr->_phase = ADSRPhaseNone;
        adsr->_currentPhaseElapsedTime = 0;
        
        adsr.attackT = attack;
        adsr.decayT = decay;
        adsr.sustain = sustain;
        adsr.releaseT = release;
        
        [adsr createProcessBlock];
        
    }
    
    return adsr;
}

- (void)createProcessBlock
{
    __weak ADSR *weakSelf = self;
    
    self.processBlock = ^(UInt32 frames, float *audio) {
       
        ADSR *adsr = weakSelf; // strongify
    
        for (int i = 0; i < frames; i++) {
            
            // if the gate was closed, goto the release phase
            if (adsr->_phase != ADSRPhaseRelease && !adsr->_gateOpen) {
                adsr->_phase = ADSRPhaseRelease;
            } else if (adsr->_gateOpen && (adsr->_phase == ADSRPhaseRelease || adsr->_phase == ADSRPhaseNone)) {
                // gate was re-opened
                adsr->_phase = ADSRPhaseAttack;
                adsr->_currentPhaseElapsedTime = 0.0;
            }

            switch (adsr->_phase) {
                    
                case ADSRPhaseAttack: {
                    
                    if (adsr->_currentPhaseElapsedTime >= (adsr->_attackT * 44100)) {
                        adsr->_amplitude = 1.0;
                        adsr->_currentPhaseElapsedTime = 0.0;
                        adsr->_phase++;
                        break;
                    }
                    
                    adsr->_amplitude+= adsr->_attackIncrement;
                    adsr->_currentPhaseElapsedTime++;
                    break;
                }
                    
                case ADSRPhaseDecay: {
                    
                    if (adsr->_amplitude <= adsr->_sustain) {
                        adsr->_amplitude = adsr->_sustain;
                        adsr->_currentPhaseElapsedTime = 0.0;
                        adsr->_phase++;
                        break;
                    }
                    adsr->_amplitude-= adsr->_decayDecrement;
                    adsr->_currentPhaseElapsedTime++;

                    break;
                }
                
                case ADSRPhaseSustain:
                    
                    adsr->_amplitude = adsr->_sustain;
                    break;
                
                case ADSRPhaseRelease: {
                    
                    if (adsr->_amplitude <=0) {
                        adsr->_amplitude = 0.0;
                        adsr->_phase = ADSRPhaseNone;
                        adsr->_currentPhaseElapsedTime = 0.0;
                        break;
                    }
                    
                    adsr->_amplitude-= adsr->_releaseDecrement;
                    adsr->_currentPhaseElapsedTime++;
        
                    break;
                }
                default:
                    adsr->_amplitude = 0.0;
                    break;
            }
        
            audio[i]*= fminf(1.0, adsr->_amplitude);
        }
        
    };
}

- (void)setAttackT:(NSTimeInterval)attackT
{
    _attackT = attackT;
    if (attackT == 0) {
        _attackIncrement = 1.0;
        return;
    }
    _attackIncrement = 1.0f / (attackT * 44100.0);
    
}

- (void)setDecayT:(NSTimeInterval)decayT
{
    _decayT = decayT;
    _decayDecrement = (1.0f - self.sustain) / (decayT * 44100.0);
    if (_decayDecrement == 0) _decayDecrement = 1.0;
}


- (void)setReleaseT:(NSTimeInterval)releaseT
{
    _releaseT = releaseT;
    _releaseDecrement = 1.0f / (releaseT * 44100.0);
    if (_releaseDecrement == 0) _releaseDecrement = 1.0;
}

@end
