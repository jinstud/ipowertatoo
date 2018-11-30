#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Marca.h"

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
- (NSMutableArray*) getAllMarche;
- (void) saveNomeDevice:(NSString*)nome;
- (NSString*) getNomeDevice:(NSString*)indirizzo;
-(void) insertMarca:(NSString*)marca andVolt:(NSString*)volt andLs:(NSString*)ls andStazione:(NSString*)stazione;
-(void) deleteMarca:(NSString*)marca;
-(void) updateMarca:(NSString*)marca andStazione:(NSString*)stazione;
-(void) updateMarca:(NSString*)marca andLs:(NSString*)ls;
-(void) updateStazione:(NSString*)stazione andVolt:(NSString*)volt;
-(Marca*) getMarca:(NSString*)stazione;
@end