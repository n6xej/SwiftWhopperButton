//
//  SwiftWhopperButton.swift
//  SwiftWhopperButton
//
//  Created by Christopher Worley on 7/10/16.
//  Copyright © 2016 stashdump.com. All rights reserved.
//
//	The MIT License (MIT)
//
//	Copyright (c) 2016 Christopher Worley
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//

import UIKit

enum PathConvertType: Int {
	case None
	case Horizontal
	case Vertical
	case Both
	case NoneAndAlt
	case HorizontalAndAlt
	case VerticalAndAlt
	case BothAndAlt
}

@objc
@IBDesignable
class SwiftWhopperButton: UIButton {

	@objc
	@IBInspectable var lineColor: UIColor = UIColor.blackColor()

	@objc
	@IBInspectable var circleColor: UIColor = UIColor.clearColor()

	private var altAni: Bool = false

	@objc
	@IBInspectable var convert: Int = 0 {
		didSet {
			if convert > 3 {
				convert %= 4
				altAni = true
			} else {
				altAni = false
			}
		}
	}

	@objc
	@IBInspectable var isMenu: Bool = true {
		didSet {

			if topPos0 == nil {
				// If this is called before init, so can ignore
				// commonInit() has not happened
			} else {
				configButton()
			}
		}
	}

	private var topPos0: CGPoint?
	private var topPos1: CGPoint?
	private var bottomPos0: CGPoint?
	private var bottomPos1: CGPoint?
	private let cancelStrokeStart: CGFloat = 0.22
    private let cancelStrokeEnd: CGFloat = 0.9
    private let menuStrokeStart: CGFloat = 0.0218
    private let menuStrokeEnd: CGFloat = 0.1138
	private var _topLayer: CAShapeLayer!
	private var _middleLayer: CAShapeLayer!
	private var _bottomLayer: CAShapeLayer!
	private var _circleLayer: CAShapeLayer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	// MARK: Interface Builder
	override func awakeFromNib() {
		commonInit()
	}

	// MARK: Live Render
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()

		commonInit()
	}

    override init(frame: CGRect) {
        super.init(frame: frame)
		commonInit()
	}

	func commonInit() {
		_loadLayers()
		layoutSubviews()

		self.addTarget(self, action: #selector(SwiftWhopperButton.touchUpInside(_:event:)), forControlEvents: .TouchUpInside)

		// this is the one to start as parralel lines
		topPos0 = CGPointScaleFromSize(78.0740740740741, y: 33.3333333333333, fromSize: 100, toSize: frame.size, convert: .None)

		bottomPos0 = CGPointScaleFromSize(78.0740740740741, y: 66.6666666666667, fromSize: 100, toSize: frame.size, convert: .None)

		// this needs to be the final position when make X
		bottomPos1 = CGPointScaleFromSize(73.0740740740741, y: 66.6666666666667, fromSize: 100, toSize: frame.size, convert: .None)

		topPos1 = CGPointScaleFromSize(73.0740740740741, y: 33.3333333333333, fromSize: 100, toSize: frame.size, convert: .None)

		_middleLayer.position = CGPointScaleFromSize(50.0, y: 50.0, fromSize: 100, toSize: frame.size, convert: .None)

		// make anchor for lines
		_topLayer.anchorPoint = CGPoint(x: 0.9615, y: 1.0)
		_bottomLayer.anchorPoint = CGPoint(x: 0.9615, y: 0.0)

		if isMenu {

			_circleLayer.opacity = 0
			_topLayer.position = topPos0!
			_bottomLayer.position = bottomPos0!

			_middleLayer.strokeStart = menuStrokeStart
			_middleLayer.strokeEnd = menuStrokeEnd
		} else {
			_middleLayer.strokeStart = cancelStrokeStart
			_middleLayer.strokeEnd = cancelStrokeEnd

			// do pre-init
			_topLayer.position = topPos1!
			_bottomLayer.position = bottomPos1!

			let transform = CATransform3DMakeTranslation(0, 0, 0)
			_topLayer.transform = CATransform3DRotate(transform, -CGFloat.init(M_PI_4), 0, 0, 1)
			_bottomLayer.transform = CATransform3DRotate(transform, CGFloat.init(M_PI_4), 0, 0, 1)
		}
    }

	// the button will keep track of own state with button
	// presses. Can programmatically set button with isMenu property
	// but should not set in response to an event from an outlet
	func touchUpInside(sender: SwiftWhopperButton, event: UIEvent) {
		isMenu = !isMenu
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		if _topLayer.superlayer != layer {
			layer.addSublayer(_topLayer)
		}

		if _bottomLayer.superlayer != layer {
			layer.addSublayer(_bottomLayer)
		}

		if _middleLayer.superlayer != layer {
			layer.addSublayer(_middleLayer)
		}

		if _circleLayer.superlayer != layer {
			layer.insertSublayer(_circleLayer, atIndex: 0)
		}
	}

	private func _loadLayers() {

		_topLayer = CAShapeLayer()
		_topLayer.path = _menuPath

		_middleLayer = CAShapeLayer()
		_middleLayer.path = _cancelPath

		_bottomLayer = CAShapeLayer()
		_bottomLayer.path = _menuPath

		_circleLayer = CAShapeLayer()
		_circleLayer.path = _circlePath
		_circleLayer.fillColor = circleColor.CGColor

		let buttonLayers: [CAShapeLayer] = [_topLayer, _middleLayer, _bottomLayer]

		let space = fmin(frame.size.width, frame.size.height)
		let strokeWidth = ceil(space * 0.08)

		for layer in buttonLayers {

			layer.fillColor = nil
			layer.strokeColor = lineColor.CGColor
			layer.lineWidth = strokeWidth
			layer.lineCap = kCALineCapRound
			layer.masksToBounds = true

			let strokingPath = CGPathCreateCopyByStrokingPath(layer.path, nil, strokeWidth, .Round, .Miter, strokeWidth)

			layer.bounds = CGPathGetPathBoundingBox(strokingPath)
			
			// don't need this layoutSubviews() is called right after this
//			self.layer.addSublayer(layer)
		}
	}

	var _menuPath: CGPath {
		let newsize = frame.size
		let path = UIBezierPath()

		path.moveToPoint(CGPointScaleFromSize(4, y: 4, fromSize: 100, toSize: newsize, convert: .None))
		path.addLineToPoint(CGPointScaleFromSize(57.5, y: 4, fromSize: 100, toSize: newsize, convert: .None))

		return path.CGPath
	}

	private var _circlePath: CGPath {
		let circleRadius = fmin(frame.size.width / 2, frame.size.height / 2)

		return UIBezierPath(arcCenter: CGPointMake(frame.size.width / 2, frame.size.height / 2), radius: circleRadius, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true).CGPath
	}

	private var _cancelPath: CGPath {
		let scaledPoint = CGPointScaleFromSize
		let newsize = frame.size
		let convert = PathConvertType.init(rawValue: self.convert)!
		let path = UIBezierPath()

		path.moveToPoint(scaledPoint(18.5185185185185, y: 50.0, fromSize: 100, toSize: newsize, convert: convert))

		path.addCurveToPoint(scaledPoint(77.0, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(22.2222222222222, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(51.8888888888889, y: 50.0, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(50.0, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(103.555555555556, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(93.462962962963, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(3.7037037037037, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(24.3703703703704, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(3.7037037037037, y: 24.3703703703704, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(50.0, y: 96.2962962962963, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(3.7037037037037, y: 75.6296296296296, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(24.3703703703704, y: 96.2962962962963, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(96.2962962962963, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(75.6296296296296, y: 96.2962962962963, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(96.2962962962963, y: 75.6296296296296, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(50.0, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(96.2962962962963, y: 24.3703703703704, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(78.5, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(3.7037037037037, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(24.3703703703704, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(3.7037037037037, y: 24.3703703703704, fromSize: 100, toSize: newsize, convert: convert))
		return path.CGPath
	}

	private var _antiCancelPath: CGPath {
		let scaledPoint = CGPointScaleFromSize
		let newsize = frame.size
		let convert = PathConvertType.init(rawValue: 3 - self.convert)!
		let path = UIBezierPath()

		path.moveToPoint(scaledPoint(18.5185185185185, y: 50.0, fromSize: 100, toSize: newsize, convert: convert))

		path.addCurveToPoint(scaledPoint(77.0, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(22.2222222222222, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(51.8888888888889, y: 50.0, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(50.0, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(103.555555555556, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(93.462962962963, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(3.7037037037037, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(24.3703703703704, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(3.7037037037037, y: 24.3703703703704, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(50.0, y: 96.2962962962963, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(3.7037037037037, y: 75.6296296296296, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(24.3703703703704, y: 96.2962962962963, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(96.2962962962963, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(75.6296296296296, y: 96.2962962962963, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(96.2962962962963, y: 75.6296296296296, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(50.0, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(96.2962962962963, y: 24.3703703703704, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(78.5, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert))
		path.addCurveToPoint(scaledPoint(3.7037037037037, y: 50.0, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint1: scaledPoint(24.3703703703704, y: 3.7037037037037, fromSize: 100, toSize: newsize, convert: convert),
		                     controlPoint2: scaledPoint(3.7037037037037, y: 24.3703703703704, fromSize: 100, toSize: newsize, convert: convert))
		return path.CGPath
	}

	private func CGPointScaleFromSize(x: CGFloat, y: CGFloat, fromSize: CGFloat, toSize: CGSize, convert: PathConvertType) -> CGPoint {

		var newWidth = x / fromSize
		var newHeight = y / fromSize

		switch convert {
		case .Horizontal:
			newWidth = (fromSize - x) / fromSize

		case .Vertical:
			newHeight = (fromSize - y) / fromSize

		case .Both:
			newWidth = (fromSize - x) / fromSize
			newHeight = (fromSize - y) / fromSize

		default:
			break
		}

		newWidth *= toSize.width
		newHeight *= toSize.height

		return CGPointMake(newWidth, newHeight)
	}

	private var bSwitch: Bool = false
	private func configButton() {

		if isMenu {

//			print("menu")

			if altAni {
				bSwitch = !bSwitch
				if bSwitch {
					_middleLayer.path = _cancelPath
				} else {
					_middleLayer.path = _antiCancelPath
				}
			}

			_middleLayer.addAnimation(_makeMenuStrokeStart, forKey: "strokeStart")
			_middleLayer.addAnimation(_makeMenuStrokeEnd, forKey: "strokeEnd")
			_topLayer.addAnimation(_makeMenuPositionX, forKey: "x")
			_bottomLayer.addAnimation(_makeMenuPositionX, forKey: "x")
			_topLayer.addAnimation(_makeMenuTopTransform, forKey: "transform")
			_bottomLayer.addAnimation(_makeMenuBottomTransform, forKey: "transform")
			_circleLayer.addAnimation(_makeMenuOpacity, forKey: "opacity")

		} else {

//			print("cancel")

			if altAni {
				bSwitch = !bSwitch
				if bSwitch {
					_middleLayer.path = _cancelPath
				} else {
					_middleLayer.path = _antiCancelPath
				}
			}

			_middleLayer.addAnimation(_makeCancelStrokeStart, forKey: "strokeStart")
			_middleLayer.addAnimation(_makeCancelStrokeEnd, forKey: "strokeEnd")
			_topLayer.addAnimation(_makeCancelPositionX, forKey: "x")
			_bottomLayer.addAnimation(_makeCancelPositionX, forKey: "x")
			_topLayer.addAnimation(_makeCancelTopTransform, forKey: "transform")
			_bottomLayer.addAnimation(_makeCancelBottomTransform, forKey: "transform")
			_circleLayer.addAnimation(_makeCancelOpacity, forKey: "opacity")
		}
	}

	private var _makeMenuStrokeStart: CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "strokeStart")
		animation.fromValue = cancelStrokeStart
		animation.toValue = menuStrokeStart
		animation.duration = 0.5
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0, 0.5, 1.2)
		animation.beginTime = CACurrentMediaTime() + 0.1
		animation.fillMode = kCAFillModeBoth
		animation.removedOnCompletion = false

		return animation
	}

	private var _makeMenuStrokeEnd: CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = cancelStrokeEnd
		animation.toValue = menuStrokeEnd
		animation.duration = 0.6
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.3, 0.5, 0.9)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeMenuTopTransform: CABasicAnimation {
		let trans = CATransform3DMakeTranslation(0, 0, 0)
		let animation = CABasicAnimation(keyPath: "transform")
		animation.fromValue = NSValue(CATransform3D: CATransform3DRotate(trans, -CGFloat.init(M_PI_4), 0, 0, 1))
		animation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
		animation.beginTime = CACurrentMediaTime() + 0.05
		animation.duration = 0.4
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.785398, 0.5, 1.85)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeMenuBottomTransform: CABasicAnimation {
		let trans = CATransform3DMakeTranslation(0, 0, 0)
		let animation = CABasicAnimation(keyPath: "transform")
		animation.fromValue = NSValue(CATransform3D: CATransform3DRotate(trans, CGFloat.init(M_PI_4), 0, 0, 1))
		animation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
		animation.beginTime = CACurrentMediaTime() + 0.05
		animation.duration = 0.4
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.785398, 0.5, 1.85)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeMenuPositionX: CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "position.x")
		animation.fromValue = topPos1!.x
		animation.toValue = topPos0!.x
		animation.beginTime = CACurrentMediaTime() + 0.05
		animation.duration = 0.3
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeMenuOpacity: CABasicAnimation {
		let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
		animation.fromValue = 1
		animation.toValue = 0
		animation.beginTime = CACurrentMediaTime() + 0.05
		animation.duration = 0.2
		animation.fillMode = kCAFillModeBoth
		animation.removedOnCompletion = false

		return animation
	}

	private var _makeCancelStrokeStart: CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "strokeStart")
		animation.fromValue = menuStrokeStart
		animation.toValue = cancelStrokeStart
		animation.duration = 0.5
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeForwards

		return animation
	}

	private var _makeCancelStrokeEnd: CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = menuStrokeEnd
		animation.toValue = cancelStrokeEnd
		animation.duration = 0.6
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeForwards

		return animation
	}

	private var _makeCancelTopTransform: CABasicAnimation {
		let trans = CATransform3DMakeTranslation(0, 0, 0)
		let animation = CABasicAnimation(keyPath: "transform")
		animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
		animation.toValue = NSValue(CATransform3D: CATransform3DRotate(trans, -CGFloat.init(M_PI_4), 0, 0, 1))
		animation.beginTime = CACurrentMediaTime() + 0.25
		animation.duration = 0.4
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.785398, 0.5, 1.85)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeCancelBottomTransform: CABasicAnimation {
		let trans = CATransform3DMakeTranslation(0, 0, 0)
		let animation = CABasicAnimation(keyPath: "transform")
		animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
		animation.toValue = NSValue(CATransform3D: CATransform3DRotate(trans, CGFloat.init(M_PI_4), 0, 0, 1))
		animation.beginTime = CACurrentMediaTime() + 0.25
		animation.duration = 0.4
		animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.785398, 0.5, 1.85)
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeCancelPositionX: CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "position.x")
		animation.fromValue = topPos0!.x
		animation.toValue = topPos1!.x
		animation.beginTime = CACurrentMediaTime() + 0.15
		animation.duration = 0.3
		animation.removedOnCompletion = false
		animation.fillMode = kCAFillModeBoth

		return animation
	}

	private var _makeCancelOpacity: CABasicAnimation {
		let animation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
		animation.fromValue = 0
		animation.toValue = 1
		animation.beginTime = CACurrentMediaTime() + 0.35
		animation.duration = 0.2
		animation.fillMode = kCAFillModeBoth
		animation.removedOnCompletion = false

		return animation
	}

}
