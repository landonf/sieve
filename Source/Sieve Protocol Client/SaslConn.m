/* Copyright (c) 1010 Sven Weidauer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and 
 * to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the 
 * Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
 * THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "SaslConn.h"
#import "AsyncSocket.h"

#include <sasl/sasl.h>

NSString * const kSASLErrorDomain = @"SaslErrorDomain";

@interface SaslConn ()
@property (readwrite, retain) NSString *mechanism;
@property (readwrite, retain) NSMutableArray *authComponents;

- (NSData *) storeAuthComponent: (NSString *) value;

@end

@implementation SaslConn
@synthesize mechanism;
@synthesize realm, user, password, authName;
@synthesize authComponents;

static sasl_callback_t SaslCallbacks[] = { 
    { SASL_CB_GETREALM, NULL, NULL }, 
    { SASL_CB_USER, NULL, NULL }, 
    { SASL_CB_AUTHNAME, NULL, NULL }, 
    { SASL_CB_PASS, NULL, NULL }, 
    { SASL_CB_GETOPT, NULL, NULL }, 
    { SASL_CB_CANON_USER, NULL, NULL }, 
    { SASL_CB_LIST_END, NULL, NULL } 
}; 


+ (void) initialize;
{
    if (self == [SaslConn class]) {
        sasl_client_init( SaslCallbacks );
        atexit( sasl_done );
    }
}

- (NSData *) storeAuthComponent: (NSString *) value;
{
    const char *str = [value UTF8String];
    unsigned length = strlen( str );
    
    NSData *result = [NSData dataWithBytes: str length: length];
    
    if (nil == authComponents) {
        [self setAuthComponents: [NSMutableArray arrayWithObject: result]];
    } else {
        [authComponents addObject: result];
    }
    
    return result;
}

- initWithService: (NSString *) service server: (NSString *) serverFQDN 
           socket: (AsyncSocket *) socket flags: (SaslConnFlags) flags;
{
    NSString *localIp = [NSString stringWithFormat: @"%@;%d", [socket localHost], [socket localPort]];
    NSString *remoteIp = [NSString stringWithFormat: @"%@;%d", [socket connectedHost], [socket connectedPort]];

    return [self initWithService: service server: serverFQDN localIp: localIp remoteIp: remoteIp flags: flags];
}

- initWithService: (NSString *) service server: (NSString *) serverFQDN 
          localIp: (NSString *) localIp remoteIp: (NSString *) remoteIp
            flags: (SaslConnFlags) flags;
{
    if (nil == [super init]) return nil;
    
    unsigned saslFlags = 0;
    if (flags & SaslConnNoAnonymous) saslFlags |= SASL_SEC_NOANONYMOUS;
    if (flags & SaslConnNoPlaintext) saslFlags |= SASL_SEC_NOPLAINTEXT;
    if (flags & SaslConnNeedProxy) saslFlags |= SASL_NEED_PROXY;
    if (flags & SaslConnSuccessData) saslFlags |= SASL_SUCCESS_DATA;
    
    lastError = sasl_client_new([service UTF8String], [serverFQDN UTF8String], [localIp UTF8String], 
                                [remoteIp UTF8String], NULL, saslFlags, (sasl_conn_t **)&conn );
    if (SASL_OK != lastError) {
        const char *errstring = sasl_errstring( lastError, NULL, NULL );
        NSLog( @"sasl error: %d: %s", lastError, errstring );
        [self release];
        return nil;
    }
    
    return self;
}

-(void) fillPrompts: (sasl_interact_t *) prompts;
{
    for (int i = 0; prompts[i].id != SASL_CB_LIST_END; i++) {
        NSString *actualValue = nil;
        switch (prompts[i].id) {
            case SASL_CB_AUTHNAME:
                actualValue = authName;
                break;
                
            case SASL_CB_PASS:
                actualValue = password;
                break;
                
            case SASL_CB_GETREALM:
                actualValue = realm;
                break;
                
            case SASL_CB_USER:
                actualValue = user;
                break;
             
            default:
                NSAssert( NO, @"Error: unknown callback code %x", prompts[i].id );
                break;
        }
        
        if (nil != actualValue) {
            NSData *result = [self storeAuthComponent: actualValue];
            prompts[i].result = [result bytes];
            prompts[i].len = [result length];
        } else {
            prompts[i].result = "";
            prompts[i].len = 0;
        }
        
    }    
}

- (SaslConnStatus) startWithMechanisms: (NSString *) mechList clientOut: (NSData **) outData;
{
    sasl_interact_t *prompts = NULL;
    const char *clientOut = NULL;
    unsigned len = 0;
    const char *mech = NULL;
    
    const char **clientOutParam = &clientOut;
    unsigned *lenParam = &len;
    
    if (NULL == outData) {
        lenParam = NULL;
        clientOutParam = NULL;
    }

    lastError = 0;
    for (;;) {
        lastError = sasl_client_start( conn, [mechList UTF8String], &prompts, clientOutParam, lenParam, &mech );
        
        if (lastError != SASL_INTERACT) break;

        [self fillPrompts: prompts];
    }
    
    if (lastError != SASL_CONTINUE) {
        [self setAuthComponents: nil];
    }
    
    if (lastError != SASL_OK && lastError != SASL_CONTINUE) {
        const char *err = sasl_errdetail( conn );
        const char *errstring = sasl_errstring( lastError, "de", NULL );
        NSLog( @"sasl error: %d: %s: %s", lastError, errstring, err );
        return SaslConnFailed;
    }
    
    if (NULL != outData) {
        if (NULL != clientOut) *outData = [NSData dataWithBytesNoCopy: (void *)clientOut length: len freeWhenDone: NO];
        else *outData = nil;
    }
    
    [self setMechanism: [NSString stringWithUTF8String: mech]];
    
    return (lastError == SASL_OK) ? SaslConnSuccess : SaslConnContinue;
}

- (SaslConnStatus) continueWithServerData: (NSData *) serverData clientOut: (NSData **) outData;
{
    const char *bytes = "";
    unsigned length = 0;
    
    if (nil != serverData) {
        bytes = [serverData bytes];
        length = [serverData length];
    }

    sasl_interact_t *prompts = NULL;
    const char *clientOut = NULL;
    unsigned len = 0;
    
    lastError = 0;
    for (;;) {
        lastError = sasl_client_step( conn, bytes, length, &prompts, &clientOut, &len );
        
        if (lastError != SASL_INTERACT) break;

        [self fillPrompts: prompts];
    }

    if (lastError != SASL_CONTINUE) {
        [self setAuthComponents: nil];
    }
    
    if (lastError != SASL_OK && lastError != SASL_CONTINUE) {
        const char *err = sasl_errdetail( conn );
        const char *errstring = sasl_errstring( lastError, "de", NULL );
        NSLog( @"sasl error: %d: %s: %s", lastError, errstring, err );

        return SaslConnFailed;
    }
    
    if (NULL != outData) {
        if (NULL != clientOut) *outData = [NSData dataWithBytesNoCopy: (void *)clientOut length: len freeWhenDone: NO];
        else *outData = nil;
    }

    return (lastError == SASL_OK) ? SaslConnSuccess : SaslConnContinue;
}

- (SaslConnStatus) finishWithServerData: (NSData *) serverData;
{
    return [self continueWithServerData: serverData clientOut: NULL];
}

- (NSData *) encodeData: (NSData *) inData;
{
    unsigned outLen = 0;
    const char *outData = NULL;
    
    lastError = sasl_encode( conn, [inData bytes], [inData length], &outData, &outLen );
    if (SASL_OK != lastError) return nil;
    
    return [NSData dataWithBytesNoCopy: (void *)outData length: outLen freeWhenDone: NO];
}


- (NSData *) decodeData: (NSData *) inData;
{
    unsigned outLen = 0;
    const char *outData = NULL;
    
    lastError = sasl_decode( conn, [inData bytes], [inData length], &outData, &outLen );
    if (SASL_OK != lastError) return nil;
    
    return [NSData dataWithBytesNoCopy: (void *)outData length: outLen freeWhenDone: NO];    
}

- (BOOL) needsToEncodeData;
{
    const sasl_ssf_t *ssf = NULL;
    lastError = sasl_getprop( conn, SASL_SSF, (const void **)&ssf );
    if (SASL_OK != lastError) return YES;
    
    return *ssf != 0;
}

- (void) dealloc;
{
    if (NULL != conn) {
        sasl_dispose( (sasl_conn_t **)&conn );
    }
    
    [self setUser: nil];
    [self setPassword: nil];
    [self setRealm: nil];
    [self setAuthName: nil];
    [self setMechanism: nil];
    [self setAuthComponents: nil];
    
    [super dealloc];
}

- (NSError *) lastError;
{
    if (lastError == SASL_OK) {
        return nil;
    }

    NSString *languages = [[NSLocale preferredLanguages] componentsJoinedByString:  @","];
    const char *errString = sasl_errstring( lastError, [languages UTF8String], NULL );
    NSString *description = [NSString stringWithUTF8String: errString];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: description, NSLocalizedDescriptionKey, nil];
    
    return [NSError errorWithDomain: kSASLErrorDomain code: lastError userInfo: userInfo];
}

@end
