//
//  ViewController.swift
//  SwiftBurgerButton
//
//  Created by Christopher Worley on 7/10/16.
//  Copyright © 2016 stashdump.com. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

	@IBOutlet weak var burger0: SwiftWhopperButton!
	@IBOutlet weak var burger1: SwiftWhopperButton!
	@IBOutlet weak var burger2: SwiftWhopperButton!
	@IBOutlet weak var burger3: SwiftWhopperButton!


	@IBAction func doMenu(sender: SwiftWhopperButton) {
// do not set isMenu on click, taken care of internally
		if sender.isMenu {
			print("Was a Menu")
			print("Now an X")
		}
		else {
			print("Was an X")
			print("Now a Menu")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
//		
//		to create a window programatically do this:
//
//		let width = UIScreen.mainScreen().bounds.size.width / 2
//		let quarter = width/2
//		
//		let rect = CGRectMake(quarter , 50, 50, 50)
//		
//		let vc = SwiftWopperButton.init(frame: rect)
//		vc.lineColor = UIColor.yellowColor()
//		vc.circleColor = UIColor.purpleColor()
//		vc.convert = PathConvertType.HorizontalAndAlt.rawValue
//		vc.isMenu = false


		NSTimer.schedule(delay: 0.75) { timer in
			self.doDemo()
		}

	}

	var demoCnt = 3
	func doDemo() {
		
		// see if expired
		if self.demoCnt == 0 {
			return
		}
		
		self.demoCnt -= 1
		
		NSTimer.schedule(delay: 0.0) { timer in
			self.burger0.isMenu = !self.burger0.isMenu
			NSTimer.schedule(delay: 1.0) { timer in
				self.burger0.isMenu = !self.burger0.isMenu
			}
		}
		NSTimer.schedule(delay: 2.25){ timer in
			self.burger1.isMenu = !self.burger1.isMenu
			NSTimer.schedule(delay: 1.0) { timer in
				self.burger1.isMenu = !self.burger1.isMenu
			}
		}
		NSTimer.schedule(delay: 4.5) { timer in
			self.burger2.isMenu = !self.burger2.isMenu
			NSTimer.schedule(delay: 1.0) { timer in
				self.burger2.isMenu = !self.burger2.isMenu
			}
		}
		NSTimer.schedule(delay: 6.75){ timer in
			self.burger3.isMenu = !self.burger3.isMenu
			NSTimer.schedule(delay: 1.0) { timer in
				self.burger3.isMenu = !self.burger3.isMenu
			}
			NSTimer.schedule(delay: 2.25){ timer in
				self.doDemo()
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

extension NSTimer {
	class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
		let fireDate = delay + CFAbsoluteTimeGetCurrent()
		let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
		CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
		return timer
	}
	
	class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
		let fireDate = interval + CFAbsoluteTimeGetCurrent()
		let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
		CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
		return timer
	}
}



