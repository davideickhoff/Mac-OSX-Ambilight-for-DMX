

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@protocol NetIOConnectionDelegate
-(void)connection:(id)sender didReceive:(NSData*)data;
-(void)connectionDidConnect:(id)sender;
-(void)connectionDidEnd:(id)sender;
@end


@interface NetIOConnection : NSObject<NSStreamDelegate> {
	AsyncSocket *socket;
	id<NetIOConnectionDelegate> delegate;
    NSArray *commands;
    
    BOOL synchron;
    id responseTarget;
    NSString* responseAction;
}

@property (nonatomic, retain) AsyncSocket *socket;
@property (nonatomic, retain) id<NetIOConnectionDelegate> delegate;
@property (nonatomic, retain) NSArray *commands;

@property (assign) BOOL synchron;
@property (nonatomic, retain) id responseTarget;
@property (nonatomic, retain) NSString* responseAction;


+(NetIOConnection*) instance;
+(void) reset;

-(void)connect;
-(void)disconnect;

- (void)sendCommand:(NSString*)commandString;
- (void)sendSynchronCommand: (NSString*)commandString target: (id)target action:(NSString*)action;

@end
