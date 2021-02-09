//
//  AppDelegate.m
//  App1
//
//  Created by me on 2021/2/8.
//

#import "AppDelegate.h"


#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <syslog.h>
#include <mach-o/dyld.h>
@interface AppDelegate ()

@end

@implementation AppDelegate

#define FILE_PATH "/tmp/file.txt"
#define TEXT_FIELD_TAG (0x100)
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //NSArray<NSWindow *> *windows = [[NSApplication sharedApplication] windows];
    NSWindow* mainWindow =  [[NSApplication sharedApplication] windows] [0];
    

    mainWindow.sharingType = NSWindowSharingReadWrite;
    NSWindow* mainWindow1 =  [[NSApplication sharedApplication] windows] [0];
    if (fork() > 0)
    {
        //main-process create a NSTextField with text "from main process"
        
        
        NSTextField* textField = [[NSTextField alloc]initWithFrame:CGRectInset(mainWindow.contentView.bounds, 50, 50) ];
        textField.stringValue = @"from main process";
        textField.alignment = NSTextAlignmentCenter;
        textField.editable = NO;
        textField.tag = TEXT_FIELD_TAG;
        [mainWindow.contentView addSubview:textField];
        

        //if uncomment here, we could see two lines of text in app window
        /*
        {
            NSTextField* textField = [[NSTextField alloc]initWithFrame:CGRectInset(mainWindow.contentView.bounds, 50, 50) ];
            textField.stringValue = @"\n\nfrom sub process";
            textField.alignment = NSTextAlignmentCenter;
            textField.editable = NO;
            textField.tag = TEXT_FIELD_TAG;
            [mainWindow.contentView addSubview:textField];
        }
        */
        
        //then write the windowNumber to /tmp/file.txt
        std::ofstream outfile;
        outfile.open(FILE_PATH, std::ios::out | std::ios::trunc);
        assert(outfile.is_open());
        outfile << intptr_t(mainWindow.windowNumber) << std::endl;
        
  
        //and waiting for sub-process to modify the text
    }
    else
    {
        
        
        //sub-process wait 3 seconds (make sure file is written by main-process)
        sleep(3);
        
        
        //read the address of textField(created by main-process) from /tmp/file.txt
        std::ifstream infile;
        std::string windowNumber;
        infile.open(FILE_PATH, std::ios::in);
        assert(infile.is_open());
        infile >> windowNumber;
        
   
        //NSWindow * mainWindow = [[NSApplication sharedApplication] windowWithWindowNumber:windowNumber];
        
        //we could get mainWindow here, but we can't add more ui to it
        //otherwise the following warning will occur
        /*
         he process has forked and you cannot use this CoreFoundation functionality safely.
         You MUST exec(). Break on __THE_PROCESS_HAS_FORKED_AND_YOU_CANNOT_USE_THIS_
         COREFOUNDATION_FUNCTIONALITY___YOU_MUST_EXEC__() to debug.
         */
        
        //so we have to use exec()
        //see main.mm
        

        char        execPath[PATH_MAX];
        uint32_t    execPathSize = sizeof(execPath);
        (void) _NSGetExecutablePath(execPath, &execPathSize);
        const char * args[] = {execPath, "is_subprogress", windowNumber.c_str(), nullptr};
        (void) execv(execPath, (char * const *) args);

        kill(getpid(), SIGKILL);
        
    }
    

}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
