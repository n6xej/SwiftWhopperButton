//
//  ViewController.m
//  WhopperTest
//
//  Created by Christopher Worley on 7/10/16.
//  Copyright © 2016 stashdump.com. All rights reserved.
//

#import "ViewController.h"
#import "WhopperTest-Swift.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet SwiftWhopperButton *burger;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)grillIt:(id)sender {
	
	_burger.isMenu = !_burger.isMenu;
}

- (IBAction)fryIt:(id)sender {
	
	SwiftWhopperButton *burg = (SwiftWhopperButton *)sender;
	
	if (burg.isMenu) {
		NSLog(@"Menu");
	}
	else {
		NSLog(@"Cancel");
	}
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
