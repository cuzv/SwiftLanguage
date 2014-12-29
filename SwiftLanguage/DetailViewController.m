//
//  ViewController.m
//  SwiftLanguage
//
//  Created by Moch Xiao on 12/29/14.
//  Copyright (c) 2014 Foobar. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@end

@implementation DetailViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self customUserInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.webView stopLoading];
}

- (void)customUserInterface {
	NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:self.bundleFileName ofType:@"html"];
	NSURL *fileURL = [NSURL URLWithString:bundleFilePath];
	NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
	[self.webView loadRequest:request];
	
	UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(forward:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:swipeLeft];
	
	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
	[self.view addGestureRecognizer:swipeRight];
}

#pragma mark - 

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil];
	[alert addAction:cancel];
	[self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		
		NSString *requestURLString  = [request.URL absoluteString];
		NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
		if ([requestURLString rangeOfString:resourcePath].location == NSNotFound) {
			NSString *last = [requestURLString lastPathComponent];
			NSString *newRequestString = [resourcePath stringByAppendingPathComponent:last];
			newRequestString = [@"file://" stringByAppendingString:newRequestString];
			
			NSRange anchorLinkRange = [requestURLString rangeOfString:@"#"];
			if (anchorLinkRange.location != NSNotFound) {
				NSUInteger location = anchorLinkRange.location;
				NSString *anchorLinkString = [requestURLString substringFromIndex:location];
				[newRequestString stringByAppendingString:anchorLinkString];
			}
			
			NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:newRequestString]];
			[self.webView loadRequest:newRequest];
			return NO;
		}
	}
	return YES;
}

#pragma mark - Actions

- (void)back:(id)sender {
	if ([self.webView canGoBack]) {
		[self.webView goBack];
	}
}

- (void)forward:(id)sender {
	if ([self.webView canGoForward]) {
		[self.webView goForward];
	}
}


@end
