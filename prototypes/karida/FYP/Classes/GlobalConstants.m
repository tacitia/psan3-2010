//
//  GlobalConstants.m
//  RDPPrototype
//
//  Created by Guo Hua on 27/04/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "GlobalConstants.h"

#pragma mark Virtual Key Codes

const int VK_LBUTTON = 0x01;
const int VK_RBUTTON = 0x02;

const int VK_CANCEL = 0x03; //Control-breaking process
const int VK_BACK = 0x08;
const int VK_TAB = 0x09;
const int VK_RETURN = 0x0D; //Enter
const int VK_SHIFT = 0x10;
const int VK_CONTROL = 0x11;
const int VK_MENU = 0x12; //ALT key
const int VK_LMENU = 0xA4;
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
const int VK_LWIN = 0x5B;
const int VK_F1 = 70;

#pragma mark MouseEvent Constants

const int MOUSEEVENTF_ABSOLUTE = 0x8000;
const int MOUSEEVENTF_MOVE = 0x0001;
const int MOUSEEVENTF_LEFTDOWN = 0x0002;
const int MOUSEEVENTF_LEFTUP = 0x0004;
const int MOUSEEVENTF_RIGHTDOWN = 0x0008;
const int MOUSEEVENTF_RIGHTUP = 0x0010;
const int MOUSEEVENTF_WHEEL = 0x0800;