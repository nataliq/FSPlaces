//
//  AsyncConnection.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "AsyncConnection.h"

@interface AsyncConnection ()

@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* responseData;

@end

@implementation AsyncConnection

- (id)initWithUrl:(NSURL*)url andComplitionBlock:(ComplitionBlock)block
{
    self = [super init];
    if (self) {
        self.url = url;
        self.block = block;
        self.responseData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Finish" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"finishStatus"]];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    dispatch_async(dispatch_get_main_queue(), self.block);
}

@end
