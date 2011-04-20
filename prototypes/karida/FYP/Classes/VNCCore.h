
//
//  VNCCore.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommunicator.h"
#import "RDPPrototypeViewController.h"

struct PixelFormat {
	int bitPerPixel;
	int depth;
	int bigEndianFlag;
	int trueColorFlag;
	int redMax;
	int greenMax;
	int blueMax;
	int redShift;
	int greenShift;
	int blueShift;
};
struct RectPixel {
	int x;
	int y;
	int width;
	int height;
	int encoding;
};

typedef enum {
	Back_Space,
	Tab,
	Return,
	Escape,
	Insert,
	Delete,
	Home,
	End,
	Page_Up,
	Page_Down,
	Left,
	Right,
	Up,
	Down,
	Scroll_Lock,
	SysReq,
	Shift_L,
	Shift_R,
	Ctrl_L,
	Ctrl_R,
	Caps_Lock,
	Meta_L,
	Meta_R,
	Alt_L,
	Alt_R,
	
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	
	Space,
	Exclam, //!
	Quotedbl, //???
	Numbersign, //#
	Dollar, //$
	Percent, //%
	Ampersand, //???
	Apostrophe, //'
	Parenleft, //(
	Parenright, //)
	Asterisk, //*
	Plus, 
	Comma,
	Minus,
	Period,
	Slash,
	Colon,
	Semicolon,
	Less,
	Equal,
	Greater,
	Question,
	At,
	Bracketleft,
	Backslash,
	Bracketright,
	Asciicircum, //^
	Underscore,
	Grave,//' (The one on the right of the keyboard)
	Braceleft, //(
	Braceright, //)
	Bar,
	Asciitilde, //~
	
	Num_0,
	Num_1,
	Num_2,
	Num_3,
	Num_4,
	Num_5,
	Num_6,
	Num_7,
	Num_8,
	Num_9,
	
	Char_A,
	Char_B,
	Char_C,
	Char_D,
	Char_E,
	Char_F,
	Char_G,
	Char_H,
	Char_I,
	Char_J,
	Char_K,
	Char_L,
	Char_M,
	Char_N,
	Char_O,
	Char_P,
	Char_Q,
	Char_R,
	Char_S,
	Char_T,
	Char_U,
	Char_V,
	Char_W,
	Char_X,
	Char_Y,
	Char_Z,
	
	Char_a,
	Char_b,
	Char_c,
	Char_d,
	Char_e,
	Char_f,
	Char_g,
	Char_h,
	Char_i,
	Char_j,
	Char_k,
	Char_l,
	Char_m,
	Char_n,
	Char_o,
	Char_p,
	Char_q,
	Char_r,
	Char_s,
	Char_t,
	Char_u,
	Char_v,
	Char_w,
	Char_x,
	Char_y,
	Char_z,		
} KeySym;

typedef enum {
	LeftButton,
	MiddleButton,
	RightButton,
	WheelUp,
	WheelDown
} MouseButton;

@class RDPPrototypeViewController;

@interface VNCCore : NSObject {
	
	NSString* serverIP;
	int serverPort;
	RDPPrototypeViewController* viewController;
	NetworkCommunicator* communicator;
	int packetLength;
	uint8_t* packet;
	int status;
	int setupStatus;//used in serverinit msg
	int recievingStatus;
	
	uint8_t* serverVer;
	uint8_t* challange;
	//UIImage* display;
	unsigned char *displayArray;
	uint8_t* secTypes;
	int numOfSecTypes;
	int count;
	
	int framebufferWidth;
	int framebufferHeight;
	int numOfRects;
	int currentRectID;
	struct RectPixel currentRects;
	
	NSString* serverName;
	struct PixelFormat pixelFormat;
	
	uint8_t* mouseButtonStatus;
}

@property (nonatomic, retain) NSString* serverIP;
@property (nonatomic) int serverPort;
@property (nonatomic, retain) RDPPrototypeViewController* viewController;
@property (nonatomic, retain) NetworkCommunicator* communicator;
@property (nonatomic) int packetLength;
@property (nonatomic) uint8_t* packet;
@property (nonatomic) int status;
@property (nonatomic) uint8_t* serverVer;
//@property (nonatomic, retain) UIImage* display;
@property (nonatomic) unsigned char* displayArray;
@property (nonatomic) int numOfSecTypes;
@property (nonatomic) int count;
@property (nonatomic) uint8_t* challange;
@property (nonatomic) uint8_t* secTypes;
@property (nonatomic) int framebufferWidth;
@property (nonatomic) int framebufferHeight;
@property (nonatomic, retain) NSString* serverName;
@property (nonatomic) struct PixelFormat pixelFormat;
@property (nonatomic) int setupStatus;
@property (nonatomic) int recievingStatus;
@property (nonatomic) int numOfRects;
@property (nonatomic) struct RectPixel currentRects;
@property (nonatomic) int currentRectID;
@property (nonatomic) uint8_t* mouseButtonStatus;

-(int)initConnection;
-(id)initWithViewController:(RDPPrototypeViewController *)viewControllerPtr;
-(int)parseMessage:(uint8_t*)message ofLength:(int)length;
-(int)updateImage;


- (void)sendLeftClickEventAtPosition:(CGPoint)position;
- (void)sendRightClickEventAtPosition:(CGPoint)position;
- (void)sendMouseDragEventFromPosition:(CGPoint)startPosition toPosition:(CGPoint)endPosition;

//Send keyboard events
- (void)sendString:(NSString*)string;
- (void) sendCtrlPlusChar:(char)character;
- (void) sendTab;
- (void) sendAltPlusTab;
- (void) sendAltPlusF4;
- (void) sendCtrlPlusF4;
- (void) sendCtrlPlusSpace;
- (void) sendSingleKeyEventWithKey:(int)key pressed:(BOOL)pressed;
- (void) minimizeCurrentActiveWindow;
- (void) maximizeCurrentActiveWindow;

@end
