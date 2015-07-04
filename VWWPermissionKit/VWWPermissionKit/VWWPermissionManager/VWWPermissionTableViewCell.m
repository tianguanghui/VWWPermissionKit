//
//  VWWPermissionTableViewCell.m
//  
//
//  Created by Zakk Hoyt on 6/11/15.
//
//

#import "VWWPermissionTableViewCell.h"
#import "VWWPermission.h"
#import "VWWPermissionNotifications.h"
#import "VWWPermissionAppearance.h"

@interface VWWPermissionTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *permissionLabel;
@property (weak, nonatomic) IBOutlet UIButton *permissionButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightConstraint;
@end

@implementation VWWPermissionTableViewCell

-(void)setPermission:(VWWPermission *)permission{
    _permission = permission;
    self.permissionLabel.text = permission.labelText;
    
    [self addObserver:self forKeyPath:@"permission.status" options:NSKeyValueObservingOptionNew context:nil];
    [self skinButton];
}

-(void)setAppearance:(VWWPermissionAppearance *)appearance{
    _appearance = appearance;
    self.backgroundColor = self.appearance.backgroundColor;
    self.permissionButton.layer.borderColor = self.appearance.tintColor.CGColor;
}

#pragma mark Private methods
- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.permissionButton.layer.borderWidth = 1.0;
    self.permissionButton.layer.cornerRadius = 4.0;
    self.permissionButton.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.permissionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.permissionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                
        // On iOS8 and iPhone5s, Body size ranges from 14-23. Use this to scale the button height
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        CGFloat factor = font.pointSize - 14.0;
        factor *= 5;
        self.buttonHeightConstraint.constant = 30 + factor;
    }];
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"permission.status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self skinButton];
    });
}

-(void)skinButton{
    
    self.permissionButton.enabled = YES;
    
    switch (self.permission.status) {
        case VWWPermissionStatusAuthorized:{
            [self.permissionButton setBackgroundColor:self.appearance.authorizedColor];
            [self.permissionButton setTitleColor:self.appearance.authorizedTextColor forState:UIControlStateNormal];
            NSString *buttonTitle = [[NSString stringWithFormat:@"%@ allowed", self.permission.type] uppercaseString];
            [self.permissionButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
            break;
        case VWWPermissionStatusDenied:{
            [self.permissionButton setBackgroundColor:self.appearance.deniedColor];
            [self.permissionButton setTitleColor:self.appearance.deniedTextColor forState:UIControlStateNormal];
            NSString *buttonTitle = [[NSString stringWithFormat:@"%@ denied", self.permission.type] uppercaseString];
            [self.permissionButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
            break;
        case VWWPermissionStatusRestricted:{
            [self.permissionButton setBackgroundColor:self.appearance.restrictedColor];
            [self.permissionButton setTitleColor:self.appearance.restrictedTextColor forState:UIControlStateNormal];
            NSString *buttonTitle = [[NSString stringWithFormat:@"%@ restricted", self.permission.type] uppercaseString];
            [self.permissionButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
            break;
        case VWWPermissionStatusUninitialized:{
            [self.permissionButton setBackgroundColor:self.appearance.uninitializedColor];
            [self.permissionButton setTitleColor:self.appearance.uninitializedTextColor forState:UIControlStateNormal];
            NSString *buttonTitle = [[NSString stringWithFormat:@"%@ ???", self.permission.type] uppercaseString];
            [self.permissionButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
            break;
        case VWWPermissionStatusNotDetermined:{
            [self.permissionButton setBackgroundColor:self.appearance.notDeterminedColor];
            [self.permissionButton setTitleColor:self.appearance.notDeterminedTextColor forState:UIControlStateNormal];
            NSString *buttonTitle = [[NSString stringWithFormat:@"allow %@", self.permission.type] uppercaseString];
            [self.permissionButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
            break;
        case VWWPermissionStatusServiceNotAvailable:{
            self.permissionButton.enabled = NO;
            [self.permissionButton setBackgroundColor:self.appearance.serviceNotAvailableColor];
            [self.permissionButton setTitleColor:self.appearance.serviceNotAvailableTextColor forState:UIControlStateNormal];
            NSString *buttonTitle = [[NSString stringWithFormat:@"%@ (not available)", self.permission.type] uppercaseString];
            [self.permissionButton setTitle:buttonTitle forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (IBAction)promptButtonTouchUpInside:(id)sender {
    if(self.permission.status == VWWPermissionStatusDenied ||
       self.permission.status == VWWPermissionStatusRestricted){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else if(self.permission.status == VWWPermissionStatusNotDetermined ||
              self.permission.status == VWWPermissionStatusUninitialized){
        NSDictionary *userInfo = @{VWWPermissionNotificationsPermissionKey : self.permission};
        [[NSNotificationCenter defaultCenter] postNotificationName:VWWPermissionNotificationsPromptAction object:nil userInfo:userInfo];
    }
    
    

    
}

@end
