//
//  ViewController.m
//  ZJHChangeIconDemo
//
//  Created by ZhangJingHao48 on 2020/12/18.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) NSArray *nameArr;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGRect temF;
@property (nonatomic, copy) NSString *imgFilePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nameArr = @[@"DEV", @"PRO"];
    
    CGFloat btnX = 100;
    CGFloat btnY = 70;
    CGFloat btnW = self.view.frame.size.width - btnX * 2;
    CGFloat btnH = btnW * 0.618;
    CGRect btnF = CGRectMake(btnX, btnY, btnW, btnH);
    UIButton *btn1 = [[UIButton alloc] initWithFrame:btnF];
    [btn1 setTitle:@"切换图标" forState:UIControlStateNormal];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self
             action:@selector(changeIcon:)
   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    btnY = btnY + btnH + 70;
    btnH = btnH * 0.5;
    btnF = CGRectMake(btnX, btnY, btnW, btnH);
    UIButton *btn2 = [[UIButton alloc] initWithFrame:btnF];
    [btn2 setTitle:@"处理Assets中的图标" forState:UIControlStateNormal];
    btn2.backgroundColor = [UIColor blueColor];
    [btn2 addTarget:self
             action:@selector(dealIcon:)
   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    btn2.tag = 2;
    
    btnY = btnY + btnH + 30;
    btnF = CGRectMake(btnX, btnY, btnW, btnH);
    UIButton *btn3 = [[UIButton alloc] initWithFrame:btnF];
    [btn3 setTitle:@"处理其他文件中的图标" forState:UIControlStateNormal];
    btn3.backgroundColor = [UIColor orangeColor];
    [btn3 addTarget:self
             action:@selector(dealIcon:)
   forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    btn3.tag = 3;
    
    CGFloat iconX = btn3.frame.origin.x;
    CGFloat iconWH = btn1.frame.size.width;
    CGFloat iconY = CGRectGetMaxY(btn3.frame) + 30;
    CGRect iconF = CGRectMake(iconX, iconY, iconWH, iconWH);
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconF];
    iconView.backgroundColor = [UIColor yellowColor];
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *temStr = @"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles";
    NSString *icon = [[infoPlist valueForKeyPath:temStr] lastObject];
    iconView.image = [UIImage imageNamed:icon];
    [self.view addSubview:iconView];
    self.iconView = iconView;
}

#pragma mark - 切换系统ICON

/// 切换系统icon
- (void)changeIcon:(UIButton *)btn {
    if (@available(iOS 10.3, *)) {
        // 判断系统是否支持
        if (![[UIApplication sharedApplication] supportsAlternateIcons]) {
            return;
        }
    }
    
    self.index++;
    if (self.index > self.nameArr.count) {
        self.index = 0;
    }
    NSString *iconName = nil;
    if (self.index < self.nameArr.count) {
        iconName = self.nameArr[self.index];
    }
        
    if (@available(iOS 10.3, *)) {
        // 设备指定图片，iconName为info.plist中的key
        [[UIApplication sharedApplication] setAlternateIconName:iconName completionHandler:^(NSError * error) {
            if (error) {
                NSLog(@"更换app图标发生错误了 ： %@",error);
            }
        }];
    }
}



#pragma mark - 自动生成带水印的图标

/// 处理icon：自动生成带水印的icon
- (void)dealIcon:(UIButton *)btn {
    [self imgFilePath];
    self.temF = self.iconView.frame;
    
    NSString *iconPath = nil;
    BOOL isOnlyWater = YES;

    if (btn.tag == 2) {
        isOnlyWater = NO;
        // 处理Assets.xcassets中的图片
        iconPath = [[NSBundle mainBundle] bundlePath];
    } else if (btn.tag == 3) {
#warning 这里需要改成自己需要打水印的图片地址
        iconPath = @"/Users/zjh48/Desktop/20201229App-icon/ios";
    }

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *temArr = [fileMgr contentsOfDirectoryAtPath:iconPath error:nil];
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSString *str in temArr) {
        
        if (isOnlyWater) { // 只打水印的图片
            NSString *imgPath = [NSString stringWithFormat:@"%@/%@", iconPath, str];
            UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
            if (!img) {
                continue;
            }
            CGFloat imgWH = [self getImgSizeWithIconName:str img:img];
            for (NSString *labStr in self.nameArr) {
                NSString *imgName = [str lastPathComponent];
                NSString *imgFilePath =
                [NSString stringWithFormat:@"%@_%@", self.imgFilePath, labStr];
                [self dealIconWithImg:img
                             iconName:imgName
                                imgWH:imgWH
                              labText:labStr
                          imgFilePath:imgFilePath];
            }
            continue;
        }
        
        if ([str hasPrefix:@"AppIcon"] && [str hasSuffix:@".png"] &&
            ![str containsString:@"~ipad"]) {
            [mutArr addObject:str];
            NSString *imgPath = [NSString stringWithFormat:@"%@/%@", iconPath, str];
            UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
            CGFloat imgWH = [self getImgSizeWithIconName:str img:img];
            for (NSString *labStr in self.nameArr) {
                NSString *oriName = [str lastPathComponent];
                NSString *imgName =
                [oriName stringByReplacingOccurrencesOfString:@"App"
                                                   withString:labStr];
                [self dealIconWithImg:img
                             iconName:imgName
                                imgWH:imgWH
                              labText:labStr
                          imgFilePath:nil];
            }
            
        }
    }
    
    // 还原视图
    [self.iconView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.iconView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.iconView.frame = self.temF;
}

// 处理图片
- (void)dealIconWithImg:(UIImage *)img
               iconName:(NSString *)iconName
                  imgWH:(CGFloat)imgWH
                labText:(NSString *)labText
            imgFilePath:(NSString *)imgFilePath{
    // 还原视图
    [self.iconView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.iconView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    // 设置框的大小和图片大小一致
    self.iconView.frame = CGRectMake(50, 50, imgWH, imgWH);
    // 设置图片
    self.iconView.image = img;

    // 图片靠左还是靠右
    BOOL isLeft = YES;
    
    // 添加背景三角形
    CGFloat triangleH = self.iconView.frame.size.width * 0.4;
    [self addTriangleWithInView:self.iconView height:triangleH isLeft:isLeft];
    
    // 添加文字
    // 已知直角三角形两个直角边长度，求斜边长度
    CGFloat labW = hypot(triangleH, triangleH);
    CGFloat rate = 0.3; // 文字高度比例
    CGFloat labH = labW * rate;
    // 下面是一道数学，拿着纸笔算出来的方法
    CGFloat labX = -triangleH * 0.5 * (sqrt(2) - (1-rate));
    CGFloat labY = triangleH * 0.5 * ( (1-rate) - sqrt(2) * rate);
    if (!isLeft) {
        CGFloat cX = labX + 0.5 * labW;
        CGFloat cY = labY + 0.5 * labH;
        cX = self.iconView.frame.size.width - cX;
        labX = cX - 0.5 * labW;
        labY = cY - 0.5 * labH;
    }
    CGRect labF = CGRectMake(labX, labY, labW, labH);
    UILabel *lab = [[UILabel alloc] initWithFrame:labF];
    lab.text = labText;
    lab.textColor = [UIColor whiteColor];
    lab.textAlignment = NSTextAlignmentCenter;
    CGFloat fontSize = labH * 0.85; // 文字大小
    lab.font = [UIFont boldSystemFontOfSize:fontSize];
    if (isLeft) {
        lab.transform = CGAffineTransformMakeRotation(-M_PI/4);
    } else {
        lab.transform = CGAffineTransformMakeRotation(M_PI/4);
    }
    [self.iconView addSubview:lab];
    
    // view截图
    UIGraphicsBeginImageContextWithOptions(self.iconView.frame.size, NO, 1);
    [self.iconView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.iconView.image = newImg;
    
    NSString *filePath = imgFilePath;
    if (!filePath) {
        filePath = self.imgFilePath;
    }
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:filePath]) {
        [fileMgr createDirectoryAtPath:filePath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    }
    
    /// 图片存储在沙河目录
    NSData *imgData = UIImagePNGRepresentation(newImg);
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@", filePath, iconName];
    [imgData writeToFile:imgPath atomically:YES];
}

/// 根据图片名获取图片尺寸
- (CGFloat)getImgSizeWithIconName:(NSString *)iconName img:(UIImage *)img {
    CGFloat imgW = img.size.width;
    if (![iconName containsString:@"@"]) {
        return imgW;
    }
        
    NSArray *arr1 = [iconName componentsSeparatedByString:@"@"];
    NSString *str1 = arr1.lastObject;
    NSArray *arr2 = [str1 componentsSeparatedByString:@"x"];
    NSString *str2 = arr2.firstObject;
    NSInteger num = [str2 integerValue];
    return num * imgW;
}

// 添加三角形
- (void)addTriangleWithInView:(UIView *)inView height:(CGFloat)height isLeft:(BOOL)isLeft {
    CAShapeLayer *triangleLayer = [[CAShapeLayer alloc]init];
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (isLeft) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0, height)];
        [path addLineToPoint:CGPointMake(height, 0)];
    } else {
        [path moveToPoint:CGPointMake(inView.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(inView.frame.size.width, height)];
        [path addLineToPoint:CGPointMake(inView.frame.size.width-height, 0)];
    }
    
    triangleLayer.path = path.CGPath;
    [inView.layer addSublayer:triangleLayer];
    UIColor *color = [UIColor colorWithRed:255.0/255 green:159.0/255 blue:47.0/255 alpha:1];
    [triangleLayer setFillColor:color.CGColor];
}

- (NSString *)imgFilePath {
    if (!_imgFilePath) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask,
                                                              YES) lastObject];
        _imgFilePath = [NSString stringWithFormat:@"%@/CustomIcon", path];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:_imgFilePath]) {
            [fileMgr createDirectoryAtPath:_imgFilePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        }
        NSLog(@"生成图片路经：%@", _imgFilePath);
    }
    return _imgFilePath;
}

@end
