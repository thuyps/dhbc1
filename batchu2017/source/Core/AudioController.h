//
//  AudioController.h
//  Anagrams
//
//  Created by Marin Todorov on 16/02/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
@interface AudioController : NSObject
{
    NSMutableDictionary* audio;
        AVAudioPlayer* oldPlayer;
    
}
-(void)playEffect:(NSString*)name;
-(void)preloadAudioEffects:(NSArray*)effectFileNames;
-(id)playEffect:(NSString*)name withDelegate:(id)delegate;
- (void) stopSound;
@end
