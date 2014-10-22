//
//  SCImageCollectionViewController.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-25.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

@protocol scImageCollectionViewDelegate <NSObject>

- (void)getChoosePhoto:(UIImage *)image;
- (void)getChoosePhotoURL:(NSURL *)url;

@end

@interface SCImageCollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *collectionView;
}

@property (nonatomic, strong) NSArray *photosArray;
@property (nonatomic, assign) id<scImageCollectionViewDelegate>delegate;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
