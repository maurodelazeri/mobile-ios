//
//  AlbumPickerController.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ELCAlbumPickerController : UITableViewController {
	
	NSMutableArray *assetGroups;
	NSOperationQueue *queue;
	id parent;
    
    ALAssetsLibrary *library;
}

@property (nonatomic, weak) id parent;
@property (nonatomic, strong) NSMutableArray *assetGroups;

-(void)selectedAssets:(NSArray*)_assets;

@end

