//
//  VideoCompressModule.m
//  Ablo
//
//  Created by Jovan Stanimirovic on 04/04/2019.
//  Copyright © 2019 Massive//Media. All rights reserved.
//

#import "VideoCompressModule.h"
#import "SDAVAssetExportSession.h"


@implementation VideoCompressModule


RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue
{
	return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents
{
	return @[];
}

+ (BOOL)requiresMainQueueSetup
{
	return YES;
}

- (NSDictionary *)constantsToExport {
	return @{};
}


#pragma mark - compress

RCT_EXPORT_METHOD(compress:(NSString *)url options:(NSDictionary*)options callback:(RCTResponseSenderBlock)callback)
{
	// create temporary directory to store file
	NSString *fileName = [NSString stringWithFormat:@"%@-compressed-video.mp4", [self randomStringWithLength:20]];
	NSString *filePath = [self documentsPathForFileName:fileName];
	
	// fetch asset
	NSURL *inputURL = [NSURL fileURLWithPath:url];
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
	
	// get video track
	AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
	if (videoTrack)
	{
		// parse options
		NSNumber *width = options[@"width"] ? @([options[@"width"] intValue]) : @480;
		NSNumber *height = options[@"height"] ? @([options[@"height"] intValue]) : @848;
		NSNumber *minimumBitrate = options[@"minimumBitrate"] ? @([options[@"minimumBitrate"] intValue]) : @300000;
		NSNumber *bitrateMultiplier = options[@"bitrateMultiplier"] ? @([options[@"bitrateMultiplier"] intValue]) : @3;
		BOOL removeAudio = options[@"removeAudio"] ? [options[@"minimumBitrate"] boolValue] : NO;
		
		// calculate average bitrate
		CGFloat bps = videoTrack.estimatedDataRate;
		CGFloat averageBitrate = bps / [bitrateMultiplier floatValue];
		if (minimumBitrate) {
			if (averageBitrate < [minimumBitrate floatValue]) {
				averageBitrate = [minimumBitrate floatValue];
			}
			if (bps < [minimumBitrate floatValue]) {
				averageBitrate = bps;
			}
		}
		
		// encode
		SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:asset];
		encoder.outputFileType = AVFileTypeMPEG4;
		encoder.outputURL = [NSURL fileURLWithPath:filePath];
		encoder.videoSettings = @
		{
		AVVideoCodecKey: AVVideoCodecH264,
		AVVideoWidthKey: width,
		AVVideoHeightKey: height,
		AVVideoCompressionPropertiesKey: @
			{
			AVVideoAverageBitRateKey: @(averageBitrate),
			AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
			},
		};
		
		if (!removeAudio) {
			encoder.audioSettings = @
			{
			AVFormatIDKey: @(kAudioFormatMPEG4AAC),
			AVNumberOfChannelsKey: @2,
			AVSampleRateKey: @44100,
			AVEncoderBitRateKey: @128000,
			};
		}
		
		[encoder exportAsynchronouslyWithCompletionHandler:^
		 {
			 if (encoder.status == AVAssetExportSessionStatusCompleted)
			 {
				 NSLog(@"Video export succeeded");
				 if (callback) {
					 callback(@[[NSNull null], filePath]);
				 }
			 }
			 else if (encoder.status == AVAssetExportSessionStatusCancelled)
			 {
				 NSLog(@"Video export cancelled");
				 if (callback) {
					 callback(@[@"Video export cancelled", [NSNull null]]);
				 }
			 }
			 else
			 {
				 NSString *errorString = [NSString stringWithFormat:@"%@ %@, %ld", @"Video export failed with error: %@ (%ld)", encoder.error.localizedDescription, (long)encoder.error.code];
				 NSLog(@"%@", errorString);
				 if (callback) {
					 callback(@[errorString, [NSNull null]]);
				 }
			 }
		 }];
	} else {
		if (callback) {
			NSString *errorString = [NSString stringWithFormat:@"No video track found at path %@", filePath];
			callback(@[errorString, [NSNull null]]);
		}
	}
}

RCT_EXPORT_METHOD(getAssetInfo:(NSString *)url callback:(RCTResponseSenderBlock)callback)
{
	// load asset
	NSURL *assetURL = [NSURL fileURLWithPath:url];
	AVURLAsset *asset = [AVURLAsset assetWithURL:assetURL];
	
	// asset information to be returned
	NSMutableDictionary *assetInfo = [NSMutableDictionary new];
	
	// get video track
	AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
	if (videoTrack)
	{
		// duration
		assetInfo[@"duration"] = @(CMTimeGetSeconds(videoTrack.timeRange.duration));
		
		// size
		CGSize naturalSize = videoTrack.naturalSize;
		CGAffineTransform t = videoTrack.preferredTransform;
		BOOL isPortrait = t.a == 0 && fabs(t.b) == 1 && t.d == 0;
		NSDictionary *sizeInfo = @{
								   @"width": isPortrait ? @(naturalSize.height) : @(naturalSize.width),
								   @"height": isPortrait ? @(naturalSize.width) : @(naturalSize.height)
								   };
		assetInfo[@"size"] = sizeInfo;
		
		// framerate
		assetInfo[@"frameRate"] = @(round(videoTrack.nominalFrameRate));
		assetInfo[@"bitrate"] = @(round(videoTrack.estimatedDataRate));
		
		if (callback) {
			callback(@[[NSNull null], assetInfo]);
		}
	} else {
		if (callback) {
			NSString *error = [NSString stringWithFormat:@"No video found for url %@", url];
			callback(@[error, [NSNull null]]);
		}
	}
}


- (NSString *)randomStringWithLength:(int)length
{
	NSMutableString* string = [NSMutableString stringWithCapacity:length];
	for (int i = 0; i < length; i++) {
		[string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(26))];
	}
	return string;
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	return [documentsPath stringByAppendingPathComponent:name];
}

- (BOOL)deleteWithFilePath:(NSString*)filePath
{
	NSError *error = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
	if (error) {
		NSLog(@"Could not delete file %@", [error localizedDescription]);
	}
	return success;
}

@end
