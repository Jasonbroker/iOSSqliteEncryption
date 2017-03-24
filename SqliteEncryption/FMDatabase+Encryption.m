//
//  FMDatabase+Encrption.m
//  test
//
//  Created by Jason on 15/03/2017.
//  Copyright © 2017 51talk. All rights reserved.
//

#import "FMDatabase+Encryption.h"
#import <objc/runtime.h>
#import <sqlite3.h>
#import <UIKit/UIKit.h>

#define DB_SECRETKEY [FMDatabase dataBaseKey]

@implementation FMDatabase (Encrption)

void SwizzleClassMethod(id c, SEL orig, SEL new1, BOOL isClassMethod) {
    
    if (isClassMethod) {
        Method origMethod = class_getClassMethod(c, orig);
        Method newMethod = class_getClassMethod(c, new1);
        
        c = object_getClass((id)c);
        
        if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
            class_replaceMethod(c, new1, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        else {
            method_exchangeImplementations(origMethod, newMethod);
        }
    } else {
        
        Method original, swizzled;
        
        original = class_getInstanceMethod(c, orig);
        swizzled = class_getInstanceMethod(c, new1);
        method_exchangeImplementations(original, swizzled);
        
    }
}

+ (void)load {
    SwizzleClassMethod([self class],@selector(open), @selector(snOpen), NO);
    SwizzleClassMethod([self class],@selector(openWithFlags:vfs:), @selector(snOpenWithFlags:vfs:), NO);
}

- (BOOL)snOpen {
    BOOL open = [self snOpen];
    [self setKey:DB_SECRETKEY];
    return open;
}

- (BOOL)snOpenWithFlags:(int)flags vfs:(NSString *)vfsName {
    BOOL open = [self snOpenWithFlags:flags vfs:vfsName];
    [self setKey:DB_SECRETKEY];
    return open;
}

+ (BOOL)encryptDatabase:(NSString *)path {
    return [self encriptDatabase:path
                       removeOld:YES];
}

+ (BOOL)encriptDatabase:(NSString *)path
              removeOld:(BOOL)remove {
    return [self encryptDatabase:[self changeDatabaseToOldPath:path]
                          toPath:path
              removeWhenComplete:remove];
}

+ (BOOL)encryptDatabase:(NSString *)path
                 toPath:(nullable NSString *)destinationPath
     removeWhenComplete:(BOOL)remove {
    
    if (!path) {
        return NO;
    }
    
    if (!destinationPath) {
        destinationPath = [self changeDatabaseToOldPath:path];
    }
    
    // path is the same
    if ([path isEqualToString:destinationPath]) {
        return NO;
    }
    // no file exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    
    // unencrpted db
    sqlite3 *unencrypted_DB;
    if (sqlite3_open([path UTF8String], &unencrypted_DB) == SQLITE_OK) { // open unencrpted db
    
        // encrypted: attach的column alias
        // destinationPath: dest path
        // KEY: key
        const char* sqlQ = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS 'encrypted' KEY '%@';",destinationPath,DB_SECRETKEY] UTF8String];
        
        char* attacherrmsg = NULL;
        // Attach empty encrypted database to unencrypted database
        sqlite3_exec(unencrypted_DB, sqlQ, NULL, NULL, &attacherrmsg);
        if (attacherrmsg) {
            return NO;
        }
        
        char* exporterrmsg = NULL;
        // export database with column named 'encrypted'
        sqlite3_exec(unencrypted_DB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, &exporterrmsg);
        if (exporterrmsg) {
            return NO;
        }
        
        // Detach encrypted database
        sqlite3_exec(unencrypted_DB, "DETACH DATABASE 'encrypted';", NULL, NULL, NULL);
        
        sqlite3_close(unencrypted_DB);
        
        //delete tmp database if needed.
        if (remove) {
            [self removeFileAtPath:path];
        }
    }
    else {
        sqlite3_close(unencrypted_DB);
        NSAssert1(NO, @"Failed to open database with message ‘%s‘.", sqlite3_errmsg(unencrypted_DB));
        return NO;
    }
    
    return YES;
}

+ (void)removeFileAtPath:(NSString *)path {
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:path error:nil];
}

+ (NSString *)changeDatabaseToOldPath:(NSString *)path{
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    NSString *tmppath = [NSString stringWithFormat:@"%@.old",path];
    BOOL result = [fm moveItemAtPath:path toPath:tmppath error:&err];
    if(!result){
        NSLog(@"Error: %@", err);
        return nil;
    }else{
        return tmppath;
    }
}

+ (NSString *)dataBaseKey {
    static NSString *key = nil;
    if (!key) {
        key = [[self class] getUID];
    }
    return key;
}

// get a key which will not change.
+ (NSString *)getUID {
    NSString *uniqueIdentifier = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) {
        // iOS6 以上可用
        // a UUID that may be used to uniquely identify the device, same across apps from a single vendor.
        uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return uniqueIdentifier;
}

@end
