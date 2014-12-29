//
//  CatalogViewController.m
//  SwiftLanguage
//
//  Created by Moch Xiao on 12/29/14.
//  Copyright (c) 2014 Foobar. All rights reserved.
//

#import "CatalogViewController.h"
#import "DetailViewController.h"

NSString *const kCatalogCellIdentifier = @"CatalogCell";
NSString *const kShowDetailSegue = @"ShowDetail";

@interface CatalogViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *statusBar;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) NSString *bundlePath;
@end

@implementation CatalogViewController

#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self customUserInterface];
}

- (void)customUserInterface {
	self.navigationController.navigationBar.hidden = YES;
	self.statusBar.backgroundColor = self.tableView.backgroundColor;
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ContentCatalog" ofType:@"plist"];
	_dataArray = [NSArray arrayWithContentsOfFile:filePath];
	[self.tableView reloadData];
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:kShowDetailSegue]) {
		DetailViewController *detail = segue.destinationViewController;
		NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
		NSString *bundleFileName = self.dataArray[indexPath.section][indexPath.row][@"link"];
		detail.bundleFileName = bundleFileName;
	}
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCatalogCellIdentifier forIndexPath:indexPath];
		
	cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row][@"name"];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @[@"Welcome to Swift", @"Swift Course", @"Language Refrence"][section];
}

#pragma mark - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:kShowDetailSegue sender:self];
}


@end
