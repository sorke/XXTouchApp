//
//  XXCreateItemTableViewController.m
//  XXTouchApp
//
//  Created by Zheng on 9/2/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "XXCreateItemTableViewController.h"

typedef enum : NSUInteger {
    kXXCreateItemTypeRegularLuaFile = 0,
    kXXCreateItemTypeRegulatTextFile,
    kXXCreateItemTypeDirectory,
} kXXCreateItemType;

@interface XXCreateItemTableViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (nonatomic, assign) kXXCreateItemType selectedType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation XXCreateItemTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.itemNameTextField.delegate = self;
    {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (void)viewTapped:(UITapGestureRecognizer *)tapGesture {
    if ([_itemNameTextField isFirstResponder]) {
        [_itemNameTextField resignFirstResponder];
    }
}

- (IBAction)nameTextFieldChanged:(UITextField *)sender {
    NSString *itemName = sender.text;
    if (itemName.length == 0 || itemName.length > 255) {
        self.doneButton.enabled = NO;
    } else if ([itemName containsString:@"/"]) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
}

- (IBAction)cancel:(id)sender {
    if ([self.itemNameTextField isFirstResponder]) {
        [self.itemNameTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSString *itemName = _itemNameTextField.text;
    if (itemName.length == 0) {
        [self.navigationController.view makeToast:XXLString(@"Item name cannot be empty.")];
        return;
    } else if ([itemName containsString:@"/"]) {
        [self.navigationController.view makeToast:XXLString(@"Invalid item name.")];
        return;
    }
    BOOL result = NO;
    NSError *err = nil;
    kXXCreateItemType itemType = self.selectedType;
    NSString *itemPath = [self.currentDirectory stringByAppendingPathComponent:itemName];
    if (itemType == kXXCreateItemTypeRegularLuaFile) {
        itemPath = [itemPath stringByAppendingPathExtension:@"lua"];
        result = [FCFileManager createFileAtPath:itemPath error:&err];
    } else if (itemType == kXXCreateItemTypeRegulatTextFile) {
        itemPath = [itemPath stringByAppendingPathExtension:@"txt"];
        result = [FCFileManager createFileAtPath:itemPath error:&err];
    } else if (itemType == kXXCreateItemTypeDirectory) {
        result = [FCFileManager createDirectoriesForPath:itemPath error:&err];
    }
    if (result == YES) {
        if ([self.itemNameTextField isFirstResponder]) {
            [self.itemNameTextField resignFirstResponder];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (err != nil) {
        [self.navigationController.view makeToast:[err localizedDescription]];
    } else {
        [self.navigationController.view makeToast:XXLString(@"Unknown error")];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_itemNameTextField isFirstResponder]) {
        [_itemNameTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSIndexPath *oldPath = [NSIndexPath indexPathForRow:self.selectedType inSection:1];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedType = indexPath.row;
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
