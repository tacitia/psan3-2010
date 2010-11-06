//
//  RDPCore.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class RDPCore;

@interface RDPCore{

}

-(int)RDPackageParse:(NSsting*) message;
-(int)RDPConnectionSetUp;
-(RDPCore*)initRDPCore;   


@end
