#import "GameManager.h"
@class GameManager;
 
@implementation GameManager

#define IS_IPHONE_5 ([UIScreen mainScreen].bounds.size.height == 568.0)
#define K_SHOULD_SHOW_HOW_TO_PLAY @"should_show_how_to_play"

static GameManager *sharedInstance = nil;
 
+ (GameManager*)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

 
// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        //generate bezier values for animals
        [self initBezier];
        
        [self resetGameVariables];
        
        //initialize database
        [self initDB];
        
        //initilaize music
        self.sae = [SimpleAudioEngine sharedEngine];
        if (self.sae != nil) {
            [self.sae preloadEffect:@"menuMusic.mp3"];
            [self.sae preloadEffect:@"gameStop.mp3"];
            [self.sae preloadEffect:@"pickup.mp3"];
            [self.sae preloadEffect:@"countdown.mp3"];
            [self.sae preloadBackgroundMusic:@"gameLoop.mp3"];
            if (self.sae.willPlayBackgroundMusic) {
                self.sae.backgroundMusicVolume = 0.7f;
            }
        }
    }
    return self;
}

-(void) resetGameVariables{
    self.frozenPowerupActivated = NO;

    //init array for animals
    [self.animals removeAllObjects];
    self.animals = [[NSMutableArray alloc] init];
    
    //initialize speed
    self.gameSpeed = 0.30;
    
    //initialize rate
    self.currentSpawnRate = 2.00;
    
    self.currentSpawnCount = 2.00;
}

-(void)setAnimals:(NSMutableArray *)animals {
    _animals = animals;
}

-(void) initDB{
    //init db
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database setLogsErrors:YES];
    [database open];
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS game (id INTEGER PRIMARY KEY, name VARCHAR(50), value INTEGER);"];
    FMResultSet* result = [database executeQuery:@"SELECT value FROM game WHERE name='highScore'"];
    
    //get highscore value
    int highScore = -1;
    while([result next]){
        highScore  = [result intForColumn:@"value"];
    }
    if(highScore == -1){
        [database executeUpdate:@"INSERT INTO game (name, value) VALUES ('highScore', 0);"];
    }else{
        NSLog(@"HighScore %d",highScore);
    }
    
    //get sound effect value
    FMResultSet* resultTwo = [database executeQuery:@"SELECT value FROM game WHERE name='soundEffects'"];
    int soundEffects = -1;
    while([resultTwo next]){
        soundEffects  = [resultTwo intForColumn:@"value"];
    }
    if(soundEffects == -1){
        [database executeUpdate:@"INSERT INTO game (name, value) VALUES ('soundEffects', 1);"];
    }else{
        NSLog(@"Effect %d",soundEffects);
    }
    
    //get bg value
    FMResultSet* resultThree = [database executeQuery:@"SELECT value FROM game WHERE name='backgroundMusic'"];
    int backgroundMusic = -1;
    while([resultThree next]){
        backgroundMusic = [resultThree intForColumn:@"value"];
    }
    if(backgroundMusic == -1){
        [database executeUpdate:@"INSERT INTO game (name, value) VALUES ('backgroundMusic', 1);"];
    }else{
        NSLog(@"BG %d",backgroundMusic);
    }
    
    [database close];
}

//returns highscore
-(int) getHighScore{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database setLogsErrors:YES];
    [database open];
    FMResultSet* result = [database executeQuery:@"SELECT value FROM game WHERE name='highScore'"];
    
    int highScore = -1;
    while([result next]){
        highScore  = [result intForColumn:@"value"];
    }
    if(highScore == -1){
        [database executeUpdate:@"INSERT INTO game (name, value) VALUES ('highScore', 0);"];
    }else{
        NSLog(@"HighScore %d",highScore);
    }
    
    [database close];
    return highScore;
}

//returns sound effect
-(int) getSoundEffects{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database setLogsErrors:YES];
    [database open];

    FMResultSet* resultTwo = [database executeQuery:@"SELECT value FROM game WHERE name='soundEffects'"];
    int soundEffects = -1;
    while([resultTwo next]){
        soundEffects  = [resultTwo intForColumn:@"value"];
    }
    if(soundEffects == -1){
        [database executeUpdate:@"INSERT INTO game (name, value) VALUES ('soundEffects', 1);"];
    }else{
        NSLog(@"Effect %d",soundEffects);
    }
    
    [database close];
    return soundEffects;
}

//returns bg
-(int) getBackgroundMusic{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database setLogsErrors:YES];
    [database open];
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS game (id INTEGER PRIMARY KEY, name VARCHAR(50), value INTEGER);"];

    FMResultSet* resultThree = [database executeQuery:@"SELECT value FROM game WHERE name='backgroundMusic'"];
    int backgroundMusic = -1;
    while([resultThree next]){
        backgroundMusic = [resultThree intForColumn:@"value"];
    }
    if(backgroundMusic == -1){
        [database executeUpdate:@"INSERT INTO game (name, value) VALUES ('backgroundMusic', 1);"];
    }else{
        NSLog(@"BG %d",backgroundMusic);
    }
    
    [database close];
    return backgroundMusic;
}

//sets highscore if greater than current
-(void) checkHighScore:(int)newScore{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database setLogsErrors:YES];
    [database open];
    FMResultSet* result = [database executeQuery:@"SELECT value FROM game WHERE name='highScore'"];
    int highScore;
    while([result next]){
        highScore  = [result intForColumn:@"value"];
    }
    if(highScore<newScore){
        [database executeUpdate:[NSString stringWithFormat:@"UPDATE game SET value = '%d'where name = 'highScore'",newScore]];
        [database close];
        return;
//        return YES;
    }
    [database close];
    return;
//    return NO;
}

-(void)initBezier{

    CGPoint bezierOne[4] =
	{
		{6,83},
		{185,51},
		{16,238},
		{173,231}
	};
    self.bezierArray = [self generateBezierArray:bezierOne WithSize:100];
    CGPoint bezierTwo[4] =
	{
		{173,231},
		{415,231},
		{370,248},
		{382,129}
	};
    [self.bezierArray addObjectsFromArray:[self generateBezierArray:bezierTwo WithSize:100]];
    CGPoint bezierThree[4] =
	{
		{382,129},
		{383,71},
		{470,82},
		{530,80}
	};
    [self.bezierArray addObjectsFromArray:[self generateBezierArray:bezierThree WithSize:100]];
}

- (NSMutableArray*) generateBezierArray:(CGPoint[4])bezierPoints WithSize:(int)points {
    NSMutableArray* array = [[NSMutableArray alloc]init];
	for(int i = 0; i < points; i++){
		float t = (float)i / points;
		CGPoint p;
		p.x = [self bezierAtA:bezierPoints[0].x B:bezierPoints[1].x C:bezierPoints[2].x D:bezierPoints[3].x WithTime:t];
        if(IS_IPHONE_5) {
            p.x += 44;
        }
		p.y = [self bezierAtA:bezierPoints[0].y B:bezierPoints[1].y C:bezierPoints[2].y D:bezierPoints[3].y WithTime:t];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            p.x *= 2.133333333;
            p.y *= 2.4;          
        }
		[array addObject:[NSValue valueWithCGPoint:p]];
    }
    return array;
}

- (CGFloat) bezierAtA: (float) a B: (float) b C: (float) c D: (float) d WithTime: (ccTime) t {
    return (powf(1-t,3) * a +
    3*t*(powf(1-t,2))*b +
    3*powf(t,2)*(1-t)*c +
    powf(t,3)*d );
}

+ (BOOL)shouldShowHowToPlay {
    NSNumber *number = [self retrievePreferenceForKey:K_SHOULD_SHOW_HOW_TO_PLAY];
    if (!number) {
        [self savePreference:[NSNumber numberWithBool:YES] forKey:K_SHOULD_SHOW_HOW_TO_PLAY];
        return YES;
    } else {
        return number.boolValue;
    }
}

+ (void)saveShouldShowHowToPlay:(BOOL)shouldShowHowToPlay {
    [self savePreference:[NSNumber numberWithBool:shouldShowHowToPlay] forKey:K_SHOULD_SHOW_HOW_TO_PLAY];
}

+ (void) savePreference: (NSObject *) value forKey: (NSString *) key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

+ (id)retrievePreferenceForKey: (NSString *) key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}
 
// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
 
@end