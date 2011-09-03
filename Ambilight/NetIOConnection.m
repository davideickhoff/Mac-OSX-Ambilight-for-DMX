
#import "NetIOConnection.h"

#define TAG_MSG 12

static NetIOConnection* _connection;

@implementation NetIOConnection

@synthesize delegate, socket, commands;
@synthesize synchron, responseAction, responseTarget;

-(id)init {
	self = [super init];
    
	return self;
}


- (void)sendCommand:(NSString *)commandString {
	if (!synchron) {
        //NSLog(@"connection: sending %@", commandString);
        NSString * stringToSend = [NSString stringWithFormat:@"%@\n",commandString];
        
        NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
        
        [socket writeData:dataToSend withTimeout:10.0 tag:TAG_MSG];
    }
}

- (void)sendSynchronCommand: (NSString*)commandString target: (id)target action:(NSString*)action {
    synchron = TRUE;
    self.responseAction = action;
    self.responseTarget = target;
    //NSLog(@"connection: sending synchron %@", commandString);

    NSString * stringToSend = [NSString stringWithFormat:@"%@\n",commandString];    
    NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
    
    [socket writeData:dataToSend withTimeout:10.0 tag:TAG_MSG];
    [socket readDataWithTimeout:5.0 tag:TAG_MSG];
}


-(void)connect {
    socket = [[AsyncSocket alloc] initWithDelegate:self];    
	[socket connectToHost:@"192.168.0.90" onPort:2701 withTimeout: 2.0 error:nil];
}

- (void)disconnect {
    [socket disconnect];
}

#pragma mark network methods

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    [self.responseTarget performSelector:NSSelectorFromString(self.responseAction) withObject:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
    synchron = FALSE;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"connection: will connect");
	return TRUE;
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSLog(@"connection: established");
	[delegate connectionDidConnect:self];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	NSLog(@"connection: disconnected");
	[delegate connectionDidEnd:self];
}


+(NetIOConnection*) instance {
    @synchronized([NetIOConnection class]) {
        if ( _connection == NULL ) {
            _connection = [[NetIOConnection alloc] init];
        }
    }
    
	return _connection;
}

+(void) reset {
    _connection = [[NetIOConnection alloc] init];
}



@end
