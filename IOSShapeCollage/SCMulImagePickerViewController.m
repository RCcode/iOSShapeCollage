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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (iOS8)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"user_library_step", @"") delegate:self cancelButtonTitle:LocalizedString(@"rc_custom_positive", @"") otherButtonTitles:nil, nil];
                    [alert show];
                    
                });

                
            }
            else if (status == PHAuthorizationStatusAuthorized)
            {
//                dispatch_async(dispatch_get_main_queue(), ^
//                {
                    _photoResultArray = [[NSMutableArray alloc]init];
                    PHFetchOptions *options = [[PHFetchOptions alloc] init];
                    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
                    [_photoResultArray addObject:fetchResult];
                    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
                    [_photoResultArray addObject:smartAlbums];
                    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
                    [_photoResultArray addObject:topLevelUserCollections];
                    
                    PHFetchResult *shareAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
                    [_photoResultArray addObject:shareAlbums];
                    
                    PHFetchResult *shareStream = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
                    [_photoResultArray addObject:shareStream];
                    
                    [self refreshalbums];
//                });
            }
        }];
    }
}

- (void)refreshalbums
{
    PHFetchResult *fetchResult = [_photoResultArray objectAtIndex:0];
    
    PHFetchResult *smartAlbums = [_photoResultArray objectAtIndex:1];
    
    PHFetchResult *topLevelUserCollections = [_photoResultArray objectAtIndex:2];
    
    PHFetchResult *shareAlbums = [_photoResultArray objectAtIndex:3];
    
    PHFetchResult *shareStream = [_photoResultArray objectAtIndex:4];
    
    NSMutableArray *tempPhototGroupArray = [[NSMutableArray alloc]init];
    if ([fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] > 0)
    {
        [tempPhototGroupArray addObject:fetchResult];
    }
    
    for (int i = 0 ; i < [smartAlbums count]; i++)
    {
        PHCollection *collection = [smartAlbums objectAtIndex:i];
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *tempResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        if ((assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos || assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumSlomoVideos || assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumAllHidden) && [tempResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] != 0)
        {
            [tempPhototGroupArray addObject:collection];
        }
    }
    for (int j = 0; j < [topLevelUserCollections count]; j++)
    {
        PHCollection *collection = [topLevelUserCollections objectAtIndex:j];
        PHFetchResult *tempResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
        if ([tempResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] != 0)
        {
            [tempPhototGroupArray addObject:collection];
        }
    }
    for (int k = 0; k < [shareAlbums count]; k++)
    {
        PHCollection *collection = [shareAlbums objectAtIndex:k];
        PHFetchResult *tempResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
        if ([tempResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] != 0)
        {
            [tempPhototGroupArray addObject:collection];
        }
    }
    for (int m = 0; m < [shareStream count]; m++)
    {
        PHCollection *collection = [shareStream objectAtIndex:m];
        PHFetchResult *tempResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
        if ([tempResult countOfAssetsWithMediaType:PHAssetMediaTypeImage] != 0)
        {
            [tempPhototGroupArray addObject:collection];
        }
    }
    NSLog(@"照片加载完成");
    self.photoGroupArray = tempPhototGroupArray;
//    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.photoGroupArray.count != 0)
        {
            [photoGroupTable reloadData];
        }
        
    });
    
}

//- (void)resetCachedAssets
//{
//    [self.imageManager stopCachingImagesForAllAssets];
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.imageManager = [[PHCachingImageManager alloc] init];
//    [self resetCachedAssets];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    AssetGridThumbnailSize = CGSizeMake(77*scale, 77*scale);

    photosArray = [[NSMutableArray alloc]init];

    photoGroupTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-135) style:UITableViewStylePlain];
    photoGroupTable.delegate = self;
    photoGroupTable.dataSource = self;
    photoGroupTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    photoGroupTable.backgroundColor = colorWithHexString(@"#202020");
    photoGroupTable.tag = 100;
    [photoGroupTable setRowHeight:100];
    [photoGroupTable setShowsVerticalScrollIndicator:NO];
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
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        if (iOS8)
        {
            PHCollection *tempCollection = nil;
            PHFetchResult *tempResult = nil;
            PHAsset *asset = nil;
            if (indexPath.row == 0)
            {
                tempResult = (PHFetchResult *)[self.photoGroupArray objectAtIndex:indexPath.row];
                cell.textLabel.text = LocalizedString(@"allPhoto", nil);
                asset = [tempResult objectAtIndex:0];
            }
            else
            {
                tempCollection = (PHCollection *)[self.photoGroupArray objectAtIndex:indexPath.row];
                NSLog(@"找图");
                tempResult =[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)tempCollection options:nil];
                NSLog(@"找完");
                cell.textLabel.text = tempCollection.localizedTitle;
                asset = [tempResult lastObject];
            }
            
            [[PHImageManager defaultManager] requestImageForAsset:asset
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
        
        PHCollection *collection = nil;
        PHFetchResult *assetsFetchResult = nil;
        SCImageCollectionViewController *collectionView = [[SCImageCollectionViewController alloc]init];
        collectionView.delegate = [[PRJ_Global shareStance] getSCCollectionViewDelegate];

        if (indexPath.row == 0)
        {
            assetsFetchResult = [photoGroupArray objectAtIndex:0];
        }
        else
        {
            collection = [photoGroupArray objectAtIndex:indexPath.row];
            assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
        }
        
        collectionView.assetsFetchResults = assetsFetchResult;
        
        [self.navigationController pushViewController:collectionView animated:YES];
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

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedCollectionsFetchResults = nil;
        
        for (PHFetchResult *collectionsFetchResult in _photoResultArray) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            if (changeDetails) {
                if (!updatedCollectionsFetchResults) {
                    updatedCollectionsFetchResults = [_photoResultArray mutableCopy];
                }
                [updatedCollectionsFetchResults replaceObjectAtIndex:[_photoResultArray indexOfObject:collectionsFetchResult] withObject:[changeDetails fetchResultAfterChanges]];
            }
        }
        
        if (updatedCollectionsFetchResults) {
            _photoResultArray = updatedCollectionsFetchResults;
            [self refreshalbums];
        }
        
    });
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
