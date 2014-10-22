//
//  BYHProtocolClass.h
//  BaYingHe
//
//  Created by 高 on 14-3-17.
//  Copyright (c) 2014年 高录扬. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BackgroundSecondToolBarView;
@class PaletteView;
@class PRJ_ImageEditToolBarView;
@class PRJ_FilterToolBarView;
@class LableStickerView;
@class PRJ_ImageEditToolBarView;
@class BackgroundToolBarView;
@class CameraApertureView;
@class ControlBorder;
@class CornerView;
@class PRJ_TypeFaceObject;

typedef enum {
    kImageEditToolBarItemFull = 0,  //填满
    kImageEditToolBarItemCenter,    //居中
    kImageEditToolBarItemRotate,     //旋转90度
    kImageEditToolBarItemHorMir,     //水平翻转
    kImageEditToolBarItemVerMir,     //垂直翻转
    kImageEditToolBarItemCut         //剪裁
} ImageEditToolBarItemType;

typedef enum {
    leftAligment = NSTextAlignmentLeft,
    centerAligment = NSTextAlignmentCenter,
    rightAligment = NSTextAlignmentRight
}TextAligment;

@protocol LabelActionDelegate <NSObject>

- (void)didTouchedLabel:(NSUInteger)tag;


@end

@protocol WebRequestDelegate <NSObject>

- (void)didReceivedData:(NSDictionary *)dic withTag:(NSInteger)tag;
- (void)requestFailed:(NSInteger)tag;

@end

@protocol DoneTextDelegate <NSObject>

- (void)touchDoneBtnWithContent:(NSString *)content textAligment:(TextAligment)aligment;

@optional
- (void)touchDoneWithExitLabel:(NSString *)content textAligment:(TextAligment)aligment centerPoint:(CGPoint)point;

@end


@protocol TouchLabelMarkDelegate <NSObject>

- (void)touchLabelMarkTag:(LableStickerView *)lableMark;

@optional
- (void)lableStickerViewEditBtnOnClick:(LableStickerView *)lableStickerView;
@end

@protocol DownLoadTypeFaceDelegate <NSObject>

- (void)haveDownLoadTypeFaceIndex:(NSInteger)index;

@end

@protocol ChangeLabelFontDelegate <NSObject>

- (void)didSelectContentFont:(NSString *)fontName;

@optional
- (void)didDeleteContentFont:(NSString *)fontName;

@end

@protocol ResigenTypeFaceDelegate <NSObject>

- (void)resigenSuccess:(PRJ_TypeFaceObject *)typeFace;

@optional

- (void)deleteTypeFace:(NSString *)name;

@end

@protocol BackgroundSecondToolBarViewDelegate <NSObject>

/**
 *  选中了背景图片时调用
 *
 *  @param toolBar 二级工具栏对象
 *  @param image   选中的背景图片
 */
- (void)backgroundSecondToolBarView:(BackgroundSecondToolBarView *)toolBar DidSelectedWithImage:(UIImage *)image;

/**
 *  二级工具栏向代理请求退出
 *
 *  @param toolBar 二级工具栏对象
 */
- (void)backgroundSecondToolBarViewRequestRetain:(BackgroundSecondToolBarView *)toolBar;

@end

@protocol PaletteViewDelegate <NSObject>
@optional

/**
 *  选中颜色时调用
 *
 *  @param paletteView 取色板对象
 *  @param color       当前选中的颜色
 */
- (void)paletteView:(PaletteView *)paletteView DidSelectedColor:(UIColor *)color;


/**
 *  平移手势开始时调用
 *
 *  @param paletteView 取色板对象
 *  @param color       当前选中的颜色
 */
- (void)paletteView:(PaletteView *)paletteView ToucheBeginWithSelectedColor:(UIColor *)color;


/**
 *  平移手势结束时调用
 *
 *  @param paletteView 取色板对象
 */
- (void)paletteViewToucheEnd:(PaletteView *)paletteView withColor:(UIColor *)color;

@end

@protocol PRJ_ImageEditToolBarViewDelegate <NSObject>

- (void)imageEditToolBarView:(PRJ_ImageEditToolBarView *)toolBar ItemClickWithType:(ImageEditToolBarItemType)type;

@end

@protocol PRJ_FilterToolBarViewDelegate <NSObject>
@optional
/**
 *  选中了某个滤镜效果时调用
 *
 *  @param toolBar 滤镜工具栏
 *  @param type    滤镜类型
 */
- (void)filterToolBar:(PRJ_FilterToolBarView *)toolBar DidSelectedItemWithFilterType:(int)type;

@end

@protocol BackgroundToolBarViewDelegate <NSObject>
@optional
- (void)backgroundToolBarItemOnClick:(BackgroundToolBarView *)toolBar;
- (void)backgroundToolBar:(BackgroundToolBarView *)toolBar DidSelectedBgImage:(UIImage *)image;
- (void)backgroundToolBar:(BackgroundToolBarView *)toolBar DidSelectedBgColor:(UIColor *)color;
- (void)backgroundToolBarClearBgColor:(BackgroundToolBarView *)toolBar;

//- (void)backgroundToolBar:(BackgroundToolBarView *)toolBar BeginSelectedColor:(UIColor *)color;
- (void)backgroundToolBarEndSelected:(BackgroundToolBarView *)toolBar;
@end

@protocol CameraApertureDelegate <NSObject>

/**
 *  当frame改变时，通知代理对象
 *
 *  @param cameraAperture 透明截图框cameratAperture对象
 */
- (void)cameraApertureFrameChanged:(CameraApertureView *)cameraAperture;

@end

@protocol ControlBorderDelegate <NSObject>
@optional
- (void)controlBorder:(ControlBorder *)controlBorder MoveBeginWithTouch:(UITouch *)touch;
- (void)controlBorder:(ControlBorder *)controlBorder MovedWithTouch:(UITouch *)touch;
- (void)controlBorderMoveEnd:(ControlBorder *)controlBorder;
@end

@protocol CornerDelegate <NSObject>

@optional

/**********************************************************
 函数名称：- (void)corner:(Corner *)corner TouchesMoved:(UITouch *)touch
 函数描述：当touchesMoved事件被触发时此方法会被调用
 输入参数：(Corner *)corner 被触发touchesMoved事件的view
 输入参数：(UITouch *)touch touch事件
 输出参数：N/A
 返回值：N/A
 **********************************************************/
- (void)corner:(CornerView *)corner TouchesMoved:(UITouch *)touch;


/**********************************************************
 函数名称：- (void)corner:(Corner *)corner TouchesBegin:(UITouch *)touch
 函数描述：当TouchesBegin事件被触发时此方法会被调用
 输入参数：(Corner *)corner 被触发touchesMoved事件的view
 输入参数：(UITouch *)touch touch事件
 输出参数：N/A
 返回值：N/A
 **********************************************************/
- (void)corner:(CornerView *)corner TouchesBegin:(UITouch *)touch;


/**********************************************************
 函数名称：- (void)corner:(Corner *)corner TouchesEnd:(UITouch *)touch
 函数描述：当TouchesEnd事件被触发时此方法会被调用
 输入参数：(Corner *)corner 被触发touchesMoved事件的view
 输入参数：(UITouch *)touch touch事件
 输出参数：N/A
 返回值：N/A
 **********************************************************/
- (void)corner:(CornerView *)corner TouchesEnd:(UITouch *)touch;

@end


@protocol MoreAppDelegate <NSObject>

- (void)jumpAppStore:(NSString *)appid;

@end