import Foundation
import AsyncDisplayKit

public class WindowRootViewController: UIViewController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return false
    }
}

@objc
public protocol WindowContentController {
    func setViewSize(toSize: CGSize, duration: NSTimeInterval)
    var view: UIView! { get }
}

public func animateRotation(view: UIView?, toFrame: CGRect, duration: NSTimeInterval) {
    if let view = view {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            view.frame = toFrame
        })
    }
}

public func animateRotation(view: ASDisplayNode?, toFrame: CGRect, duration: NSTimeInterval) {
    if let view = view {
        CALayer.beginRecordingChanges()
        view.frame = toFrame
        view.layout()
        let states = CALayer.endRecordingChanges() as! [CALayerAnimation]
        let k = Float(UIView.animationDurationFactor())
        var speed: Float = 1.0
        if k != 0 && k != 1 {
            speed = Float(1.0) / k
        }
        for state in states {
            if let layer = state.layer {
                if !CGRectEqualToRect(state.startBounds, state.endBounds) {
                    let boundsAnimation = CABasicAnimation(keyPath: "bounds")
                    boundsAnimation.fromValue = NSValue(CGRect: state.startBounds)
                    boundsAnimation.toValue = NSValue(CGRect: state.endBounds)
                    boundsAnimation.duration = duration
                    boundsAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    boundsAnimation.removedOnCompletion = true
                    boundsAnimation.fillMode = kCAFillModeForwards
                    boundsAnimation.speed = speed
                    layer.addAnimation(boundsAnimation, forKey: "_rotationBounds")
                }
                
                if !CGPointEqualToPoint(state.startPosition, state.endPosition) {
                    let positionAnimation = CABasicAnimation(keyPath: "position")
                    positionAnimation.fromValue = NSValue(CGPoint: state.startPosition)
                    positionAnimation.toValue = NSValue(CGPoint: state.endPosition)
                    positionAnimation.duration = duration
                    positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    positionAnimation.removedOnCompletion = true
                    positionAnimation.fillMode = kCAFillModeForwards
                    positionAnimation.speed = speed
                    layer.addAnimation(positionAnimation, forKey: "_rotationPosition")
                }
            }
        }
    }
}

public class Window: UIWindow {
    public convenience init() {
        self.init(frame: UIScreen.mainScreen().bounds)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.rootViewController = WindowRootViewController()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return self.viewController?.view.hitTest(point, withEvent: event)
    }
    
    public override var frame: CGRect {
        get {
            return super.frame
        }
        set(value) {
            let sizeUpdated = super.frame.size != value.size
            super.frame = value
            if sizeUpdated {
                self.viewController?.setViewSize(value.size, duration: self.isRotating() ? 0.3 : 0.0)
            }
        }
    }
    
    public override var bounds: CGRect {
        get {
            return super.frame
        }
        set(value) {
            let sizeUpdated = super.bounds.size != value.size
            super.bounds = value
            if sizeUpdated {
                self.viewController?.setViewSize(value.size, duration: self.isRotating() ? 0.3 : 0.0)
            }
        }
    }
    
    private var _rootViewController: WindowContentController?
    public var viewController: WindowContentController? {
        get {
            return _rootViewController
        }
        set(value) {
            self._rootViewController?.view.removeFromSuperview()
            self._rootViewController = value
            self._rootViewController?.view.frame = self.bounds
            /*if let reactiveController = self._rootViewController as? ReactiveViewController {
                reactiveController.displayNode.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
                self.addSubview(reactiveController.displayNode.view)
            }
            else {*/
                if let view = self._rootViewController?.view {
                    self.addSubview(view)
                }
            //}
        }
    }
}
