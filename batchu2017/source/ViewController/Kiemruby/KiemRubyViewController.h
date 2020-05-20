//
//  ViewController.h
//  batchu
//
//  Created by MacBookPro on 9/17/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface KiemRubyViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{

}

@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic)  NSMutableArray *applist;
@end
