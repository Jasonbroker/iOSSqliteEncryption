# SqliteEncryption
Encrypt sqlite database base on FMDB

# Install

`'FMDB/SQLCipher'` is required.
Install using cocoapods.
```
pod 'FMDB/SQLCipher'
```
Drag `SqliteEncryption` folder into your project.

# How to use

```
+ (BOOL)encryptDatabase:(NSString *)path;
```
 is use to encrypt an existed database.

 If you wanna keep the old database, `+ (BOOL)encryptDatabase:(NSString *)path removeOld:(BOOL)remove;` will work.

 If you wanna custom the new database name,
 ```
 + (BOOL)encryptDatabase:(NSString *)path
                 toPath:(NSString *)destinationPath
     removeWhenComplete:(BOOL)remove;
 ```

 See more usage in example folder.