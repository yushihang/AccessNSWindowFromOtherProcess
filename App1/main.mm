//
//  main.m
//  App1
//
//  Created by me on 2021/2/8.
//

#import <Cocoa/Cocoa.h>
#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <syslog.h>
#include <mach-o/dyld.h>

#define TEXT_FIELD_TAG (0x100)
int main(int argc, const char * argv[]) {
    
    // record exec args
    {
        std::ofstream outfile;
        outfile.open("/tmp/main.log", std::ios::out | std::ios::app);
        assert(outfile.is_open());
        
        outfile << "----begin----" << std::endl;
        for (int i=0; i< argc; i++)
        {
            outfile << "[" << argv[i] << "]:" << std::endl;
        }
        
        outfile << "----end----" << std::endl;
    }
    // record exec args
    
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        
        if (argc >= 3)
        {
            //see AppDelegate.mm
            if (strcmp(argv[1], "is_subprogress") == 0)
            {
                intptr_t windowNumber = atoll(argv[2]);
                
                {
                    //to confirm the code here executed
                    std::ofstream outfile;
                    outfile.open("/tmp/exec1.log", std::ios::out | std::ios::trunc);
                    assert(outfile.is_open());
                    outfile << windowNumber << std::endl;
                }
  
            
                NSWindow * mainWindow = [[NSApplication sharedApplication] windowWithWindowNumber:windowNumber];
                //Could not get NSWindow here!
                
                {
                    //to confirm the code here executed
                    std::ofstream outfile;
                    outfile.open("/tmp/exec2.log", std::ios::out | std::ios::trunc);
                    assert(outfile.is_open());
                    outfile << windowNumber << std::endl;
                }
                
                {
                    NSTextField* textField = [[NSTextField alloc]initWithFrame:CGRectInset(mainWindow.contentView.bounds, 50, 50) ];
                    textField.stringValue = @"\n\nfrom sub process";
                    textField.alignment = NSTextAlignmentCenter;
                    textField.editable = NO;
                    textField.tag = TEXT_FIELD_TAG;
                    [mainWindow.contentView addSubview:textField];
                }
               
                
                {
                    //to confirm the code here executed
                    std::ofstream outfile;
                    outfile.open("/tmp/exec3.log", std::ios::out | std::ios::trunc);
                    assert(outfile.is_open());
                    outfile << windowNumber << std::endl;
                }
                
       
                
                
             
                return 0;
            }
        }
    }
    return NSApplicationMain(argc, argv);
}
