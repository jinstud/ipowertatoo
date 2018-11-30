#import "DBManager.h"
#import "Marca.h"
#import "SessionBean.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createListaMarcheDB];
        [sharedInstance createListaNomiDeviceDB];
    }
    return sharedInstance;
}

-(BOOL)createListaMarcheDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"tatooDB.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE	TABLE ListaMarcheDB (_id INTEGER PRIMARY KEY, marca	TEXT NOT NULL, volt	TEXT NOT NULL, ls TEXT NOT NULL, stazione TEXT NOT NULL)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                //NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            //NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-(BOOL)createListaNomiDeviceDB{
    //NSLog(@"createListaNomiDeviceDB");
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"tatooDB.db"]];
    BOOL isSuccess = YES;
  
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE ListaNomiDeviceDB (_id INTEGER PRIMARY KEY, indirizzo	TEXT NOT NULL, nome	TEXT NOT NULL)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                //NSLog(@"Failed to create table %s", sqlite3_errmsg(database));
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            //NSLog(@"Failed to open/create database");
        }
    
    return isSuccess;
}

- (NSMutableArray*) getAllMarche;
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        static sqlite3_stmt *statement = nil;
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from ListaMarcheDB ORDER BY _id ASC"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                Marca *marca = [[Marca alloc] init];
                marca.marca = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 1)];
                
                //NSLog(@"marca %@",marca.marca);
                
                marca.volt = [[[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)] floatValue];
                
                //NSLog(@"volt %f",marca.volt);
                
                marca.ls = [[NSString alloc]initWithUTF8String:
                              (const char *) sqlite3_column_text(statement, 3)];
                
                //NSLog(@"ls %@",marca.ls);
                
                marca.stazione = [[NSString alloc]initWithUTF8String:
                            (const char *) sqlite3_column_text(statement, 4)];
                
                //NSLog(@"stazione %@",marca.stazione);
                
                [result addObject:marca];

            }
            sqlite3_reset(statement);
        }else{
            //NSLog(@"query errata '%s'", sqlite3_errmsg(database));
        }
    }
    return result;
}

- (void) saveNomeDevice:(NSString*)nome;
{
    const char *dbpath = [databasePath UTF8String];
    SessionBean *myApp = [SessionBean sharedSessionBean];
    
    //NSLog(@"saveNomeDevice nome %@ indirizzo %@", nome, myApp.mDevice.identifier.UUIDString);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        static sqlite3_stmt *statement = nil;
        NSString *querySQL = [NSString stringWithFormat:
                              @"select indirizzo from ListaNomiDeviceDB WHERE indirizzo = ? ORDER BY _id ASC"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [myApp.mDevice.identifier.UUIDString UTF8String], -1, NULL);
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                //NSLog(@"device già presente, fare aggiornamento");
                NSString *sqlStr=[NSString stringWithFormat:@"UPDATE 'ListaNomiDeviceDB' SET nome = ? WHERE indirizzo = ?"];
                const char *sql=[sqlStr UTF8String];
                sqlite3_stmt *statement1;
                
                if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
                    sqlite3_bind_text(statement1, 1, [nome UTF8String], -1, nil);
                    sqlite3_bind_text(statement1, 2, [myApp.mDevice.identifier.UUIDString UTF8String], -1, nil);
                }
                if (sqlite3_step(statement1) != SQLITE_DONE) {
                    //NSLog(@"Error inserting in table ListaNomiDeviceDB: %s", sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement1);
                
            } else{
                //NSLog(@"device non presente, aggiunta");
                
                NSString *sqlStr=[NSString stringWithFormat:@"INSERT INTO 'ListaNomiDeviceDB' ('indirizzo','nome') VALUES(?,?)"];
                const char *sql=[sqlStr UTF8String];
                sqlite3_stmt *statement1;
                
                if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
                    sqlite3_bind_text(statement1, 1, [myApp.mDevice.identifier.UUIDString UTF8String], -1, nil);
                     sqlite3_bind_text(statement1, 2, [nome UTF8String], -1, nil);
                }
                if (sqlite3_step(statement1) != SQLITE_DONE) {
                    //NSLog(@"Error inserting in table ListaNomiDeviceDB: %s", sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement1);
            }
            
            sqlite3_reset(statement);
        } else{
            //NSLog(@"query errata '%s'", sqlite3_errmsg(database));
        }
    } else{
        //NSLog(@"Errore di connessione al db");
    }
}

- (NSString*) getNomeDevice:(NSString*)indirizzo;
{
    NSString *result = nil;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        static sqlite3_stmt *statement = nil;
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from ListaNomiDeviceDB WHERE indirizzo = ?"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [indirizzo UTF8String], -1, NULL);
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                result = [[NSString alloc] initWithUTF8String:
                               (const char *) sqlite3_column_text(statement, 2)];
            }
            sqlite3_reset(statement);
        } else{
            //NSLog(@"query errata %s", sqlite3_errmsg(database));
        }
    } else{
        //NSLog(@"Errore di connessione al db");
    }
    
    //NSLog(@"Nome %@", result);
    
    return result;
}

-(void) insertMarca:(NSString*)marca andVolt:(NSString*)volt andLs:(NSString*)ls andStazione:(NSString*)stazione{
    const char *dbpath = [databasePath UTF8String];
    
    //NSLog(@"insertMarca marca %@ volt %@ ls %@ stazione %@", marca, volt,ls,stazione);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlStr=[NSString stringWithFormat:@"INSERT INTO 'ListaMarcheDB' ('marca','volt','ls','stazione') VALUES(?,?,?,?)"];
        const char *sql=[sqlStr UTF8String];
        sqlite3_stmt *statement1;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
            sqlite3_bind_text(statement1, 1, [marca UTF8String], -1, nil);
            sqlite3_bind_text(statement1, 2, [volt UTF8String], -1, nil);
            sqlite3_bind_text(statement1, 3, [ls UTF8String], -1, nil);
            sqlite3_bind_text(statement1, 4, [stazione UTF8String], -1, nil);
        }
        if (sqlite3_step(statement1) != SQLITE_DONE) {
            //NSLog(@"Error inserting in table ListaMarcheDB: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement1);
    } else{
        //NSLog(@"Errore di connessione al db");
    }

}

-(void)deleteMarca:(NSString *)marca{
    const char *dbpath = [databasePath UTF8String];
    
    //NSLog(@"deleteMarca marca %@", marca);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlStr=[NSString stringWithFormat:@"DELETE FROM  ListaMarcheDB WHERE marca = ?"];
        const char *sql=[sqlStr UTF8String];
        sqlite3_stmt *statement1;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
            sqlite3_bind_text(statement1, 1, [marca UTF8String], -1, nil);
        }
        if (sqlite3_step(statement1) == SQLITE_ROW) {
        }else{
            //NSLog(@"Error removing in table ListaMarcheDB: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement1);
    } else{
        //NSLog(@"Errore di connessione al db");
    }
}

-(void) updateMarca:(NSString*)marca andStazione:(NSString*)stazione{
    const char *dbpath = [databasePath UTF8String];
    
    //NSLog(@"updateMarca marca %@ stazione %@", marca,stazione);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlStr=[NSString stringWithFormat:@"UPDATE 'ListaMarcheDB' SET stazione = ? WHERE marca = ?"];
        const char *sql=[sqlStr UTF8String];
        sqlite3_stmt *statement1;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
            sqlite3_bind_text(statement1, 1, [stazione UTF8String], -1, nil);
            sqlite3_bind_text(statement1, 2, [marca UTF8String], -1, nil);
        }
        if (sqlite3_step(statement1) != SQLITE_DONE) {
            //NSLog(@"Error inserting in table ListaMarcheDB: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement1);
    } else{
        //NSLog(@"Errore di connessione al db");
    }
}

-(void) updateMarca:(NSString*)marca andLs:(NSString*)ls{
    const char *dbpath = [databasePath UTF8String];
    
    //NSLog(@"updateMarca marca %@ ls %@", marca,ls);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *sqlStr=[NSString stringWithFormat:@"UPDATE 'ListaMarcheDB' SET ls = ? WHERE marca = ?"];
        const char *sql=[sqlStr UTF8String];
        sqlite3_stmt *statement1;
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
            sqlite3_bind_text(statement1, 1, [ls UTF8String], -1, nil);
            sqlite3_bind_text(statement1, 2, [marca UTF8String], -1, nil);
        }
        if (sqlite3_step(statement1) != SQLITE_DONE) {
            //NSLog(@"Error inserting in table ListaMarcheDB: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement1);
    } else{
        //NSLog(@"Errore di connessione al db");
    }
}

-(void) updateStazione:(NSString*)stazione andVolt:(NSString*)volt{
    const char *dbpath = [databasePath UTF8String];
    
    //NSLog(@"updateStazione stazione %@ volt %@", stazione,volt);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        static sqlite3_stmt *statement = nil;
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from ListaMarcheDB WHERE stazione = ?"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [stazione UTF8String], -1, nil);
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *sqlStr=[NSString stringWithFormat:@"UPDATE 'ListaMarcheDB' SET volt = ? WHERE stazione = ?"];
                const char *sql=[sqlStr UTF8String];
                sqlite3_stmt *statement1;
                
                if (sqlite3_prepare_v2(database, sql, -1, &statement1, nil)==SQLITE_OK) {
                    sqlite3_bind_text(statement1, 1, [volt UTF8String], -1, nil);
                    sqlite3_bind_text(statement1, 2, [stazione UTF8String], -1, nil);
                }
                if (sqlite3_step(statement1) != SQLITE_DONE) {
                    //NSLog(@"Error updating in table ListaMarcheDB: %s", sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement1);
            } else{
                //NSLog(@"Insert new marca");
                [self insertMarca:@"" andVolt:volt andLs:@"L1" andStazione:stazione];
            }
            sqlite3_reset(statement);
        }else{
            //NSLog(@"query errata '%s'", sqlite3_errmsg(database));
        }
    } else{
        //NSLog(@"Errore di connessione al db");
    }
}

-(Marca*) getMarca:(NSString*)stazione{
    Marca *marca;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        static sqlite3_stmt *statement = nil;
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from ListaMarcheDB WHERE stazione = ?"];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [stazione UTF8String], -1, nil);
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                marca = [[Marca alloc] init];
                marca.marca = [[NSString alloc] initWithUTF8String:
                               (const char *) sqlite3_column_text(statement, 1)];
                
                //NSLog(@"marca %@",marca.marca);
                
                marca.volt = [[[NSString alloc]initWithUTF8String:
                               (const char *) sqlite3_column_text(statement, 2)] floatValue];
                
                //NSLog(@"volt %f",marca.volt);
                
                marca.ls = [[NSString alloc]initWithUTF8String:
                            (const char *) sqlite3_column_text(statement, 3)];
                
                //NSLog(@"ls %@",marca.ls);
                
                marca.stazione = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 4)];
                
                //NSLog(@"stazione %@",marca.stazione);
                
            }
            sqlite3_reset(statement);
        }else{
            //NSLog(@"query errata '%s'", sqlite3_errmsg(database));
        }
    }
    return marca;

}


@end

