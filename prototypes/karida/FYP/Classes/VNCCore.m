//
//  VNCCore.m
//  RDPPrototype
//
//  Created by LIU Haixiang on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VNCCore.h"
#include <CommonCrypto/CommonCryptor.h>

@interface VNCCore()

- (uint8_t *)generateSingleKeyEvent:(long)key pressed:(BOOL)pressed;
- (CGPoint)transformClientPositionToServerPosition:(CGPoint)clientPosition;
- (int)selectSecurityType:(uint8_t*)secTypes withNumOfOptions:(int)numOfSecTypes; 

@end


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

@synthesize mouseButtonStatus;

BOOL isCustomServer = FALSE; 

#pragma mark MouseEvent Constants

const int MOUSEEVENTF_ABSOLUTE = 0x8000;
const int MOUSEEVENTF_MOVE = 0x0001;
const int MOUSEEVENTF_LEFTDOWN = 0x0002;
const int MOUSEEVENTF_LEFTUP = 0x0004;
const int MOUSEEVENTF_RIGHTDOWN = 0x0008;
const int MOUSEEVENTF_RIGHTUP = 0x0010;
const int MOUSEEVENTF_WHEEL = 0x0800;

#pragma mark KeyEvent Constants

const int KEYEVENTF_KEYUP = 0x0002;

#pragma mark Virtual Key Codes

const int VK_CANCEL = 0x03; //Control-breaking process
const int VK_BACK = 0x08;
const int VK_TAB = 0x09;
const int VK_RETURN = 0x0D; //Enter
const int VK_SHIFT = 0x10;
const int VK_CONTROL = 0x11;
const int VK_MENU = 0x12; //ALT key
const int VK_CAPITAL = 0x14;
const int VK_ESCAPE = 0x1B;
const int VK_SPACE = 0x20;
const int VK_PRIOR = 0x21; //Page up
const int VK_NEXT = 0x22; //Page down
const int VK_END = 0x23;
const int VK_HOME = 0x24;
const int VK_LEFT = 0x25;
const int VK_UP = 0x26;
const int VK_RIGHT = 0x27;
const int VK_DOWN = 0x28;
const int VK_SNAPSHOT = 0x2C;
const int VK_INSERT = 0x2D;
const int VK_DELETE = 0x2E;
const int VK_F1 = 70;

#pragma mark Other Constants
const int singleKeyEventRepLength = 12;
const int keyEventPacketHeaderLength = 2;
UIImage* previousImage = nil;
#pragma mark Connection Flow


-(int)initConnection{
	printf("initConnection calledn");
	NSLog(serverIP);
	NSLog(@"\n");
	NSLog(@"%i\n", serverPort);
	
	[self updateImage];
	
	communicator = [[NetworkCommunicator alloc] initWithVNCCore:self];
	[communicator setDelegate:self.viewController];
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
	
	mouseButtonStatus = malloc(sizeof(uint8_t)*8);
	memset(mouseButtonStatus, 0, 8);
	
	printf("end of init connection");
	
	return 1;
}

-(int)parseMessage:(uint8_t *)message ofLength:(int)length {
	static int expectedPacket = -1;
	static NSMutableData* imageData = nil;
	static NSMutableData* p_data = nil;
	static int updateImageX = -1;
	static int updateImageY = -1;
	static int updateImageW = -1;
	static int updateImageH = -1;
	
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	
	if (p_data == nil) {
		p_data = [[NSMutableData alloc] initWithLength:0];
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
	if (status == 1 && message[10] == '0') {
		isCustomServer = TRUE;
	}
	
	if (isCustomServer) {
		//Call another function
		//printf("here\n");
		while (length != 0) {
	
			switch (status) {
					
				case 1:	//Server Version Indicator
					serverVer = malloc(sizeof(uint8_t) * 8);
					memcpy(serverVer, message+4*8, 8);
					packet = malloc(sizeof(uint8_t) * 12);
				
					NSString *tmp = @"RFB 000.000\n";
					packet = (uint8_t *)[tmp UTF8String];
					[tmp release];
					
					//memcpy(packet, message, 12);
					[communicator sendMessage:packet length:12];
					packet = malloc(sizeof(uint8_t) * 12);
					NSLog(@"AAAA1");
					status = 2;
					length = 0;
					break;
				case 2://security
					//
					packet = malloc(sizeof(uint8_t));
					packet[0] = 1;
					[communicator sendMessage:packet length:1];
					status = 3;
					length = 0;
					break;
				case 3:
					//share
					packet = malloc(sizeof(uint8_t));
					packet[0] = 1;
					[communicator sendMessage:packet length:1];
					status = 4;
					length = 0;
					break;
				case 4:
					framebufferWidth = message[0] * 256 + message[1];
					framebufferHeight = message[2] * 256 + message[3];
					packet = malloc(sizeof(uint8_t));
					packet[0] = 3;
					[communicator sendMessage:packet length:1];
					status = 5;
					recievingStatus = -1;
					length = 0;
					break;
				case 5:
					if([p_data length] != 0){
						[p_data appendBytes:message length:length];
						//[message release];
						NSUInteger len = [p_data length];
						memcpy(message, [p_data bytes], len);;
						length = [p_data length];
						[p_data setLength:0];
						
					}
					/*
					 dispatch_queue_t imageDataReceiverQueue = dispatch_queue_create("Image Data Receiver", NULL);
					 dispatch_async(imageDataReceiverQueue, ^{
					 });
					 */
				
					printf("packet length: %i \n", length);
					//printf("receiving %i %i %i\n",framebufferWidth,framebufferHeight,message[0]);
					if (length >=16 && message[0] == 'U' && message[1] == 'P' && message[2] == 'D') {
						//printf("%i %i\n",message[8] * 256 + message[9],message[10] * 256 + message[11]);
						updateImageX = message[4] * 256 + message[5];
						updateImageY = message[6] * 256 + message[7];
						updateImageW = message[8] * 256 + message[9];
						updateImageH = message[10] * 256 + message[11];
						expectedPacket = message[12] * 256 * 256 * 256 + message[13] * 256 * 256 + message[14] * 256 + message[15];
						//	printf("ep %i\n",expectedPacket);
						if(imageData != nil){
							[imageData release];
						}
						imageData = [[NSMutableData alloc]initWithLength:0];
						recievingStatus = 1;
						length -= 16;
						message += 16;
						if(length == 0){
							break;
						}
					}else if (length < 16) {
						[p_data appendBytes:message length:length];
						length = 0;
						break;
					}
					if (recievingStatus = 1) {
						//printf("expected\n");
						if (expectedPacket >= length) {
							[imageData appendBytes:message length:length];
							expectedPacket -= length;
							length = 0;
							//printf("%i\n",expectedPacket);
							if(expectedPacket == 0){
								UIImage* tmp = [[UIImage alloc] initWithData:imageData];
								printf("size %f %f\n",[tmp size].width,[tmp size].height);
								if (previousImage == nil) {
									//previousImage = [[UIImage alloc] initWithCGImage: [tmp CGImage]];
									[viewController.touchViewController updateImage:tmp];
								}else {
									//UIGraphicsBeginImageContextWithOptions(CGSizeMake(framebufferWidth,framebufferHeight), YES, 0);
									//[previousImage drawAtPoint:CGPointMake(0,0)];
									//[tmp drawAtPoint:CGPointMake(updateImageX,updateImageY)];
									[previousImage release];
									//previousImage = UIGraphicsGetImageFromCurrentImageContext();
									//UIGraphicsEndImageContext();
									//[viewController.touchViewController updateImage:previousImage];
									[viewController.touchViewController updateImage:tmp];
								}
								[tmp release];	
								recievingStatus = -1;
							
								//packet = malloc(sizeof(uint8_t));
								//packet[0] = 3;
								//[communicator sendMessage:packet length:1];
							}
						}else {
							NSLog(@"aaaaaa");
							[imageData appendBytes:message length:expectedPacket];
							length -= expectedPacket;
							message += expectedPacket;
							UIImage* tmp = [[UIImage alloc] initWithData:imageData];
							printf("%f %f\n",[tmp size].width,[tmp size].height);
							if (previousImage == nil) {
								//previousImage = [[UIImage alloc] initWithCGImage: [tmp CGImage]];
								[viewController.touchViewController updateImage:tmp];
							}else {
								//UIGraphicsBeginImageContextWithOptions(CGSizeMake(framebufferWidth,framebufferHeight), YES, 0);
								//[previousImage drawAtPoint:CGPointMake(0,0)];
								//[tmp drawAtPoint:CGPointMake(updateImageX,updateImageY)];
								[previousImage release];
								//previousImage = UIGraphicsGetImageFromCurrentImageContext();
								//UIGraphicsEndImageContext();
								//[viewController.touchViewController updateImage:previousImage];
								[viewController.touchViewController updateImage:tmp];
							}
							[tmp release];
							[p_data appendBytes:message length:length];
							length = 0;
							recievingStatus = -1;
							NSLog(@"aaaaaa f");
						}

					}
					break;			
				default:
					break;
			}	
		}
	}
	else {
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
				printf("%i\n",secTypes);
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
									  &numBytesEncrypted);//printf("%i\n",cryptStatus);
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
//			printf("aaaaa");
			if(message[3] == 0){
				//ClientInit: shared-flag = 1 ALLOWS OTHERS TO CONNECT
				packet = malloc(sizeof(uint8_t) * 1);
				packet[0] = 1;
				[communicator sendMessage:packet length:1];
//				printf("SUCCEED!!!!\n");
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
//						printf("%i\n",framebufferWidth);
						setupStatus = 1;
						break;
					case 1:
						framebufferHeight = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
//						printf("%i\n",framebufferHeight);
						setupStatus = 2;
						break;
					case 2:
						pixelFormat.bitPerPixel = message[0];
						length -= 1;
						message += 1;
						setupStatus = 3;
//						printf("%i bits\n",pixelFormat.bitPerPixel);
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
//						printf("%i\n",pixelFormat.redMax);
						break;
					case 7:
						pixelFormat.greenMax = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						setupStatus = 8;
//						printf("%i\n",pixelFormat.greenMax);
						break;
					case 8:
						pixelFormat.blueMax = message[0] * 256 + message[1];
						length -= 2;
						message += 2;
						setupStatus = 9;
//						printf("%i\n",pixelFormat.blueMax);
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
//						printf("");
						;
						NSMutableData *data=[[NSMutableData alloc] init];
						[data appendBytes:message length:length];
						serverName = [[NSString alloc] 
									  initWithData:data
									  encoding:NSASCIIStringEncoding];
//						printf("%s",[serverName UTF8String]);				
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
//						printf("%i rects",numOfRects);
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
//										printf("%i\n",position / currentRects.width);
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
										[viewController.touchViewController updateImage:[UIImage imageWithCGImage:imageRef]];
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
	}
	
	return 1;
}

/*
- (void)sendKeys:(int*)keys numberOfKeys:(int)numOfKeys isSerial:(BOOL)isSerial {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * numOfKeys * 2;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = numOfKeys * 2;
	
	if (isSerial) {
		
	}
	else {
		for (int i = 0; i < numOfKeys; ++i) {
			uint8_t *keyPressed = [self generateSingleKeyEvent:keys[i] pressed:YES];
			for (int j = 0; j < singleKeyEventRepLength; ++j) {
				packet[keyEventPacketHeaderLength + i * singleKeyEventRepLength + j] = keyPressed[j];
			}
		}
		for (int i = numOfKeys; i > 0; --i) {
			uint8_t *keyPressed = [self generateSingleKeyEvent:keys[i] pressed:NO];
			for (int j = 0; j < singleKeyEventRepLength; ++j) {
				packet[keyEventPacketHeaderLength + numOKeys * singleKeyEventRepLength + (numOfKeys-i) * singleKeyEventRepLength +j] = keyPressed[j];
			}
		}
		[communicator sendMessage:packet length:packetLength];		
	}
}
*/
 
#pragma mark -
#pragma mark Keyboard Events

- (void) sendCtrlPlusChar:(char)character {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 4;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 4;
	
	uint8_t *ctrlPressed = [self generateSingleKeyEvent:VK_CONTROL pressed:YES];
	uint8_t *charPressed = [self generateSingleKeyEvent:(character-32) pressed:YES];
	uint8_t *charReleased = [self generateSingleKeyEvent:(character-32) pressed:NO];
	uint8_t *ctrlReleased = [self generateSingleKeyEvent:VK_CONTROL pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = ctrlPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = charPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = charReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = ctrlReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendTab {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 2;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 2;
	
	uint8_t *tabPressed = [self generateSingleKeyEvent:VK_TAB pressed:YES];
	uint8_t *tabReleased = [self generateSingleKeyEvent:VK_TAB pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = tabPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = tabReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendAltPlusTab {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 4;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 4;
	
	uint8_t *altPressed = [self generateSingleKeyEvent:VK_MENU pressed:YES];
	uint8_t *tabPressed = [self generateSingleKeyEvent:VK_TAB pressed:YES];
	uint8_t *tabReleased = [self generateSingleKeyEvent:VK_TAB pressed:NO];
	uint8_t *altReleased = [self generateSingleKeyEvent:VK_MENU pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = altPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = tabPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = tabReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = altReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendAltPlusF4 {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 4;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 4;
	
	uint8_t *altPressed = [self generateSingleKeyEvent:VK_MENU pressed:YES];
	uint8_t *f4Pressed = [self generateSingleKeyEvent:(VK_F1+3) pressed:YES];
	uint8_t *f4Released = [self generateSingleKeyEvent:(VK_F1+3) pressed:NO];
	uint8_t *altReleased = [self generateSingleKeyEvent:VK_MENU pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = altPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = f4Pressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = f4Released[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = altReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendCtrlPlusF4 {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 4;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 4;
	
	uint8_t *ctrlPressed = [self generateSingleKeyEvent:VK_CONTROL pressed:YES];
	uint8_t *f4Pressed = [self generateSingleKeyEvent:(VK_F1+3) pressed:YES];
	uint8_t *f4Released = [self generateSingleKeyEvent:(VK_F1+3) pressed:NO];
	uint8_t *ctrlReleased = [self generateSingleKeyEvent:VK_CONTROL pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = ctrlPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = f4Pressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = f4Released[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = ctrlReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendCtrlPlusSpace {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 4;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 4;
	
	uint8_t *ctrlPressed = [self generateSingleKeyEvent:VK_CONTROL pressed:YES];
	uint8_t *spacePressed = [self generateSingleKeyEvent:VK_SPACE pressed:YES];
	uint8_t *spaceReleased = [self generateSingleKeyEvent:VK_SPACE pressed:NO];
	uint8_t *ctrlReleased = [self generateSingleKeyEvent:VK_CONTROL pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = ctrlPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = spacePressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = spaceReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = ctrlReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendShiftPlusAltPlusTab {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 6;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 6;
	
	uint8_t *shiftPressed = [self generateSingleKeyEvent:VK_SHIFT pressed:YES];
	uint8_t *altPressed = [self generateSingleKeyEvent:VK_MENU pressed:YES];
	uint8_t *tabPressed = [self generateSingleKeyEvent:VK_TAB pressed:YES];
	uint8_t *tabReleased = [self generateSingleKeyEvent:VK_TAB pressed:NO];
	uint8_t *altReleased = [self generateSingleKeyEvent:VK_MENU pressed:NO];
	uint8_t *shiftReleased = [self generateSingleKeyEvent:VK_SHIFT pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = shiftPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = altPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = tabPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = tabReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*4] = altReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*5] = shiftReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

- (void) sendSingleKeyEventWithKey:(int)key pressed:(BOOL)pressed {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	
	packetLength = keyEventPacketHeaderLength+singleKeyEventRepLength;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 1;
	
	uint8_t *keyEvent = [self generateSingleKeyEvent:key pressed:pressed];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[keyEventPacketHeaderLength+i] = keyEvent[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}

// send Alt + Space, then N
- (void) minimizeCurrentActiveWindow {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 6;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 6;
	
	uint8_t *altPressed = [self generateSingleKeyEvent:VK_MENU pressed:YES];
	uint8_t *spacePressed = [self generateSingleKeyEvent:VK_SPACE pressed:YES];
	uint8_t *spaceReleased = [self generateSingleKeyEvent:VK_SPACE pressed:NO];
	uint8_t *altReleased = [self generateSingleKeyEvent:VK_MENU pressed:NO];
	uint8_t *nPressed = [self generateSingleKeyEvent:'n'-32 pressed:YES];
	uint8_t *nReleased = [self generateSingleKeyEvent:'n'-32 pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = altPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = spacePressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = spaceReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = altReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*4] = nPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*5] = nReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}


// send Alt + Space, then X
- (void) maximizeCurrentActiveWindow {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = keyEventPacketHeaderLength + singleKeyEventRepLength * 6;
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	packet[0] = 4;
	packet[1] = 6;
	
	uint8_t *altPressed = [self generateSingleKeyEvent:VK_MENU pressed:YES];
	uint8_t *spacePressed = [self generateSingleKeyEvent:VK_SPACE pressed:YES];
	uint8_t *spaceReleased = [self generateSingleKeyEvent:VK_SPACE pressed:NO];
	uint8_t *altReleased = [self generateSingleKeyEvent:VK_MENU pressed:NO];
	uint8_t *xPressed = [self generateSingleKeyEvent:'x'-32 pressed:YES];
	uint8_t *xReleased = [self generateSingleKeyEvent:'x'-32 pressed:NO];
	
	for (int i = 0; i < singleKeyEventRepLength; ++i) {
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*0] = altPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*1] = spacePressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*2] = spaceReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*3] = altReleased[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*4] = xPressed[i];
		packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*5] = xReleased[i];
	}
	
	[communicator sendMessage:packet length:packetLength];
}


//TODO
- (void)sendString:(NSString*)string {
	NSLog(@"sendString called");
	
	if (packet != nil) {
		free(packet);
		packet = nil;
	}	
	
	packetLength = 0;
		
	for (int i = 0; i < [string length]; ++i) {
		unichar currentChar = [string characterAtIndex:i];
		if (48 <= currentChar <= 57 || 97 <= currentChar <= 122) {
			packetLength += 2;
		}
		else {
			packetLength += 4;
		}
	}
	
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	int numberOfKeyEventRecorded = 0;	
	for (int i = 0; i < [string length]; ++i) {
		unichar currentChar = [string characterAtIndex:i];
		
		if (97 <= currentChar <= 122) {						
			uint8_t *charPressed = [self generateSingleKeyEvent:(currentChar-32) pressed:YES];
			uint8_t *charReleased = [self generateSingleKeyEvent:(currentChar-32) pressed:NO];
			for (int i = 0; i < singleKeyEventRepLength; ++i) {
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*numberOfKeyEventRecorded] = charPressed[i];
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*(numberOfKeyEventRecorded+1)] = charReleased[i];
			}
			numberOfKeyEventRecorded += 2;
		}
		else if (65 <= currentChar <= 90) {			
			uint8_t *shiftPressed = [self generateSingleKeyEvent:VK_SHIFT pressed:YES];
			uint8_t *charPressed = [self generateSingleKeyEvent:currentChar pressed:YES];
			uint8_t *charReleased = [self generateSingleKeyEvent:currentChar pressed:NO];
			uint8_t *shiftReleased = [self generateSingleKeyEvent:VK_SHIFT pressed:NO];
			
			for (int i = 0; i < 12; ++i) {
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*numberOfKeyEventRecorded] = shiftPressed[i];
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*(numberOfKeyEventRecorded+1)] = charPressed[i];
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*(numberOfKeyEventRecorded+2)] = charReleased[i];
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*(numberOfKeyEventRecorded+3)] = shiftReleased[i];
			}
			numberOfKeyEventRecorded += 4;
		}
		else if (48 <= currentChar <= 57) {
			uint8_t *charPressed = [self generateSingleKeyEvent:currentChar pressed:YES];;
			uint8_t *charReleased = [self generateSingleKeyEvent:currentChar pressed:NO];
			
			for (int i = 0; i < 12; ++i) {
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*numberOfKeyEventRecorded] = charPressed[i];
				packet[i+keyEventPacketHeaderLength+singleKeyEventRepLength*(numberOfKeyEventRecorded+1)] = charReleased[i];
			}
			numberOfKeyEventRecorded += 2;
		}
		else {
			//TODO
			
		}
		NSLog(@"keyboard event sent");
		for (int i = 0; i < packetLength; ++i) {
			printf("%i, ", packet[i]);
		}
		printf("\n");
		[communicator sendMessage:packet length:packetLength];
	}
}

- (uint8_t *)generateSingleKeyEvent:(long)key pressed:(BOOL)pressed {
	uint8_t *event = malloc(sizeof(uint8_t) * singleKeyEventRepLength);
	
	event[0] = (key / 256) % 256;
	event[1] = key % 256;
	event[2] = event[3] = 0;
	
	unsigned int dwFlags = pressed ? 0 : KEYEVENTF_KEYUP;
	event[4] = dwFlags / 256 / 256 / 256;
	event[5] = (dwFlags / 256 / 256) % 256;
	event[6] = (dwFlags / 256) % 256;
	event[7] = dwFlags % 256;
	
	event[8] = event[9] = event[10] = event[11] = 0;
	
	return event;
}


/*
-(void)sendKeyEvent:(KeySym)keySym pressed:(BOOL)pressed {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	
	packet = malloc(sizeof(uint8_t) * 8);
	
	packet[0] = 4; //message-type: client to server keyEvent
	(pressed == TRUE) ? (packet[1] = 1) : (packet[1] = 0); //zero indicates the key is now released
	packet[2] = packet[3] = packet[4] = packet[5] = 0;
	
	
	switch (keySym) {
		case Back_Space:
			packet[6] = 0xff;
			packet[7] = 0x08;
			break;
		case Tab:
			packet[6] = 0xff;
			packet[7] = 0x09;
			break;
		case Return:
			packet[6] = 0xff;
			packet[7] = 0x0d;
			break;
		case Escape:
			packet[6] = 0xff;
			packet[7] = 0x1b;
			break;
		case Insert:
			packet[6] = 0xff;
			packet[7] = 0x63;
			break;
		case Delete:
			packet[6] = 0xff;
			packet[7] = 0xff;
			break;
		case Home:
			packet[6] = 0xff;
			packet[7] = 0x50;
			break;
		case End:
			packet[6] = 0xff;
			packet[7] = 0x57;
			break;
		case Page_Up:
			packet[6] = 0xff;
			packet[7] = 0x55;
			break;
		case Page_Down:
			packet[6] = 0xff;
			packet[7] = 0x56;
			break;
		case Left:
			packet[6] = 0xff;
			packet[7] = 0x51;
			break;
		case Up:
			packet[6] = 0xff;
			packet[7] = 0x52;
			break;
		case Right:
			packet[6] = 0xff;
			packet[7] = 0x53;
			break;
		case Down:
			packet[6] = 0xff;
			packet[7] = 0x54;
			break;
		case Scroll_Lock:
			packet[6] = 0xff;
			packet[7] = 0x14;
			break;
		case SysReq:
			packet[6] = 0xff;
			packet[7] = 0x15;
			break;
		case Shift_L:
			packet[6] = 0xff;
			packet[7] = 0xe1;
			break;
		case Shift_R:
			packet[6] = 0xff;
			packet[7] = 0xe2;
			break;
		case Ctrl_L:
			packet[6] = 0xff;
			packet[7] = 0xe3;
			break;
		case Ctrl_R:
			packet[6] = 0xff;
			packet[7] = 0xe4;
			break;
		case Caps_Lock:
		case Meta_L:
			packet[6] = 0xff;
			packet[7] = 0xe7;
			break;
		case Meta_R:
			packet[6] = 0xff;
			packet[7] = 0xe8;
			break;
		case Alt_L:
			packet[6] = 0xff;
			packet[7] = 0xe9;
			break;
		case Alt_R:
			packet[6] = 0xff;
			packet[7] = 0xea;
			break;
			
		case F1:
			packet[6] = 0xff;
			packet[7] = 0xbe;
			break;
		case F2:
			packet[6] = 0xff;
			packet[7] = 0xbf;
			break;
		case F3:
			packet[6] = 0xff;
			packet[7] = 0xc0;
			break;
		case F4:
			packet[6] = 0xff;
			packet[7] = 0xc1;
		case F5:
			packet[6] = 0xff;
			packet[7] = 0xc2;
			break;
		case F6:
			packet[6] = 0xff;
			packet[7] = 0xc3;
			break;
		case F7:
			packet[6] = 0xff;
			packet[7] = 0xc4;
			break;
		case F8:
			packet[6] = 0xff;
			packet[7] = 0xc5;
			break;
		case F9:
			packet[6] = 0xff;
			packet[7] = 0xc6;
			break;
		case F10:
			packet[6] = 0xff;
			packet[7] = 0xc7;
			break;
		case F11:
			packet[6] = 0xff;
			packet[7] = 0xc8;
			break;
		case F12:
			packet[6] = 0xff;
			packet[7] = 0xc9;
			break;
	
		case Space:
			packet[6] = 0x00;
			packet[7] = 0x20;
			break;
		case Exclam:
			packet[6] = 0x0;
			packet[7] = 0x21;
			break;
		case Quotedbl:
			packet[6] = 0x0;
			packet[7] = 0x22;
			break;
		case Numbersign:
			packet[6] = 0x0;
			packet[7] = 0x23;
			break;
		case Dollar:
			packet[6] = 0x0;
			packet[7] = 0x24;
			break;
		case Percent:
			packet[6] = 0x0;
			packet[7] = 0x25;
			break;
		case Ampersand:
			packet[6] = 0x0;
			packet[7] = 0x26;
			break;
		case Apostrophe:
			packet[6] = 0x0;
			packet[7] = 0x27;
			break;
		case Parenleft:
			packet[6] = 0x0;
			packet[7] = 0x28;
			break;
		case Parenright:
			packet[6] = 0x0;
			packet[7] = 0x29;
			break;
		case Asterisk:
			packet[6] = 0x0;
			packet[7] = 0x2a;
			break;
		case Plus:
			packet[6] = 0x0;
			packet[7] = 0x2b;
			break;
		case Comma:
			packet[6] = 0x0;
			packet[7] = 0x2c;
			break;
		case Minus:
			packet[6] = 0x0;
			packet[7] = 0x2d;
			break;
		case Period:
			packet[6] = 0x0;
			packet[7] = 0x2e;
			break;
		case Slash:
			packet[6] = 0x0;
			packet[7] = 0x2f;
			break;
		case Colon:
			packet[6] = 0x0;
			packet[7] = 0x3a;
			break;
		case Semicolon:
			packet[6] = 0x0;
			packet[7] = 0x3b;
			break;
		case Less:
			packet[6] = 0x0;
			packet[7] = 0x3c;
			break;
		case Equal:
			packet[6] = 0x0;
			packet[7] = 0x3d;
			break;
		case Greater:
			packet[6] = 0x0;
			packet[7] = 0x3e;
			break;
		case Question:
			packet[6] = 0x0;
			packet[7] = 0x3f;
			break;
		case At:
			packet[6] = 0x0;
			packet[7] = 0x40;
			break;
		case Bracketleft:
			packet[6] = 0x0;
			packet[7] = 0x5b;
			break;
		case Backslash:
			packet[6] = 0x0;
			packet[7] = 0x5c;
			break;
		case Bracketright:
			packet[6] = 0x0;
			packet[7] = 0x5d;
			break;
		case Asciicircum:
			packet[6] = 0x0;
			packet[7] = 0x5e;
			break;
		case Underscore:
			packet[6] = 0x0;
			packet[7] = 0x5f;
			break;
		case Grave:
			packet[6] = 0x0;
			packet[7] = 0x60;
			break;
		case Braceleft:
			packet[6] = 0x0;
			packet[7] = 0x7b;
			break;
		case Braceright:
			packet[6] = 0x0;
			packet[7] = 0x7d;
			break;
		case Bar:
			packet[6] = 0x0;
			packet[7] = 0x7c;
			break;
		case Asciitilde:
			packet[6] = 0x0;
			packet[7] = 0x7e;
			break;
			
			
		case Num_0:
			packet[6] = 0x0;
			packet[7] = 0x30;
			break;
		case Num_1:
			packet[6] = 0x0;
			packet[7] = 0x31;
			break;
		case Num_2:
			packet[6] = 0x0;
			packet[7] = 0x32;
			break;
		case Num_3:
			packet[6] = 0x0;
			packet[7] = 0x33;
			break;
		case Num_4:
			packet[6] = 0x0;
			packet[7] = 0x34;
			break;
		case Num_5:
			packet[6] = 0x0;
			packet[7] = 0x35;
			break;
		case Num_6:
			packet[6] = 0x0;
			packet[7] = 0x36;
			break;
		case Num_7:
			packet[6] = 0x0;
			packet[7] = 0x37;
			break;
		case Num_8:
			packet[6] = 0x0;
			packet[7] = 0x38;
			break;
		case Num_9:
			packet[6] = 0x0;
			packet[7] = 0x39;
			break;
			
		case Char_A:
			packet[6] = 0x0;
			packet[7] = 0x41;
			break;
		case Char_B:
			packet[6] = 0x0;
			packet[7] = 0x42;
			break;
		case Char_C:
			packet[6] = 0x0;
			packet[7] = 0x43;
			break;
		case Char_D:
			packet[6] = 0x0;
			packet[7] = 0x44;
			break;
		case Char_E:
			packet[6] = 0x0;
			packet[7] = 0x45;
			break;
		case Char_F:
			packet[6] = 0x0;
			packet[7] = 0x46;
			break;
		case Char_G:
			packet[6] = 0x0;
			packet[7] = 0x47;
			break;
		case Char_H:
			packet[6] = 0x0;
			packet[7] = 0x48;
			break;
		case Char_I:
			packet[6] = 0x0;
			packet[7] = 0x49;
			break;
		case Char_J:
			packet[6] = 0x0;
			packet[7] = 0x4a;
			break;
		case Char_K:
			packet[6] = 0x0;
			packet[7] = 0x4b;
			break;
		case Char_L:
			packet[6] = 0x0;
			packet[7] = 0x4c;
			break;
		case Char_M:
			packet[6] = 0x0;
			packet[7] = 0x4d;
			break;
		case Char_N:
			packet[6] = 0x0;
			packet[7] = 0x4e;
			break;
		case Char_O:
			packet[6] = 0x0;
			packet[7] = 0x4f;
			break;
		case Char_P:
			packet[6] = 0x0;
			packet[7] = 0x50;
			break;
		case Char_Q:
			packet[6] = 0x0;
			packet[7] = 0x51;
			break;
		case Char_R:
			packet[6] = 0x0;
			packet[7] = 0x52;
			break;
		case Char_S:
			packet[6] = 0x0;
			packet[7] = 0x53;
			break;
		case Char_T:
			packet[6] = 0x0;
			packet[7] = 0x54;
			break;
		case Char_U:
			packet[6] = 0x0;
			packet[7] = 0x55;
			break;
		case Char_V:
			packet[6] = 0x0;
			packet[7] = 0x56;
			break;
		case Char_W:
			packet[6] = 0x0;
			packet[7] = 0x57;
			break;
		case Char_X:
			packet[6] = 0x0;
			packet[7] = 0x58;
			break;
		case Char_Y:
			packet[6] = 0x0;
			packet[7] = 0x59;
			break;
		case Char_Z:
			packet[6] = 0x0;
			packet[7] = 0x5a;
			break;
			
			
		case Char_a:
			packet[6] = 0x0;
			packet[7] = 0x61;
			break;
		case Char_b:
			packet[6] = 0x0;
			packet[7] = 0x62;
			break;
		case Char_c:
			packet[6] = 0x0;
			packet[7] = 0x63;
			break;
		case Char_d:
			packet[6] = 0x0;
			packet[7] = 0x64;
			break;
		case Char_e:
			packet[6] = 0x0;
			packet[7] = 0x65;
			break;
		case Char_f:
			packet[6] = 0x0;
			packet[7] = 0x66;
			break;
		case Char_g:
			packet[6] = 0x0;
			packet[7] = 0x67;
			break;
		case Char_h:
			packet[6] = 0x0;
			packet[7] = 0x68;
			break;
		case Char_i:
			packet[6] = 0x0;
			packet[7] = 0x69;
			break;
		case Char_j:
			packet[6] = 0x0;
			packet[7] = 0x6a;
			break;
		case Char_k:
			packet[6] = 0x0;
			packet[7] = 0x6b;
			break;
		case Char_l:
			packet[6] = 0x0;
			packet[7] = 0x6c;
			break;
		case Char_m:
			packet[6] = 0x0;
			packet[7] = 0x6d;
			break;
		case Char_n:
			packet[6] = 0x0;
			packet[7] = 0x6e;
			break;
		case Char_o:
			packet[6] = 0x0;
			packet[7] = 0x6f;
			break;
		case Char_p:
			packet[6] = 0x0;
			packet[7] = 0x70;
			break;
		case Char_q:
			packet[6] = 0x0;
			packet[7] = 0x71;
			break;
		case Char_r:
			packet[6] = 0x0;
			packet[7] = 0x72;
			break;
		case Char_s:
			packet[6] = 0x0;
			packet[7] = 0x73;
			break;
		case Char_t:
			packet[6] = 0x0;
			packet[7] = 0x74;
			break;
		case Char_u:
			packet[6] = 0x0;
			packet[7] = 0x75;
			break;
		case Char_v:
			packet[6] = 0x0;
			packet[7] = 0x76;
			break;
		case Char_w:
			packet[6] = 0x0;
			packet[7] = 0x77;
			break;
		case Char_x:
			packet[6] = 0x0;
			packet[7] = 0x78;
			break;
		case Char_y:
			packet[6] = 0x0;
			packet[7] = 0x79;
			break;
		case Char_z:
			packet[6] = 0x0;
			packet[7] = 0x7a;
			break;
			
		default:
			break;
	}
	
	
	switch (keySym) {
	}
	 
	[communicator sendMessage:packet length:8];
}
*/

#pragma mark Mouse Events

- (void)sendRightClickEventAtPosition:(CGPoint)position {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	packet = malloc(sizeof(uint8_t) * 42);
	
	packet[0] = 5;
	packet[1] = 2;
	
	CGPoint serverPosition = [self transformClientPositionToServerPosition:position];
	
	unsigned int x = ceil(serverPosition.x);
	unsigned int y = ceil(serverPosition.y);	
	
	for (int i = 0; i < 2; ++i) {
		packet[2+i*20] = x / 256 / 256 / 256;
		packet[3+i*20] = (x / 256 / 256) % 256;
		packet[4+i*20] = (x / 256) % 256;
		packet[5+i*20] = x % 256;
		packet[6+i*20] = y / 256 / 256 / 256;
		packet[7+i*20] = (y / 256 / 256) % 256;
		packet[8+i*20] = (y / 256) % 256;
		packet[9+i*20] = y % 256;
		
		packet[10+i*20] = packet[11+i*20] = packet[12+i*20] = packet[13+i*20] = 0;
		
		unsigned int dwFlags = (i == 0) ? (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_RIGHTDOWN)
										: (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_RIGHTUP);
		
		packet[14+i*20] = dwFlags / 256 / 256 / 256;
		packet[15+i*20] = (dwFlags / 256 / 256) % 256;
		packet[16+i*20] = (dwFlags / 256) % 256;
		packet[17+i*20] = dwFlags % 256;
		
		packet[18+i*20] = packet[19+i*20] = packet[20+i*20] = packet[21+i*20] = 0;
	}
	
	[communicator sendMessage:packet length:42];	
}

- (void)sendLeftClickEventAtPosition:(CGPoint)position {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	packet = malloc(sizeof(uint8_t) * 42);
	
	packet[0] = 5;
	packet[1] = 2;
	
	CGPoint serverPosition = [self transformClientPositionToServerPosition:position];

	unsigned int x = ceil(serverPosition.x);
	unsigned int y = ceil(serverPosition.y);	
	
	for (int i = 0; i < 2; ++i) {
		packet[2+i*20] = x / 256 / 256 / 256;
		packet[3+i*20] = (x / 256 / 256) % 256;
		packet[4+i*20] = (x / 256) % 256;
		packet[5+i*20] = x % 256;
		packet[6+i*20] = y / 256 / 256 / 256;
		packet[7+i*20] = (y / 256 / 256) % 256;
		packet[8+i*20] = (y / 256) % 256;
		packet[9+i*20] = y % 256;
		
		packet[10+i*20] = packet[11+i*20] = packet[12+i*20] = packet[13+i*20] = 0;
		
		unsigned int dwFlags = (i == 0) ? (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTDOWN)
										: (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTUP);
		
		packet[14+i*20] = dwFlags / 256 / 256 / 256;
		packet[15+i*20] = (dwFlags / 256 / 256) % 256;
		packet[16+i*20] = (dwFlags / 256) % 256;
		packet[17+i*20] = dwFlags % 256;
		
		packet[18+i*20] = packet[19+i*20] = packet[20+i*20] = packet[21+i*20] = 0;
	}
		
	[communicator sendMessage:packet length:42];	
}

- (void)sendMouseDragEventFromPosition:(CGPoint)startPosition toPosition:(CGPoint)endPosition {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	packet = malloc(sizeof(uint8_t) * 42);
	
	packet[0] = 5;
	packet[1] = 2;
	
	for (int i = 0; i < 2; ++i) {
		
		CGPoint serverPosition = (i == 0) ? [self transformClientPositionToServerPosition:startPosition]
										  : [self transformClientPositionToServerPosition:endPosition];
		
		unsigned int x = ceil(serverPosition.x);
		unsigned int y = ceil(serverPosition.y);	
		
		packet[2+i*20] = x / 256 / 256 / 256;
		packet[3+i*20] = (x / 256 / 256) % 256;
		packet[4+i*20] = (x / 256) % 256;
		packet[5+i*20] = x % 256;
		packet[6+i*20] = y / 256 / 256 / 256;
		packet[7+i*20] = (y / 256 / 256) % 256;
		packet[8+i*20] = (y / 256) % 256;
		packet[9+i*20] = y % 256;
		
		packet[10+i*20] = packet[11+i*20] = packet[12+i*20] = packet[13+i*20] = 0;
		
		unsigned int dwFlags = (i == 0) ? (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTDOWN)
										: (MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTUP);
		
		packet[14+i*20] = dwFlags / 256 / 256 / 256;
		packet[15+i*20] = (dwFlags / 256 / 256) % 256;
		packet[16+i*20] = (dwFlags / 256) % 256;
		packet[17+i*20] = dwFlags % 256;
		
		packet[18+i*20] = packet[19+i*20] = packet[20+i*20] = packet[21+i*20] = 0;
	}
	
	[communicator sendMessage:packet length:42];
}

- (void)sendMouseWheelScrollEventFromPosition:(CGPoint)startPosition toPosition:(CGPoint)endPosition {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
	packet = malloc(sizeof(uint8_t) * 42);
	
	packet[0] = 5;
	
	
}



/*

- (void)sendPointerEvent:(MouseButton)button atPosition:(CGPoint)position relativeToView:(UIView*)view pressed:(BOOL)pressed {
	printf("send pointer event !!\n");
	if (packet != nil) {
		free(packet); 
		packet = nil;
	}
	packet = malloc(sizeof(uint8_t) * 42);
	 
	packet[0] = 5; //Indicator of mouse event
	
	float imageWidth = 1024.0;
	float imageHeight = 1024.0 / framebufferWidth * framebufferHeight;
	
	float upper = (768.0 - imageHeight) / 2;
	float xRelativeToImage = position.x;
	float yRelativeToImage = position.y - upper;
	
	
	unsigned int x = ceil(xRelativeToImage * 65535 / imageWidth);
	unsigned int y = ceil(yRelativeToImage * 65535 / imageHeight);
	
	printf("calculated x: %i\n", x);
	printf("calculated y: %i\n", y);
	printf("frame width: %f", view.frame.size.width);
	printf("frame height: %f", view.frame.size.height);

	
	packet[1] = x / 256 / 256 / 256;
	packet[2] = (x / 256 / 256) % 256;
	packet[3] = (x / 256) % 256;
	packet[4] = x % 256;
	packet[5] = y / 256 / 256 / 256;
	packet[6] = (y / 256 / 256) % 256;
	packet[7] = (y / 256) % 256;
	packet[8] = y % 256;
	
	
	if (button == LeftButton || button == RightButton) {
		packet[9] = packet[10] = packet[11] = packet[12] = 0;
	}
	else {
		packet[9] = packet[10] = packet[11] = packet[12] = 0;

	}
 
	unsigned int dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE;
	switch (button) {
		case LeftButton:
			(pressed == TRUE) ? (dwFlags = dwFlags | MOUSEEVENTF_LEFTDOWN) : (dwFlags = dwFlags | MOUSEEVENTF_LEFTUP);
			break;
		case RightButton:
			(pressed == TRUE) ? (dwFlags = dwFlags | MOUSEEVENTF_RIGHTDOWN) : (dwFlags = dwFlags | MOUSEEVENTF_RIGHTUP);
			break;
		default:
			break;
	}

	unsigned int dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTDOWN;
 
	packet[13] = dwFlags / 256 / 256 / 256;
	packet[14] = (dwFlags / 256 / 256) % 256;
	packet[15] = (dwFlags / 256) % 256;
	packet[16] = dwFlags % 256;
	

	
//	packet[17] = packet[18] = packet[19] = packet[20] = 0;
		
//	NSLog(@"MouseEnvent");
//	[communicator sendMessage:packet length:21];
	

}
*/


/*- (void)sendPointerEvent:(MouseButton)button atPosition:(CGPoint)position relativeToView:(UIView*)view pressed:(BOOL)pressed {
	if (packet != nil) {
		packet != nil;
		free(packet);
		packet = nil;
	}
	packet = malloc(sizeof(uint8_t)*6);
	
	printf("Button:%i\n", button);
	
	mouseButtonStatus[button] = pressed;
	
	for (int i = 0; i < button; ++i) {
		mouseButtonStatus[button] = mouseButtonStatus[button] << button;
	}
	
	packet[0] = 5;
	packet[1] = mouseButtonStatus[0];
	for (int i = 1; i < 8; ++i) {
		packet[1] = packet[1] | mouseButtonStatus[i];
	}
	// packet[1] holds the button-mask
	printf("button-mask: %i\n", packet[1]);
	printf("framewidth: %f\n", view.frame.size.width);
	printf("frameheight: %f\n", view.frame.size.height);
	
	float widthRatio = framebufferWidth / view.frame.size.width;
	float heightRatio = framebufferHeight / view.frame.size.height;
	
	position.x = position.x * widthRatio;
	position.y = position.y * heightRatio;
	
	packet[2] = position.x / 256;
	packet[3] = (int)position.x % 256;
	
	packet[4] = position.y / 256;
	packet[5] = (int)position.y % 256;
	
	printf("%i\n", packet[2]);
	printf("%i\n", packet[3]);
	
	[communicator sendMessage:packet length:6];
}*/


-(void)putTextIntoCutBuffer:(NSString*)text {
	if (packet != nil) {
		free(packet);
		packet = nil;
	}
		
	int textLength = [text length]; //Is this the correct length for the textChars?
	
	packet = malloc(sizeof(uint8_t) * (8+textLength));
					
	packet[0] = 6;
	packet[1] = packet[2] = packet[3] = 0;
	
	packet[4] = textLength / 256 / 256 / 256;
	packet[5] = (textLength / 256 / 256) % 256;
	packet[6] = (textLength / 256) % 256;
	packet[7] = textLength % 256;
	
	for (int i = 0; i < textLength; ++i) {
		packet[i+7] = [text UTF8String][i];
	}
	
	[communicator sendMessage:packet length:(8+textLength)];
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

#pragma mark Auxilary Functions

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

- (CGPoint)transformClientPositionToServerPosition:(CGPoint)clientPosition {
	
	float imageWidth = 1024.0;
	float imageHeight = 1024.0 / framebufferWidth * framebufferHeight;
	
	float upper = (768.0 - imageHeight) / 2;
	float xRelativeToImage = clientPosition.x;
	float yRelativeToImage = clientPosition.y - upper;
	
	CGPoint serverPosition = CGPointMake(xRelativeToImage * 65535 / imageWidth, yRelativeToImage * 65535 / imageHeight);
	
	return serverPosition;
}

@end
