//
//  HEZAppDelegate.m
//  UnoHelper
//
//  Created by Hezi Cohen on 10/24/13.
//  Copyright (c) 2013 Hezi Cohen. All rights reserved.
//

#import "HEZAppDelegate.h"

static NSString *g_scriptPath;

@implementation HEZAppDelegate

- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@" , scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
            *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
            *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    g_scriptPath = [[NSBundle mainBundle] pathForResource:@"change_dns" ofType:@"sh"];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dns" ofType:@"plist"];
    self.DNSServers = [[NSArray alloc] initWithContentsOfFile:filePath];
    
}

- (void)changeDNSwithServer:(NSString*)dnsServer {
    NSString * output = nil;
    NSString * processErrorDescription = nil;
    BOOL success = [self runProcessAsAdministrator:g_scriptPath
                                     withArguments:@[dnsServer]
                                            output:&output
                                  errorDescription:&processErrorDescription];
    
    
    if (!success) // Process failed to run
    {
        // ...look at errorDescription
    }
    else
    {
        // ...process output
    }
}

- (IBAction)serverChanged:(id)sender {
    NSString *ip = self.DNSServers[[((NSPopUpButton*)sender) indexOfSelectedItem]][@"IP"];
    [self changeDNSwithServer:ip];
}

@end
