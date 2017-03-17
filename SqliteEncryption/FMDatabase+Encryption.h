//
//  FMDatabase+Encrption.h
//  test
//
//  Created by Jason on 15/03/2017.
//  Copyright © 2017 51talk. All rights reserved.
//

#import <FMDB/FMDB.h>

@interface FMDatabase (Encription)

/**
 encript db and delete the old file
 @param path old db path
 @return YES if succeed.
 */
+ (BOOL)encriptDatabase:(NSString *)path;
/**
 encript db and rename the old db with extension *.old

 @param path old db path
 @param remove remove old db or not
 @return YES if succeed.
 */
+ (BOOL)encriptDatabase:(NSString *)path
              removeOld:(BOOL)remove;

/**
 encript db.
 
 @param path old db path
 @param destinationPath new db path
 @param remove remove the old path or not
 @return YES if succeed.
 */
+ (BOOL)encriptDatabase:(NSString *)path
                 toPath:(NSString *)destinationPath
     removeWhenComplete:(BOOL)remove;

@end
