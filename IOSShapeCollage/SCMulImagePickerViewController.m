//
//  SCMulImagePickerViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-25.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCMulImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCMulImagePickerTableViewCell.h"
#import "SCImageCollectionViewController.h"
#import "MHImagePickerMutilSelector.h"

static CGSize AssetGridThumbnailSize;


@interface SCMulImagePickerViewController ()<PHPhotoLibraryChangeObserver>

@end

@implementation SCMulImagePickerViewController

@synthesize photoGroupArray;
@synthesize imageManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (iOS8)
    {
        AssetGridThumbnailSize = CGSizeMake(77, 77);
        self.imageManager = [[PHCachingImageManager alloc] init];
        [self resetCachedAssets];
        
        NSMutableArray *tempPhototGroupArray = [[NSMutableArray alloc]init];
        
        
        
        PHFetchResult *smartRecently = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
        
        PHCollection *collectionRecently = [smartRecently objectAtIndex:0];
        [tempPhototGroupArray addObject:collectionRecently];
        
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        
        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];

        PHFetchResult *shareAlbums= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
        
        
        for (int i = 0 ; i < [smartAlbums count]; i++)
        {
            PHCollection *collection = [smartAlbums objectAtIndex:i];
            PHFetchResult *tempResult =[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            NSLog(@"%@-%lu",collection.localizedTitle,(unsigned long)tempResult.count);
            if (tempResult.count > 0 )
            {
                PHAsset *asset = [tempResult objectAtIndex:0];
                if (asset.mediaType == PHAssetMediaTypeImage)
                {
                    [tempPhototGroupArray addObject:collection];
                }
                
            }
        }
        for (int j = 0; j < [topLevelUserCollections count]; j++)
        {
            PHCollection *collection = [topLevelUserCollections objectAtIndex:j];
            PHFetchResult *tempResult =[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            NSLog(@"%@-%lu",collection.localizedTitle,(unsigned long)tempResult.count);
            if (tempResult.count > 0 )
            {
                PHAsset *asset = [tempResult objectAtIndex:0];
                if (asset.mediaType == PHAssetMediaTypeImage)
                {
                    [tempPhototGroupArray addObject:collection];
                }
                
            }
        }
        for (int k = 0; k < [shareAlbums count]; k++)
        {
            PHCollection *collection = [shareAlbums objectAtIndex:k];
            PHFetchResult *tempResult =[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            NSLog(@"%@-%lu",collection.localizedTitle,(unsigned long)tempResult.count);
            if (tempResult.count > 0 )
            {
                PHAsset *asset = [tempResult objectAtIndex:0];
                if (asset.mediaType == PHAssetMediaTypeImage)
                {
                    [tempPhototGroupArray addObject:collection];
                }
                
            }
        }
        self.photoGroupArray = tempPhototGroupArray;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    photosArray = [[NSMutableArray alloc]init];
    
    photoGroupTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-135) style:UITableViewStylePlain];
    photoGroupTable.delegate = self;
    photoGroupTable.dataSource = self;
    photoGroupTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    photoGroupTable.backgroundColor = colorWithHexString(@"#202020");
    photoGroupTable.tag = 100;
    [photoGroupTable setRowHeight:100];
    [photoGroupTable setShowsVerticalScrollIndicator:NO];
    [photoGroupTable setPagingEnabled:YES];
    [self.view addSubview:photoGroupTable];
    
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return photoGroupArray.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCMulImagePickerTableViewCell* cell= (SCMulImagePickerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger row=indexPath.row;

    static NSString *identify = @"photoGroup";
    if (cell == nil)
    {
        cell = [[SCMulImagePickerTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = colorWithHexString(@"#141414");
        if (iOS8)
        {
            PHCollection *tempCollection = nil;
            PHFetchResult *tempResult = nil;
            
            if (indexPath.row == 0)
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                tempCollection = (PHCollection *)[self.photoGroupArray objectAtIndex:indexPath.row];
                tempResult =[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)tempCollection options:options];
                
                cell.textLabel.text = LocalizedString(@"allPhoto", nil);
            }
            else
            {
                tempCollection = (PHCollection *)[self.photoGroupArray objectAtIndex:indexPath.row];
                tempResult =[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)tempCollection options:nil];
                cell.textLabel.text = tempCollection.localizedTitle;
            }
            
            PHAsset *asset = [tempResult lastObject];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:AssetGridThumbnailSize
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          
                                          // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                              cell.imageView.image = result;
                                      }];
            
            
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)[tempResult countOfAssetsWithMediaType:PHAssetMediaTypeImage]];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
        }
        else
        {
            ALAssetsGroup *groupForCell = [photoGroupArray objectAtIndex:row];
            CGImageRef posterImageRef = [groupForCell posterImage];
            UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
            cell.imageView.image = posterImage;
            
            cell.textLabel.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)[groupForCell numberOfAssets]];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (photosArray) {
        photosArray = [[NSMutableArray alloc] init];
    } else {
        [photosArray removeAllObjects];
    }
    if (iOS8)
    {
        
        PHCollection *collection = [self.photoGroupArray objectAtIndex:indexPath.row];;
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = nil;
            if (indexPath.row == 0)
            {
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                
                assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            }
            else
            {
                assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            }
            
            
            SCImageCollectionViewController *collectionView = [[SCImageCollectionViewController alloc]init];
            collectionView.assetsFetchResults = assetsFetchResult;
            collectionView.assetCollection = assetCollection;
            collectionView.delegate = [[PRJ_Global shareStance] getSCCollectionViewDelegate];
            [self.navigationController pushViewController:collectionView animated:YES];
        }
    }
    else
    {
        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result) {
                [photosArray addObject:result];
            }
            else
            {
                SCImageCollectionViewController *collectionView = [[SCImageCollectionViewController alloc]init];
                collectionView.photosArray = photosArray;
                collectionView.delegate = [[PRJ_Global shareStance] getSCCollectionViewDelegate];
                [self.navigationController pushViewController:collectionView animated:YES];
            }
        };
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [[self.photoGroupArray objectAtIndex:indexPath.row] setAssetsFilter:onlyPhotosFilter];
        [[self.photoGroupArray objectAtIndex:indexPath.row] enumerateAssetsUsingBlock:assetsEnumerationBlock];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    if (iOS8)
    {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
