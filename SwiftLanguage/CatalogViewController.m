//
//  CatalogViewController.m
//  SwiftLanguage
//
//  Created by Moch Xiao on 2014-12-29.
//	Copyright (c) 2014 Moch Xiao (htt://github.com/atcuan).
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "CatalogViewController.h"
#import "DetailViewController.h"

NSString *const kCatalogCellIdentifier = @"CatalogCell";
NSString *const kSearchCellIdentifier = @"SearchCell";
NSString *const kShowDetailSegue = @"ShowDetail";

@interface CatalogViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *statusBar;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, copy) NSString *bundlePath;

@property (nonatomic, strong) NSArray *allSearchItems;
@property (nonatomic, strong) NSMutableArray *searchDataArray;

@property (nonatomic, assign) BOOL searching;

@end

@implementation CatalogViewController

- (NSArray *)allSearchItems {
	if (!_allSearchItems) {
		NSArray *items = [[self.dataArray valueForKey:@"value"] allObjects];
		NSMutableArray *allItems = [NSMutableArray new];
		for (NSArray *item in items) {
			[allItems addObjectsFromArray:item];
		}
		_allSearchItems = [NSArray arrayWithArray:allItems];
	}
	
	return _allSearchItems;
}

- (NSMutableArray *)searchDataArray {
	if (!_searchDataArray) {
		_searchDataArray = [NSMutableArray new];
	}
	
	return _searchDataArray;
}

#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self customUserInterface];
}

- (void)customUserInterface {
	self.navigationController.navigationBar.hidden = YES;
	self.statusBar.backgroundColor = self.tableView.backgroundColor;
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Catalog" ofType:@"plist"];
	_dataArray = [NSArray arrayWithContentsOfFile:filePath];
	[self.tableView reloadData];
	
	self.searchBar.placeholder = @"Search";
	self.searchBar.tintColor = [UIColor redColor];
	self.tableView.contentOffset = CGPointMake(0, self.searchBar.bounds.size.height);
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:kShowDetailSegue]) {
		DetailViewController *detail = segue.destinationViewController;
		NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
		NSString *bundleFileName = nil;
		if (self.searching) {
			bundleFileName = self.searchDataArray[indexPath.row][@"link"];
		} else {
			bundleFileName = self.dataArray[indexPath.section][@"value"][indexPath.row][@"link"];
		}
		detail.bundleFileName = bundleFileName;
	}
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.searching ? 1 : self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.searching ? self.searchDataArray.count : [self.dataArray[section][@"value"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCatalogCellIdentifier forIndexPath:indexPath];
	
	NSString *name = nil;
	
	if (self.searching) {
		name = self.searchDataArray[indexPath.row][@"name"];
	} else {
		name = self.dataArray[indexPath.section][@"value"][indexPath.row][@"name"];
		NSString *title = [NSString stringWithFormat:@"%zd.%zd ", indexPath.section + 1, indexPath.row + 1];
		name = [title stringByAppendingString:name];
	}

	cell.textLabel.text = name;
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.searching ? nil : self.dataArray[section][@"key"];
}

#pragma mark - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:kShowDetailSegue sender:self];
	[self searchBarCancelButtonClicked:self.searchBar];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[_searchDataArray removeAllObjects];
	
	for (NSDictionary *item in self.allSearchItems) {
		if ([item[@"name"] rangeOfString:searchText].location != NSNotFound) {
			[self.searchDataArray addObject:item];
		}
	}
	
	[self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	self.searching = YES;
	searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	searchBar.showsCancelButton = NO;
	searchBar.text = @"";
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	self.searching = NO;
	[self.tableView reloadData];
}

@end
