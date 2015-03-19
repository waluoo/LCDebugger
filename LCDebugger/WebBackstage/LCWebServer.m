//
//
//      _|          _|_|_|
//      _|        _|
//      _|        _|
//      _|        _|
//      _|_|_|_|    _|_|_|
//
//
//  Copyright (c) 2014-2015, Licheng Guo. ( http://nsobject.me )
//  http://github.com/titman
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "LCWebServer.h"
#include <arpa/inet.h>
#include <netdb.h>
#import "LCLog.h"
#import "UIDevice+Reachability.h"
#import "HTTPServer.h"
#import "LCTools.h"
#import "LCWebServerConnection.h"

#define WEB_PATH [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/Caches/LCWeb/"]
#define INDEX_HTML_PATH [WEB_PATH stringByAppendingString:@"index.html"]
#define IMAGE_PATH [WEB_PATH stringByAppendingString:@"preview.jpg"]

@interface LCWebServer ()

LC_PROPERTY(strong) HTTPServer * server;

@end

@implementation LCWebServer

+ (BOOL)touchPath:(NSString *)path
{
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:NULL];
    }
    
    return YES;
}

- (void) start
{
    [self buildWebFolder];
    
    self.server = [[HTTPServer alloc] init];
    [self.server setType:@"_http._tcp."];
    [self.server setPort:12352];
    [self.server setDocumentRoot:WEB_PATH];
    [self.server setConnectionClass:[LCWebServerConnection class]];
    
    [self startServer];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
}

-(void) updateImage
{
    UIGraphicsBeginImageContext(LC_KEYWINDOW.bounds.size);
    
    [LC_KEYWINDOW.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData * data = UIImageJPEGRepresentation(image, 0.5);
    
    [data writeToFile:IMAGE_PATH atomically:YES];
}

-(void) buildWebFolder
{
    [self.class touchPath:WEB_PATH];
    
    [[NSFileManager defaultManager] removeItemAtPath:INDEX_HTML_PATH error:nil];
    [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] toPath:INDEX_HTML_PATH error:nil];
}


- (void)startServer
{
    NSError * error;
    
    if([self.server start:&error])
    {
        NSLog(@"Started HTTP Server on port %hu", [self.server listeningPort]);
    }
    else
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
}

@end
