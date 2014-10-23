//
//  SCImageCollectionViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-25.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCImageCollectionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


static CGSize AssetGridThumbnailSize;


@interface SCImageCollectionViewController ()
{
    NSInteger notImageCount;
}
@property (nonatomic, strong) NSMutableArray *assetsArray;

@end

@implementation SCImageCollectionViewController

@synthesize photosArray;
@synthesize assetsArray;
@synthesize delegate;
@synthesize assetsFetchResults = _assetsFetchResults;
@synthesize assetCollection = _assetCollection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    notImageCount = 0;
    
    
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    // 2.设置每个格子的尺寸
    flowLayout.itemSize = CGSizeMake(75, 75);
    // 3.设置整个collectionView的内边距
    CGFloat paddingY = 4;
    CGFloat paddingX = 4;
    flowLayout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);

    // 4.设置每一行之间的间距
    flowLayout.minimumLineSpacing = 4;
    flowLayout.minimumInteritemSpacing = 4;
    
    AssetGridThumbnailSize = CGSizeMake(77, 77);
    
    collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-135) collectionViewLayout:flowLayout];
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    

    // Do any additional setup after loading the view.
}

- (void)setAssetsFetchResults:(PHFetchResult *)assetsFetchResults
{
    assetsArray = [[NSMutableArray alloc]init];
    _assetsFetchResults = assetsFetchResults;
    for (int i = 0; i < assetsFetchResults.count; i++)
    {
        PHAsset *asset = assetsFetchResults[i];
        if (asset.mediaType == PHAssetMediaTypeImage)
        {
            [assetsArray addObject:asset];
        }
    }
}

#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

//每个分区上的元素个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (iOS8)
    {
        return [self.assetsFetchResults countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    }
    else
    {
        return [photosArray count];
    }
}

//设置元素内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (!cell) {
        
    }
    else
    {
        if (iOS8)
        {
            UIImageView *cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 77, 77)];
            cellImage.contentMode = UIViewContentModeScaleAspectFit;
            [cell addSubview:cellImage];
                        
            PHAsset *asset = [assetsArray objectAtIndex:indexPath.row];
            
            [[PHImageManager defaultManager] requestImageForAsset:asset
                                                       targetSize:AssetGridThumbnailSize
                                                      contentMode:PHImageContentModeAspectFill
                                                          options:nil
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        
                                                        // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                                        cellImage.image = result;
                                                    }];
            
        }
        else
        {
            UIImageView *cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 77, 77)];
            ALAsset *asset = [photosArray objectAtIndex:indexPath.row];
            CGImageRef ref = [asset thumbnail];
            UIImage *image = [UIImage imageWithCGImage:ref];
            
            cellImage.image = image;
            [cell addSubview:cellImage];
        }
    }
    
    
    return cell;
}


////设置元素的的大小框
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    UIEdgeInsets top = {2.5,2.5,0,0};
//    return top;
//}
//
////设置顶部的大小
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    CGSize size={2.5,2.5};
//    return size;
//}
////设置元素大小
//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    //NSLog(@"%f",(kDeviceHeight-88-49)/4.0);
//    return CGSizeMake(74.5,74.5);
//}

//点击元素触发事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (iOS8)
    {
        PHAsset *asset = [assetsArray objectAtIndex:indexPath.row];
        
        [[PHImageManager defaultManager]requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
         {
             UIImage *image = [UIImage imageWithData:imageData];
             [delegate getChoosePhoto:image];
         }];

    }
    else
    {
        NSLog(@"点击");
        ALAsset *asset = [photosArray objectAtIndex:indexPath.row];
        NSLog(@"%@",[asset valueForProperty:ALAssetPropertyRepresentations]);
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        UIImage *image;
        //    if (rep.orientation)
        //    {
        //        image = [UIImage imageWithCGImage:[rep fullScreenImage]
        //                                             scale:[rep scale]
        //                                       orientation:(UIImageOrientation)rep.orientation];
        //    }
        //    else
        //    {
        image = [UIImage imageWithCGImage:[rep fullScreenImage]
                                    scale:[rep scale]
                              orientation:UIImageOrientationUp];
        //    }
        
        NSLog(@"获得图片");
        
        [delegate getChoosePhoto:image];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
