//
//  OpenPhotoAppDelegate.m
//  OpenPhoto
//
//  Created by Patrick Santana on 28/07/11.
//  Copyright 2011 OpenPhoto. All rights reserved.
//

#import "OpenPhotoAppDelegate.h"
#import "OpenPhotoViewController.h"

@implementation OpenPhotoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Allow HTTP response size to be unlimited.
    [[TTURLRequestQueue mainQueue] setMaxContentLength:0];
    
    // Configure the in-memory image cache to keep approximately
    // 10 images in memory, assuming that each picture's dimensions
    // are 320x480. Note that your images can have whatever dimensions
    // you want, I am just setting this to a reasonable value
    // since the default is unlimited.
    [[TTURLCache sharedCache] setMaxPixelCount:10*640*960];
    
#ifdef TEST_FLIGHT_ENABLED
    // to start the TestFlight SDK
    [TestFlight takeOff:@"407f45aed7c5bc2fc88cb567078edb1f_MjMyNTUyMDExLTA5LTEyIDEyOjEyOjU3Ljc1Nzg5MA"];
    [TestFlight passCheckpoint:@"Started App"];
#endif
    
    UpdateUtilities *updater = [UpdateUtilities instance];
    if ([updater needsUpdate] == YES){
        NSLog(@"App needs to be updated");
        NSLog(@"Version to install %@", [updater getVersion]);
        [updater update];
        [updater updateSystemVersion];
    }
    
    
    InitializerHelper *helper = [[InitializerHelper alloc]init];
    if ([helper isInitialized] == NO){
        [helper initialize];
    }
    [helper release];
    
    
    // open the default view controller
    self.window.rootViewController = self.viewController;
    
    // now if it is not authenticated, show the screen in the TOP of the view controller
    // check if user is authenticated or not
    AuthenticationHelper *auth = [[AuthenticationHelper alloc]init];
    if ([auth isValid]== NO){
        // open the authentication screen
        AuthenticationViewController *controller = [[AuthenticationViewController alloc]init];
        [self.window.rootViewController presentModalViewController:controller animated:YES];
        [controller release];
    }
    [auth release];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void) openGallery{
    NSLog(@"Opening the Gallery. User just uploaded a picture");
    [self.viewController setSelectedIndex:1];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    NSLog(@"handleOpenUrl = %@",url);
    AuthenticationHelper *auth = [[AuthenticationHelper alloc]init];
    
#ifdef TEST_FLIGHT_ENABLED
    [TestFlight passCheckpoint:@"Started OAuth Procedure"];
#endif
    
    
    if ([auth isValid] == NO){
        [auth startOAuthProcedure:url];
    }
    
    [auth release];
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


//////// CORE DATA
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    
    NSError *error = nil;
    NSManagedObjectContext *objectContext = self.managedObjectContext;
    if (objectContext != nil)
    {
        if ([objectContext hasChanges] && ![objectContext save:&error])
        {
            // add error handling here
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataTabBarTutorial.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }  
    
    return persistentStoreCoordinator;
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];    
    [super dealloc];
}

@end
