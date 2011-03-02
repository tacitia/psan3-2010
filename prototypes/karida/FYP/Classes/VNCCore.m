//
//  VNCCore.m
//  RDPPrototype
//
//  Created by LIU Haixiang on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VNCCore.h"
#include <CommonCrypto/CommonCryptor.h>

@implementation VNCCore


@synthesize serverIP;
@synthesize serverPort;
@synthesize viewController;
@synthesize communicator;
@synthesize packet;
@synthesize packetLength;
@synthesize status;
@synthesize serverVer;


@synthesize setupStatus;//used in serverinit msg
@synthesize recievingStatus;


@synthesize challange;
//UIImage* display;
@synthesize displayArray;
@synthesize secTypes;
@synthesize numOfSecTypes;
@synthesize count;

@synthesize framebufferWidth;
@synthesize framebufferHeight;
@synthesize numOfRects;
@synthesize currentRectID;

-(int)initConnection{
	
	[self updateImage];
	
	communicator = [[NetworkCommunicator alloc] initWithVNCCore:self];
	[communicator connectToServerUsingStream:serverIP portNo:serverPort];
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	if (displayArray != nil) {
		free(displayArray);
		displayArray = nil;
	}	
	//packetLength = 1;//in byte
	//packet = malloc(sizeof(uint8_t) * packetLength);
	//packet[0] = 0x01;
	
	self.status = 1;
	
	return 1;
}

-(int)parseMessage:(uint8_t *)message ofLength:(int)length {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	//NSMutableData *data=[[NSMutableData alloc] init];
	//[data appendBytes:message length:length];
	//NSString* errorMsg = [[NSString alloc] 
	//					  initWithData:data
	//					  encoding:NSASCIIStringEncoding];
	//printf("%s\n",[errorMsg UTF8String]);
	//for(int i = 0;i < length;++i){
	//printf("%i\n",message[0]);
	//}
	//printf("%i\n",length);
	switch (status) {
			
		case 1:	//Server Version Indicator
			serverVer = malloc(sizeof(uint8_t) * 8);
			memcpy(serverVer, message+4*8, 8);
			packet = malloc(sizeof(uint8_t) * 12);
			
			NSString *tmp = @"RFB 003.008\n";
			packet = (uint8_t *)[tmp UTF8String];
			[tmp release];
			
			//memcpy(packet, message, 12);
			[communicator sendMessage:packet length:12];
			packet = malloc(sizeof(uint8_t) * 12);
			NSLog(@"AAAA");
			status = 2;
			break;
		case 2: {//Server Security Indicator
			numOfSecTypes = message[0];
			// connection failed
			if (numOfSecTypes == 0) {
				return -1;
			}
			else {
				count = 0;
				status = 3;
				secTypes = malloc(sizeof(uint8_t) * numOfSecTypes);
				for(int i = 0;i < numOfSecTypes;++i){
					count++;
				}
			}
			NSLog(@"BBBB");
		}
			break;
		case 3://Wait For All The Securities
			count++;
			if (count = numOfSecTypes) {
				int selectedSec = [self selectSecurityType:secTypes withNumOfOptions:numOfSecTypes];
				packet = malloc(sizeof(uint8_t) * 1);
				packet[0] = selectedSec;
				[communicator sendMessage:packet length:1];
				status = 4;
			}
			break;
			
		case 4: //Server Accept/Deny the security type
			if (length != 0) {//Accept
				NSLog(@"here");
				challange = malloc(sizeof(uint8_t) * 16);
				memcpy(challange, message, 16);
				packet = malloc(sizeof(uint8_t) * 16);
				NSString *tmp = @"8059\0\0\0\0";
				uint8_t* key = malloc(sizeof(uint8_t) * 8);
				key[0] = 0x1c;
				key[1] = 0xc;
				key[2] = 0xac;
				key[3] = 0x9c;
				key[4] = 0x0;
				key[5] = 0x0;
				key[6] = 0x0;
				key[7] = 0x0;
				size_t numBytesEncrypted = 0;
				CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, 
													  kCCAlgorithmDES, 
													  kCCOptionECBMode,
													  key, 
													  8,
													  NULL, 
													  challange, 
													  8,
													  packet, 
													  8,
													  &numBytesEncrypted);
				
				cryptStatus = CCCrypt(kCCEncrypt, 
									  kCCAlgorithmDES, 
									  kCCOptionECBMode,
									  key, 
									  8,
									  NULL, 
									  challange + 8, 
									  8,
									  packet + 8, 
									  8,
									  &numBytesEncrypted);printf("%i\n",cryptStatus);
				//printf("%i\n",numBytesEncrypted);
				//for (int i = 0; i < 16; ++i) {
				//	printf("%x ",packet[i]);
				//}
				//printf("\n");
				[communicator sendMessage:packet length:16];
				
				status = 5;
			}
			else {//Deny
				NSMutableData *data=[[NSMutableData alloc] init];
				[data appendBytes:message length:length];
				NSString* errorMsg = [[NSString alloc] 
									  initWithData:data
									  encoding:NSASCIIStringEncoding];
				printf("%s",[errorMsg UTF8String]);
				return -1;
			}
			break;
		case 5://security result
			printf("aaaaa");
			if(message[3] == 0){
				//ClientInit: shared-flag = 1 ALLOWS OTHERS TO CONNECT
				packet = malloc(sizeof(uint8_t) * 1);
				packet[0] = 1;
				[communicator sendMessage:packet length:1];
				printf("SUCCEED!!!!\n");
				status = 6;
				setupStatus = 0;
			}else {
				NSMutableData *data=[[NSMutableData alloc] init];
				[data appendBytes:message length:length];
				NSString* errorMsg = [[NSString alloc] 
									  initWithData:data
									  encoding:NSASCIIStringEncoding];
				printf("%s",[errorMsg UTF8String]);				
				return -1;
			}
			break;
		case 6:
			while (length > 0) {
				switch (setupStatus) {
					case 0:
						framebufferWidth = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						printf("%i\n",framebufferWidth);
						setupStatus = 1;
						break;
					case 1:
						framebufferHeight = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						printf("%i\n",framebufferHeight);
						setupStatus = 2;
						break;
					case 2:
						pixelFormat.bitPerPixel = message[0];
						length -= 1;
						message += 1;
						setupStatus = 3;
						printf("%i bits\n",pixelFormat.bitPerPixel);
						break;
					case 3:
						pixelFormat.depth = message[0];
						length -= 1;
						message += 1;
						setupStatus = 4;
						break;
					case 4:
						pixelFormat.bigEndianFlag = message[0];
						length -= 1;
						message += 1;
						setupStatus = 5;
						break;
					case 5:
						pixelFormat.trueColorFlag = message[0];
						length -= 1;
						message += 1;
						setupStatus = 6;
						break;
					case 6:
						pixelFormat.redMax = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						setupStatus = 7;
						printf("%i\n",pixelFormat.redMax);
						break;
					case 7:
						pixelFormat.greenMax = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						setupStatus = 8;
						printf("%i\n",pixelFormat.greenMax);
						break;
					case 8:
						pixelFormat.blueMax = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						setupStatus = 9;
						printf("%i\n",pixelFormat.blueMax);
						break;
					case 9:
						pixelFormat.redShift = message[0];
						length -= 1;
						message += 1;
						setupStatus = 10;
						break;
					case 10:
						pixelFormat.greenShift = message[0];
						length -= 1;
						message += 1;
						setupStatus = 11;
						break;
					case 11:
						pixelFormat.blueShift = message[0];
						length -= 1;
						message += 1;
						setupStatus = 12;
						break;
					case 12://padding zero
					case 13://padding zero
					case 14://padding zero
						setupStatus += 1;
						length -= 1;
						message += 1;
						break;
					case 15://server name length
						setupStatus = 16;
						length -= 4;
						message += 4;
						break;
					case 16://server name
						printf("");
						NSMutableData *data=[[NSMutableData alloc] init];
						[data appendBytes:message length:length];
						serverName = [[NSString alloc] 
									  initWithData:data
									  encoding:NSASCIIStringEncoding];
						printf("%s",[serverName UTF8String]);				
						setupStatus = 0;
						status = 7;
						length = 0;
						
						printf("updating");
						packet = malloc(sizeof(uint8_t) * 10);
						packet[0] = 3;//message-type : updateReq
						packet[1] = 1;//increamental
						packet[2] = 0;
						packet[3] = 0;//x position;
						packet[4] = 0;
						packet[5] = 0;//y position;
						packet[6] = framebufferWidth / 256;
						packet[7] = framebufferWidth % 256;
						packet[8] = framebufferHeight / 256;
						packet[9] = framebufferHeight % 256;
						if (displayArray!= nil) {
							free(displayArray);
							displayArray = nil;
						}
						displayArray = malloc(framebufferWidth * framebufferHeight * 4);
						[communicator sendMessage:packet length:10];
						status = 8;
						recievingStatus = -1;
						
						break;
					default:
						break;
				}
			}
			break;
		case 7://StartUpdating
			printf("updating");
			packet = malloc(sizeof(uint8_t) * 10);
			packet[0] = 3;//message-type : updateReq
			packet[1] = 1;//increamental
			packet[2] = 0;
			packet[3] = 0;//x position;
			packet[4] = 0;
			packet[5] = 0;//y position;
			packet[6] = framebufferWidth / 256;
			packet[7] = framebufferWidth % 256;
			packet[8] = framebufferHeight / 256;
			packet[9] = framebufferHeight % 256;
			if (displayArray!= nil) {
				free(displayArray);
				displayArray = nil;
			}
			displayArray = malloc(framebufferWidth * framebufferHeight * 4);
			[communicator sendMessage:packet length:10];
			status = 8;
			recievingStatus = -1;
			break;
		case 8://Receiving Image
			while (length > 0) {
				if (recievingStatus == -1) {
					printf("%i msg\n",message[0]);
				}
				if(message[0] == 0 && recievingStatus == -1){//message-type:Update
					printf("updateMessage\n");
					length -= 1;
					message += 1;
					recievingStatus = 0;
					numOfRects = -1;
				}else if (recievingStatus == 0) {//padding
					length -= 1;
					message += 1;
					recievingStatus = 1;
				}else{
					if(numOfRects == -1){
						numOfRects = message[0] * 256 + message[1];
						printf("%i rects",numOfRects);
						length -= 2;
						message += 2;
						currentRectID = 0;
					}else if(currentRectID < numOfRects){
						switch (recievingStatus) {
							case 1:
								currentRects.x = message[0] * 256 + message[1];
								length -= 2;
								message += 2;
								recievingStatus = 2;
								break;
							case 2:
								currentRects.y = message[0] * 256 + message[1];
								length -= 2;
								message += 2;
								recievingStatus = 3;
								break;
							case 3:
								currentRects.width = message[0] * 256 + message[1];
								length -= 2;
								message += 2;
								recievingStatus = 4;
								break;
							case 4:
								currentRects.height = message[0] * 256 + message[1];
								length -= 2;
								message += 2;
								recievingStatus = 5;
								break;
							case 5:
								currentRects.encoding = message[0] * 256 * 256 * 256 + message[1] * 256 * 256 + message[2] * 256 + message[3];
								length -= 4;
								message += 4;
								recievingStatus = 6;
								if (currentRects.encoding != 0) {
									printf("Not Raw Encoding: error!!\n");
									return -1;
								}
								break;
							default:
								//printf("%i \n",recievingStatus - 6);
								if(recievingStatus < 6 + currentRects.width * currentRects.height){
									int position = recievingStatus - 6;
									displayArray[((currentRects.x + position % currentRects.width) + framebufferWidth * (currentRects.y + position / currentRects.width)) * 4] = message[0];
									displayArray[((currentRects.x + position % currentRects.width) + framebufferWidth * (currentRects.y + position / currentRects.width)) * 4 + 1] = message[1];
									displayArray[((currentRects.x + position % currentRects.width) + framebufferWidth * (currentRects.y + position / currentRects.width)) * 4 + 2] = message[2];
									displayArray[((currentRects.x + position % currentRects.width) + framebufferWidth * (currentRects.y + position / currentRects.width)) * 4 + 3] = message[3];
									recievingStatus += 1;
									
									if(position % currentRects.width == 0){
										printf("%i\n",position / currentRects.width);
									}
									length -= 4;
									message += 4;
								}
								if (recievingStatus >= 6 + currentRects.width * currentRects.height) {
									printf("finished\n");
									currentRectID += 1;
									recievingStatus = 1;
									if(currentRectID == numOfRects){
										//updateFinished
										CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
										CGContextRef ctx = CGBitmapContextCreate(displayArray,
																				 framebufferWidth,
																				 framebufferHeight,
																				 8,
																				 4 * framebufferWidth,
																				 colorSpace,
																				 kCGImageAlphaPremultipliedLast); 
										
										CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
										//UIImage* rawImage = [UIImage imageWithCGImage:imageRef];  
										//testing
										[viewController.touchViewController setImageView: [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imageRef]]];
										[[viewController.touchViewController imageScrollView] addSubview:[viewController.touchViewController imageView]];
										//testing finish
										CGContextRelease(ctx);
										printf("finished o~\n");
										//request next update
										packet = malloc(sizeof(uint8_t) * 10);
										packet[0] = 3;//message-type : updateReq
										packet[1] = 1;//increamental
										packet[2] = 0;
										packet[3] = 0;//x position;
										packet[4] = 0;
										packet[5] = 0;//y position;
										packet[6] = framebufferWidth / 256;
										packet[7] = framebufferWidth % 256;
										packet[8] = framebufferHeight / 256;
										packet[9] = framebufferHeight % 256;
										//if (displayArray!= nil) {
										//	free(displayArray);
										//	displayArray = nil;
										//}
										//displayArray = malloc(framebufferWidth * framebufferHeight * 4);
										[communicator sendMessage:packet length:10];
										status = 8;
										recievingStatus = -1;
										printf("UpdateRequestSent");
									}
								}
								break;
						}
					}else {
						//request next update
						packet = malloc(sizeof(uint8_t) * 10);
						packet[0] = 3;//message-type : updateReq
						packet[1] = 1;//increamental
						packet[2] = 0;
						packet[3] = 0;//x position;
						packet[4] = 0;
						packet[5] = 0;//y position;
						packet[6] = framebufferWidth / 256;
						packet[7] = framebufferWidth % 256;
						packet[8] = framebufferHeight / 256;
						packet[9] = framebufferHeight % 256;
						if (displayArray!= nil) {
							free(displayArray);
							displayArray = nil;
						}
						displayArray = malloc(framebufferWidth * framebufferHeight * 4);
						[communicator sendMessage:packet length:10];
						status = 8;
						recievingStatus = -1;
						break;
					}
					
				}
			}
			break;
		default:
			break;
	}
	
	return 1;
}

-(id)initWithViewController:(RDPPrototypeViewController*)viewControllerPtr {
	[super init];
	self.viewController = viewControllerPtr;
	self.communicator = nil;
	self.serverIP = nil;
	self.serverPort = 0;
	self.packetLength = 0;
	self.packet = nil;
	self.status = 0;
	//self.display = nil;
	self.numOfRects = -1;
	displayArray = nil;
	return self;
}

-(int)selectSecurityType:(uint8_t*)secTypes withNumOfOptions:(int)numOfSecTypes {
	return 2;
}

-(int)updateImage{
	//printf("lala");
	//display = [UIImage imageNamed:@"Microsoft_Silverlight.png"];
	//[viewController.displayImage setImage:display];
	//printf("hah");
	return 1;
}

@end
