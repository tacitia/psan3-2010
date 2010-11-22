//
//  RDPCore.m
//  RDPPrototype
//
//  Createdfile://localhost/Users/Tacitia/Desktop/FYP-RDPPrototype/Classes/RDPCore.m by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDPCore.h"


@implementation RDPCore

@synthesize serverIP;
@synthesize serverPort;
@synthesize viewController;
@synthesize status;
@synthesize communicator;
@synthesize packet;
@synthesize packetLength;

-(int)ParseMessage:(uint8_t*)message OfLength:(int) length{
	//printf("dada");
	//viewController->outputTextView.text = @"1234";
	if(status == 255){
		//connection has already setted up 
	}else{
		printf("parsing message..");
		switch (status) {
			case 1:
				if([self CheckTPKHeader:message OfLength:length]){
					//-----check X.224 CC-----//
					if(message[4] == 6 &&//LI feild, always 6 here
					   message[5] == 0xD0 &&//CC|CDT 1101 0000 for class 0
					   
					   message[6] == 0 &&
					   message[7] == 0 &&//DST-REF 2 bytes 0
					   
					   message[10] == 0)//class option
					{
						serverSRCREF = message[8] * 256 + message[9];
						printf("checked/n");
						
					}else {
						return 0;
					}
					//-----check X.224 CC FINISHED-----//
					//-----Generate ClientMCS Connect Initial PDU with GCC Conference Create Request-----//
					packetLength = 416;
					packet = malloc(sizeof(uint8_t) * packetLength);

					[self GenerateTPKTHeader:packet OfLength:packetLength];
					//-----X.224-----//
					[self GenerateClassZeroDataTPDU];
					//-----X.224 FINISHED-----//
					
					[self GenerateMCSConnectInitialPDU];
					//-----PACKET FINISHED-----//					
					[communicator sendMessage:packet length:packetLength];
					status += 1;
				}else{
					return 0;
				} 
				break;
			case 2: {
				printf("case 2");
				packetLength = 12;
				[self GenerateTPKTHeader:packet OfLength:packetLength];
				[self GenerateClassZeroDataTPDU];
				[self GenerateMCSErectDomainRequestPDU];
				
				[communicator sendMessage:packet length:packetLength];
				status += 1;
			}
				break;
			case 3:
				break;
			default:
				break;
		}
	}
	return 1;
}

-(int)InitConnecting{
	
	communicator = [[NetworkCommunicator alloc] initWithRDPCore:self];
	[communicator setHost:serverIP port:serverPort];
	
	
	//----X.224 connection request packet----//
	packetLength = 11;//in byte
	packet = malloc(sizeof(uint8_t) * packetLength);
	
	//x224Crq started from byte 5 - 11
	
	packet[4] = 6;//LI feild, always 8 here
	packet[5] = 0xE0;//CR|CDT 1110 0000 for class 0
	
	packet[6] = 0;
	packet[7] = 0;//DST-REF 2 bytes 0
	
	SRCREF = 0;
	packet[8] = SRCREF/256;
	packet[9] = SRCREF%256;
	
	packet[10] = 0;//class option
	
	[self GenerateTPKTHeader:packet OfLength:11];

/*	printf("%i\n",packet[0]);
	printf("%i\n",packet[1]);
	printf("%i\n",packet[2]);
	printf("%i\n",packet[3]);
 */
	
	[communicator sendMessage:packet length:11];
	//----X.224 connection request packet finish----//
	
	status = 1;//startConnecting
	
	return 1;
}


-(int)GenerateTPKTHeader:(uint8_t*) incomingPacket OfLength:(int) length{
	
	incomingPacket[0] = 0X03;//0000 0011
	incomingPacket[1] = 0;//Reserved
	
	incomingPacket[2] = length >> 8;
	incomingPacket[3] = length%256;
	
	return 1;
}

-(int)GenerateClassZeroDataTPDU{
	packet[4] = 0x02;
	packet[5] = 0xf0;
	packet[6] = 0x80;
	
	return 1;
}

-(int)GenerateMCSConnectInitialPDU{
	
	//----BER----
	packet[7] = 0x7f; 
	packet[8] = 0x65;
	
	//BER: Type length
	packet[9] = 0x82;
	packet[10] = 0x01;
	packet[11] = 0x2b;
	
	//Connect-Initial::callingDomainSelector
	packet[12] = 0x04;
	packet[13] = 0x01;
	packet[14] = 0x01;
	
	//Connect-Initiall::calledDomainSelector
	packet[15] = 0x04;
	packet[16] = 0x01;
	packet[17] = 0x01;
	
	//Connect-Initial::upwardFlag = TRUE
	packet[18] = 0x01;
	packet[19] = 0x01;
	packet[20] = 0xff;
	
	//Connect-Initial::targetParameters
	packet[21] = 0x30;
	packet[22] = 0x19;
	
	
	packet[23] = 0x02;
	packet[24] = 0x01;
	packet[25] = 0x16;
	packet[26] = 0x02;
	packet[27] = 0x01;
	packet[28] = 0x02;
	packet[29] = 0x02;
	packet[30] = 0x01;
	
	packet[31] = 0x00;
	packet[32] = 0x02;
	packet[33] = 0x01;
	packet[34] = 0x01;
	packet[35] = 0x02;
	packet[36] = 0x01;
	packet[37] = 0x00;
	packet[38] = 0x02;
	packet[39] = 0x01;
	packet[40] = 0x01;
	
	packet[41] = 0x02;
	packet[42] = 0x02;
	packet[43] = 0xff;
	packet[44] = 0xff;
	packet[45] = 0x02;
	packet[46] = 0x01;
	packet[47] = 0x02;
	packet[48] = 0x30;
	packet[49] = 0x19;
	packet[50] = 0x02;
	
	packet[51] = 0x01;
	packet[52] = 0x01;
	packet[53] = 0x02;
	packet[54] = 0x01;
	packet[55] = 0x01;
	packet[56] = 0x02;
	packet[57] = 0x01;
	packet[58] = 0x01;
	packet[59] = 0x02;
	packet[60] = 0x01;
	
	packet[61] = 0x01;
	packet[62] = 0x02;
	packet[63] = 0x01;
	packet[64] = 0x00;
	packet[65] = 0x02;
	packet[66] = 0x01;
	packet[67] = 0x01;
	packet[68] = 0x02;
	packet[69] = 0x02; 
	packet[70] = 0x04;
	
	packet[71] = 0x20;
	packet[72] = 0x02;
	packet[73] = 0x01;
	packet[74] = 0x02;
	packet[75] = 0x30;
	packet[76] = 0x1c;
	packet[77] = 0x02;
	packet[78] = 0x02;
	packet[79] = 0xff;
	packet[80] = 0xff;
	
	packet[81] = 0x02;
	packet[82] = 0x02;
	packet[83] = 0xfc;
	packet[84] = 0x17;
	packet[85] = 0x02;
	packet[86] = 0x02;
	packet[87] = 0xff;
	packet[88] = 0xff;
	packet[89] = 0x02;
	packet[90] = 0x01;
	
	packet[91] = 0x01;
	packet[92] = 0x02;
	packet[93] = 0x01;
	packet[94] = 0x00;
	packet[95] = 0x02;
	packet[96] = 0x01;
	packet[97] = 0x01;
	packet[98] = 0x02;
	packet[99] = 0x02;
	packet[100] = 0xff;
	
	packet[101] = 0xff;
	packet[102] = 0x02;
	packet[103] = 0x01;
	packet[104] = 0x02;
	packet[105] = 0x04;
	packet[106] = 0x82;
	packet[107] = 0x00;
	packet[108] = 0xca;
	
	//PER encoded GCC Connection Data
	packet[109] = 0x00;
	packet[110] = 0x05;	
	packet[111] = 0x00;
	packet[112] = 0x14;
	packet[113] = 0x7c;
	packet[114] = 0x00;
	packet[115] = 0x01;
	packet[116] = 0x80;
	packet[117] = 0xc1;
	packet[118] = 0x00;
	packet[119] = 0x08;
	packet[120] = 0x00;
	packet[121] = 0x10;
	packet[122] = 0x00;
	packet[123] = 0x00;
	packet[124] = 0x01;
	packet[125] = 0xc0;
	packet[126] = 0x44;
	packet[127] = 0x75;
	packet[128] = 0x63;
	packet[129] = 0x61;
	packet[130] = 0x80;
	packet[131] = 0xb3;
	
	//----User Cluster Data----
	//header
	packet[132] = 0x04;
	packet[133] = 0xc0;
	packet[134] = 0x0c;
	packet[135] = 0x00;
	
	//TS_UD_CS_CLUSTER::flags
	packet[136] = 0x0b;
	packet[137] = 0x00;
	packet[138] = 0x00;
	packet[139] = 0x00;
	
	//TS_UD_CS_CLUSTER::RedirectedSessionID
	packet[140] = 0x00;
	packet[141] = 0x00;
	packet[142] = 0x00;
	packet[143] = 0x00;
	
	//----User Core Data----
	//header
	packet[144] = 0x01;
	packet[145] = 0xc0;
	packet[146] = 0x9b;
	packet[147] = 0x00;
	packet[148] = 0x01;
	packet[149] = 0x00;
	packet[150] = 0x08;
	packet[151] = 0x00;
	packet[152] = 0x00;
	packet[153] = 0x04;
	
	packet[154] = 0x00;
	packet[155] = 0x03;
	packet[156] = 0x01;
	packet[157] = 0xca;
	packet[158] = 0x03;
	packet[159] = 0xaa;
	packet[160] = 0x09;
	packet[161] = 0x04;
	packet[162] = 0x00;
	packet[163] = 0x00;
	
	packet[164] = 0x01;
	packet[165] = 0x00;
	packet[166] = 0x00;
	packet[167] = 0x00;
	packet[168] = 0x69;
	packet[169] = 0x00;
	packet[170] = 0x70;
	packet[171] = 0x00;
	packet[172] = 0x68;
	packet[173] = 0x00;
	
	packet[174] = 0x6f;
	packet[175] = 0x00;
	packet[176] = 0x6e;
	packet[177] = 0x00;
	packet[178] = 0x65;
	
	// 21 0x00
	memset(packet + 179, 0x00, 21);
	
	packet[200] = 0x04;
	packet[201] = 0x00;
	packet[202] = 0x00;
	packet[203] = 0x00;
	packet[204] = 0x00;
	packet[205] = 0x00;
	packet[206] = 0x00;
	packet[207] = 0x00;
	packet[208] = 0x0c;
	packet[209] = 0x00;
	
	packet[210] = 0x00;
	packet[211] = 0x00;
	
	//64 0x00
	memset(packet + 212, 0x00, 64);
	
	packet[276] = 0x01;
	packet[277] = 0xca;
	packet[278] = 0x01;
	packet[279] = 0x00;
	packet[280] = 0x00;
	packet[281] = 0x00;
	packet[282] = 0x00;
	packet[283] = 0x00;
	packet[284] = 0x10;
	packet[285] = 0x00;
	
	packet[286] = 0x08;
	packet[287] = 0x00;
	packet[288] = 0x20;
	
	//9 0x00
	memset(packet + 289, 0x00, 9);
	
	packet[298] = 0x01;
	packet[299] = 0x02;
	packet[300] = 0xc0;
	packet[301] = 0x0c;
	packet[302] = 0x00;
	packet[303] = 0x03;
	
	//7 0x00
	memset(packet + 304, 0x00, 7);
	
	return 1;
}

/*
-(int)GenerateMCSConnectInitialPDU{
	//-----BER-----//
	//TYPE//
	packet[7] = 0x7f;
	packet[8] = 0x65;
	
	//LENGTH//
	packet[9] = 0x82;
	packet[10] = 0x01;
	packet[11] = 0x94;
	
	//Connect-Initial::callingDomainSelector//
	packet[12] = 0x04;
	packet[13] = 0x01;
	packet[14] = 0x01;
	
	
	//Connect-Initial::calledDomainSelector//
	packet[15] = 0x04;
	packet[16] = 0x01;
	packet[17] = 0x01;
	
	//Connect-Initial::upwardFlag = TRUE//
	packet[18] = 0x01;
	packet[19] = 0x01;
	packet[20] = 0xff;
	
	packet[21] = 0x30; 
	packet[22] = 0x19;
	packet[23] = 0x02;
	packet[24] = 0x01;
	packet[25] = 0x22;
	packet[26] = 0x02;
	packet[27] = 0x01;
	packet[28] = 0x02;
	packet[29] = 0x02;
	packet[30] = 0x01;
	packet[31] = 0x00;
	
	packet[32] = 0x02; 
	packet[33] = 0x01;
	packet[34] = 0x01;
	packet[35] = 0x02;
	packet[36] = 0x01;
	packet[37] = 0x00;
	packet[38] = 0x02;
	packet[39] = 0x01;
	packet[40] = 0x01;
	packet[41] = 0x02;
	packet[42] = 0x02;
	packet[43] = 0xff;
	packet[44] = 0xff;
	packet[45] = 0x02;
	packet[46] = 0x01;
	packet[47] = 0x02;
	
	packet[48] = 0x30;
	packet[49] = 0x19;
	packet[50] = 0x02;
	packet[51] = 0x01;
	packet[52] = 0x01;
	packet[53] = 0x02;
	packet[54] = 0x01;
	packet[55] = 0x01; 
	packet[56] = 0x02;
	packet[57] = 0x01;
	packet[58] = 0x01;
	packet[59] = 0x02;
	packet[60] = 0x01;
	packet[61] = 0x01;
	packet[62] = 0x02;
	packet[63] = 0x01;
	
	packet[64] = 0x00; 
	packet[65] = 0x02;
	packet[66] = 0x01;
	packet[67] = 0x01;
	packet[68] = 0x02;
	packet[69] = 0x02;
	packet[70] = 0x04;
	packet[71] = 0x20;
	packet[72] = 0x02;
	packet[73] = 0x01;
	packet[74] = 0x02;
	packet[75] = 0x30;
	packet[76] = 0x1c;
	packet[77] = 0x02;
	packet[78] = 0x02;
	packet[79] = 0xff;
	
	packet[80] = 0xff;
	packet[81] = 0x02;
	packet[82] = 0x02;
	packet[83] = 0xfc;
	packet[84] = 0x17;
	packet[85] = 0x02;
	packet[86] = 0x02;
	packet[87] = 0xff;
	packet[88] = 0xff;
	packet[89] = 0x02;
	packet[90] = 0x01;
	packet[91] = 0x01;
	packet[92] = 0x02;
	packet[93] = 0x01;
	packet[94] = 0x00;
	packet[95] = 0x02;
	
	packet[96] = 0x01;
	packet[97] = 0x01;
	packet[98] = 0x02;
	packet[99] = 0x02;
	packet[100] = 0xff;
	packet[101] = 0xff;
	packet[102] = 0x02;
	packet[103] = 0x01;
	packet[104] = 0x02;
	packet[105] = 0x04;
	packet[106] = 0x82;
	packet[107] = 0x01;
	packet[108] = 0x33;
	packet[109] = 0x00;
	packet[110] = 0x05;
	packet[111] = 0x00;
	
	packet[112] = 0x14;
	packet[113] = 0x7c;
	packet[114] = 0x00;
	packet[115] = 0x01;
	packet[116] = 0x81;
	packet[117] = 0x2a;
	packet[118] = 0x00;
	packet[119] = 0x08;
	packet[120] = 0x00;
	packet[121] = 0x10;
	packet[122] = 0x00;
	packet[123] = 0x01;
	packet[124] = 0xc0;
	packet[125] = 0x00;
	packet[126] = 0x44;
	packet[127] = 0x75;
	
	packet[128] = 0x63;
	packet[129] = 0x61;
	packet[130] = 0x81;
	packet[131] = 0x1c;
	
	//----Client Core Data----
	//header
	packet[132] = 0x01;
	packet[133] = 0xc0;
	packet[134] = 0xd8;
	packet[135] = 0x00;
	
	//version
	packet[136] = 0x04;
	packet[137] = 0x00;
	packet[138] = 0x08;
	packet[139] = 0x00;
	
	//desktopWidth = 1024, desktopHeight = 768
	packet[140] = 0x00;
	packet[141] = 0x04;
	packet[142] = 0x00;
	packet[143] = 0x03;
	
	packet[144] = 0x01;
	packet[145] = 0xca;
	packet[146] = 0x03;
	packet[147] = 0xaa;
	
	//keyboardLayout = English(US)
	packet[148] = 0x09;
	packet[149] = 0x04;
	packet[150] = 0x00;
	packet[151] = 0x00;
	
	//clientBuild = 3790
	packet[152] = 0xce;
	packet[153] = 0x0e;
	packet[154] = 0x00;
	packet[155] = 0x00;
	
	//clientName = ELTONS-TEST2
	packet[156] = 0x45;
	packet[157] = 0x00;
	packet[158] = 0x4c;
	packet[159] = 0x00;
	
	packet[160] = 0x54;
	packet[161] = 0x00;
	packet[162] = 0x4f;
	packet[163] = 0x00;
	packet[164] = 0x4e;
	packet[165] = 0x00;
	packet[166] = 0x53;
	packet[167] = 0x00;
	packet[168] = 0x2d;
	packet[169] = 0x00;
	packet[170] = 0x44;
	packet[171] = 0x00;
	packet[172] = 0x45;
	packet[173] = 0x00;
	packet[174] = 0x56;
	packet[175] = 0x00;
	
	packet[176] = 0x32;
	memset(packet + 177, 0x00, 11);
	//packet[177] = 0x00;
	//packet[178] = 0x00;
	//packet[179] = 0x00;
	//packet[180] = 0x00;
	//packet[181] = 0x00;
	//packet[182] = 0x00;
	//packet[183] = 0x00;
	//packet[184] = 0x00;
	//packet[185] = 0x00;
	//packet[186] = 0x00;
	//packet[187] = 0x00;
	
	//keyboardType, keyboardSubtype and keyboardFunctionKey
	packet[188] = 0x04;
	memset(packet + 189, 0x00, 7);
	//packet[189] = 0x00;
	//packet[190] = 0x00;
	//packet[191] = 0x00;
	
	//packet[192] = 0x00 
	//packet[193] = 0x00 
	//packet[194] = 0x00 
	//packet[195] = 0x00 
	packet[196] = 0x0c;
	memset(packet + 197, 0x00, 67);//IME file name
	
	packet[264] = 0x01;
	packet[265] = 0xca;
	packet[266] = 0x01;
	
	memset(packet + 267, 0x00, 5);
	
	packet[272] = 0x18;
	packet[273] = 0x00;
	packet[274] = 0x07;
	packet[275] = 0x00;
	packet[276] = 0x01;
	packet[277] = 0x00;
	packet[278] = 0x36;
	packet[279] = 0x00;
	packet[280] = 0x39;
	packet[281] = 0x00;
	packet[282] = 0x37;
	packet[283] = 0x00;
	packet[284] = 0x31;
	packet[285] = 0x00;
	packet[286] = 0x32;
	packet[287] = 0x00;
	
	packet[288] = 0x2d;
	packet[289] = 0x00;
	packet[290] = 0x37;
	packet[291] = 0x00;
	packet[292] = 0x38;
	packet[293] = 0x00;
	packet[294] = 0x33;
	packet[295] = 0x00;
	packet[296] = 0x2d;
	packet[297] = 0x00;
	packet[298] = 0x30;
	packet[299] = 0x00;
	packet[300] = 0x33;
	packet[301] = 0x00;
	packet[302] = 0x35;
	packet[303] = 0x00;
	
	packet[304] = 0x37;
	packet[305] = 0x00;
	packet[306] = 0x39;
	packet[307] = 0x00;
	packet[308] = 0x37;
	packet[309] = 0x00;
	packet[310] = 0x34;
	packet[311] = 0x00;
	packet[312] = 0x2d;
	packet[313] = 0x00;
	packet[314] = 0x34;
	packet[315] = 0x00;
	packet[316] = 0x32;
	packet[317] = 0x00;
	packet[318] = 0x37;
	packet[319] = 0x00;
	
	packet[320] = 0x31;
	packet[321] = 0x00;
	packet[322] = 0x34;
	
	memset(packet + 323, 0x00, 21);
	
	packet[344] = 0x01;
	packet[345] = 0x00;
	packet[346] = 0x00;
	packet[347] = 0x00;
	packet[348] = 0x04;
	packet[349] = 0xc0;
	packet[350] = 0x0c;
	packet[351] = 0x00;
	
	packet[352] = 0x0d;
	packet[353] = 0x00;
	packet[354] = 0x00;
	packet[355] = 0x00;
	packet[356] = 0x00;
	packet[357] = 0x00;
	packet[358] = 0x00;
	packet[359] = 0x00;
	
	//----Client Security Data----
	//Header
	packet[360] = 0x02;
	packet[361] = 0xc0;
	packet[362] = 0x0c;
	packet[363] = 0x00;
	
	//encryptionMethods = ALL
	packet[364] = 0x1b;
	packet[365] = 0x00;
	packet[366] = 0x00;
	packet[367] = 0x00;
	
	//expEncryptionMethods = 0
	packet[368] = 0x00;
	packet[369] = 0x00;
	packet[370] = 0x00;
	packet[371] = 0x00;
	
	//----Client Network Data----
	//Header
	packet[372] = 0x03;
	packet[373] = 0xc0;
	packet[374] = 0x2c;
	packet[375] = 0x00;
	
	//TS_UD_CS_NET::channelCount = 3
	packet[376] = 0x03;
	packet[377] = 0x00;
	packet[378] = 0x00;
	packet[379] = 0x00;
	
	//CHANNEL_DEF::name = "rdpdr"
	packet[380] = 0x72;
	packet[381] = 0x64;
	packet[382] = 0x70;
	packet[383] = 0x64;
	packet[384] = 0x72;
	packet[385] = 0x00;
	packet[386] = 0x00;
	packet[387] = 0x00;
	
	//CHANNEL_DEF::options = CHANNEL_OPTION_INITIALIZED | CHANNEL_OPTION_COMPRESS_RDP
	packet[388] = 0x00;
	packet[389] = 0x00;
	packet[390] = 0x80;
	packet[391] = 0x80;
	
	//CHANNEL_DEF::name = "cliprdr"
	packet[392] = 0x63;
	packet[393] = 0x6c;
	packet[394] = 0x69;
	packet[395] = 0x70;
	packet[396] = 0x72;
	packet[397] = 0x64;
	packet[398] = 0x72;
	packet[399] = 0x00;
	
	
	//CHANNEL_DEF::options = CHANNEL_OPTION_INITIALIZED | CHANNEL_OPTION_ENCRYPT_RDP |
	//CHANNEL_OPTION_COMPRESS_RDP | CHANNEL_OPTION_SHOW_PROTOCOL	
	packet[400] = 0x00;
	packet[401] = 0x00;
	packet[402] = 0xa0;
	packet[403] = 0xc0;
	
	//CHANNEL_DEF::name = "rdpsnd"
	packet[404] = 0x72;
	packet[405] = 0x64;
	packet[406] = 0x70;
	packet[407] = 0x73;
	packet[408] = 0x6e;
	packet[409] = 0x64;
	packet[410] = 0x00;
	packet[411] = 0x00;
	
	//CHANNEL_DEF::options = CHANNEL_OPTION_INITIALIZED | CHANNEL_OPTION_ENCRYPT_RDP
	packet[412] = 0x00;
	packet[413] = 0x00;
	packet[414] = 0x00;
	packet[415] = 0xc0;
	
	return 1;
}
 */

-(int)GenerateMCSErectDomainRequestPDU{
	packet[7] = 0x04;
	packet[8] = 0x01;
	packet[9] = 0x00;
	packet[10] = 0x01;
	packet[11] = 0x00; 
	
	return 1;
}

-(bool)CheckTPKHeader:(uint8_t*) incomingPacket OfLength:(int) length{
	return (incomingPacket[0] == 0x03 && incomingPacket[2] == length >> 8 && incomingPacket[3] == length%256);
}

-(id)initWithViewController:(RDPPrototypeViewController*)viewControllerPtr {
	[super init];
	self.viewController = viewControllerPtr;
	self.status = 0;
	self.communicator = nil;
	self.serverIP = nil;
	self.serverPort = 0;
	
	self.packetLength = 0;
	self.packet = NULL;
	
	return self;
}





@end
