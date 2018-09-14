//
//  UIAlertController+Dismiss.h
//  alert
//
//  Created by 张冬阳 on 2018/9/14.
//  Copyright © 2018年 张冬阳. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AlertControllerActionBlock)(void);
/* 有UITextField时，block返回YES或block为空，点击确定dimiss。
	block中可以对输入的合法性进行验证，合法走正常的流程，非法时UIAlertController不会消失。
*/
typedef BOOL (^AlertControllerTextFieldValidateBlock)(NSString *text);

@interface UIAlertController (Dismiss)

@property(nonatomic, copy) AlertControllerTextFieldValidateBlock validateBlock;

- (void)addActionWithStyle:(UIAlertActionStyle)style title:(NSString *)title
                     block:(nullable AlertControllerActionBlock)block;

- (void)showInController:(nullable UIViewController *)destinationController;

- (void)showInWindow;

@end

NS_ASSUME_NONNULL_END
