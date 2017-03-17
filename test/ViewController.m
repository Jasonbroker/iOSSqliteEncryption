//
//  ViewController.m
//  test
//
//  Created by Jason on 03/11/2016.
//  Copyright © 2016 51talk. All rights reserved.
//

#import "ViewController.h"
#import <FMDB/FMDB.h>
#import <sqlite3.h>
#import "FMDatabase+Encryption.h"

@interface ViewController ()

@property (nonatomic, strong)NSString *databasePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.databasePath = [self normalDbPath];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 300)/2, 100, 300, 100)];
    [button addTarget:self action:@selector(generateNormalDB) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor cyanColor];
    [button setTitle:@"generate normal db" forState:UIControlStateNormal];
    [self.view addSubview:button];

    
    NSLog(@"%@", self.databasePath);
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectOffset(button.frame, 0, 200)];
    [button2 addTarget:self action:@selector(changeToEncryptedDb) forControlEvents:UIControlEventTouchUpInside];
    button2.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:button2];

}

- (NSString *)normalDbPath {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    return [documentDir stringByAppendingPathComponent:@"normal.sqlite"];
}



- (void)generateNormalDB {
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    [db open];
        
        [db executeUpdate: @"CREATE TABLE IF NOT EXISTS test \
         (test_id INTEGER PRIMARY KEY, \
         category INTEGER, \
         name TEXT, \
         last_update_time INTEGER, \
         last_fetch_time INTEGER);"];
        
        [db close];
}

- (void)changeToEncryptedDb {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *ecDBPath = [documentDir stringByAppendingPathComponent:@"result.sqlite"];
    
    BOOL result = [FMDatabase encriptDatabase:self.databasePath toPath:ecDBPath removeWhenComplete:YES];
    self.databasePath = ecDBPath;
    if (result) {
        NSLog(@"change succeed");
    }
}

@end
