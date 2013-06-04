// Copyright 2012 Little Joy Software. All rights reserved.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
// THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LjsGoogleReply.h"
#import "Lumberjack.h"
#import "LjsGoogleGlobals.h"
#import "SBJson.h"
#import "SBJSON+LjsAdditions.h"

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation LjsGoogleReply

@synthesize dictionary;

#pragma mark Memory Management


- (id) initWithReply:(NSString *) aReply 
               error:(NSError *__autoreleasing *)error {
  self = [super init];
  if (self) {
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    self.dictionary = [parser objectWithString:aReply
                                   error:error];
  }
  return self;
}

- (NSString *) status {
  if (self.dictionary == nil) {
    return LjsGoogleStatusLocalParseError; 
  }
  return [self.dictionary objectForKey:LjsGooglePlacesKeyStatus];
}

- (BOOL) statusHasResults {
  return [LjsGoogleStatusOK isEqualToString:[self status]];
}

- (BOOL) statusNoResults {
  return [LjsGoogleStatusNotFound isEqualToString:[self status]];
}

- (BOOL) statusRejected {
  return [self statusNoResults] == NO && [self statusHasResults] == NO;
}

- (BOOL) statusOverQueryLimit {
  return [LjsGoogleStatusOverQueryLimit isEqualToString:[self status]];
}

- (BOOL) statusRequestDenied {
  return [LjsGoogleStatusRequestDenied isEqualToString:[self status]];
}

- (BOOL) statusInvalidRequest {
  return [LjsGoogleStatusInvalidRequest isEqualToString:[self status]];
}

- (BOOL) statusLocalParseError {
  return [LjsGoogleStatusLocalParseError isEqualToString:[self status]];
}


@end
