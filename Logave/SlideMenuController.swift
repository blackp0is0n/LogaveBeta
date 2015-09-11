//
//  SlideMenuController.swift
//
//  Created by Yuji Hato on 12/3/14.
//

import Foundation
import UIKit

public struct SlideMenuOptions {
    public static var leftViewWidth: CGFloat = 270.0
    public static var leftBezelWidth: CGFloat = 16.0
    public static var contentViewScale: CGFloat = 0.96
    public static var contentViewOpacity: CGFloat = 0.5
    public static var shadowOpacity: CGFloat = 0.0
    public static var shadowRadius: CGFloat = 0.0
    public static var shadowOffset: CGSize = CGSizeMake(0,0)
    public static var panFromBezel: Bool = true
    public static var animationDuration: CGFloat = 0.4
    public static var rightViewWidth: CGFloat = 270.0
    public static var rightBezelWidth: CGFloat = 16.0
    public static var rightPanFromBezel: Bool = true
    public static var hideStatusBar: Bool = true
    public static var pointOfNoReturnWidth: CGFloat = 44.0
	public static var opacityViewBackgroundColor: UIColor = UIColor.blackColor()
}

public class SlideMenuController: UIViewController, UIGestureRecognizerDelegate {

    public enum SlideAction {
        case Open
        case Close
    }
    
    public enum TrackAction {
        case TapOpen
        case TapClose
        case FlickOpen
        case FlickClose
    }
    
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    public var opacityView = UIView()
    public var mainContainerView = UIView()
    public var leftContainerView = UIView()
    public var rightContainerView =  UIView()
    public var mainViewController: UIViewController?
    public var leftViewController: UIViewController?
    public var leftPanGesture: UIPanGestureRecognizer?
    public var leftTapGetsture: UITapGestureRecognizer?
    public var rightViewController: UIViewController?
    public var rightPanGesture: UIPanGestureRecognizer?
    public var rightTapGesture: UITapGestureRecognizer?
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        leftViewController = leftMenuViewController
        initView()
    }
    
    public convenience init(mainViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        rightViewController = rightMenuViewController
        initView()
    }
    
    public convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        leftViewController = leftMenuViewController
        rightViewController = rightMenuViewController
        initView()
    }
    
    deinit { }
    
    func initView() {
        mainContainerView = UIView(frame: view.bounds)
        mainContainerView.backgroundColor = UIColor.clearColor()
        mainContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        view.insertSubview(mainContainerView, atIndex: 0)

        var opacityframe: CGRect = view.bounds
        var opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = SlideMenuOptions.opacityViewBackgroundColor
        opacityView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        opacityView.layer.opacity = 0.0
        view.insertSubview(opacityView, atIndex: 1)
        
        var leftFrame: CGRect = view.bounds
        leftFrame.size.width = SlideMenuOptions.leftViewWidth
        leftFrame.origin.x = leftMinOrigin();
        var leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView = UIView(frame: leftFrame)
        leftContainerView.backgroundColor = UIColor.clearColor()
        leftContainerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        view.insertSubview(leftContainerView, atIndex: 2)
        
        addLeftGestures()
    }
  
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        leftContainerView.hidden = true
        rightContainerView.hidden = true
      
        coordinator.animateAlongsideTransition(nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.closeLeftNonAnimation()
            self.leftContainerView.hidden = false
      
            if self.leftPanGesture != nil && self.leftPanGesture != nil {
                self.removeLeftGestures()
                self.addLeftGestures()
            }
        })
    }
  
    public override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge.None
    }
    
    public override func viewWillLayoutSubviews() {
        // topLayoutGuideの値が確定するこのタイミングで各種ViewControllerをセットする
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        setUpViewController(leftContainerView, targetViewController: leftViewController)
    }
    
    public override func openLeft() {
        setOpenWindowLevel()
        
        //leftViewControllerのviewWillAppearを呼ぶため
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        openLeftWithVelocity(0.0)
        
        track(.TapOpen)
    }
    
    
    public override func closeLeft() {
        leftViewController?.beginAppearanceTransition(isLeftHidden(), animated: true)
        closeLeftWithVelocity(0.0)
        setCloseWindowLebel()
    }
    
    
    
    public func addLeftGestures() {
    
        if (leftViewController != nil) {
            if leftPanGesture == nil {
                leftPanGesture = UIPanGestureRecognizer(target: self, action: "handleLeftPanGesture:")
                leftPanGesture!.delegate = self
                view.addGestureRecognizer(leftPanGesture!)
            }
            
            if leftTapGetsture == nil {
                leftTapGetsture = UITapGestureRecognizer(target: self, action: "toggleLeft")
                leftTapGetsture!.delegate = self
                view.addGestureRecognizer(leftTapGetsture!)
            }
        }
    }
    
    
    public func removeLeftGestures() {
        
        if leftPanGesture != nil {
            view.removeGestureRecognizer(leftPanGesture!)
            leftPanGesture = nil
        }
        
        if leftTapGetsture != nil {
            view.removeGestureRecognizer(leftTapGetsture!)
            leftTapGetsture = nil
        }
    }
    
    public func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return true
    }
    
    public func track(trackAction: TrackAction) {
        // function is for tracking
        // Please to override it if necessary
    }
    
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRectZero
        static var startPointOfPan: CGPoint = CGPointZero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    func handleLeftPanGesture(panGesture: UIPanGestureRecognizer) {
        
        if !isTagetViewController() {
            return
        }
        
        
        switch panGesture.state {
            case UIGestureRecognizerState.Began:
                
                LeftPanState.frameAtStartOfPan = leftContainerView.frame
                LeftPanState.startPointOfPan = panGesture.locationInView(view)
                LeftPanState.wasOpenAtStartOfPan = isLeftOpen()
                LeftPanState.wasHiddenAtStartOfPan = isLeftHidden()
                
                leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
                addShadowToView(leftContainerView)
                setOpenWindowLevel()
            case UIGestureRecognizerState.Changed:
                
                var translation: CGPoint = panGesture.translationInView(panGesture.view!)
                leftContainerView.frame = applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
                applyLeftOpacity()
                applyLeftContentViewScale()
            case UIGestureRecognizerState.Ended:
                
                var velocity:CGPoint = panGesture.velocityInView(panGesture.view)
                var panInfo: PanInfo = panLeftResultInfoForVelocity(velocity)
                
                if panInfo.action == .Open {
                    if !LeftPanState.wasHiddenAtStartOfPan {
                        leftViewController?.beginAppearanceTransition(true, animated: true)
                    }
                    openLeftWithVelocity(panInfo.velocity)
                    track(.FlickOpen)
                    
                } else {
                    if LeftPanState.wasHiddenAtStartOfPan {
                        leftViewController?.beginAppearanceTransition(false, animated: true)
                    }
                    closeLeftWithVelocity(panInfo.velocity)
                    setCloseWindowLebel()
                    
                    track(.FlickClose)

                }
        default:
            break
        }
        
    }
    

    

    
    public func openLeftWithVelocity(velocity: CGFloat) {
        var xOrigin: CGFloat = leftContainerView.frame.origin.x
        var finalXOrigin: CGFloat = 0.0
        
        var frame = leftContainerView.frame;
        frame.origin.x = finalXOrigin;
        
        var duration: NSTimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        addShadowToView(leftContainerView)
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(SlideMenuOptions.contentViewScale, SlideMenuOptions.contentViewScale)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.disableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
    }
    
    
    public func closeLeftWithVelocity(velocity: CGFloat) {
        
        var xOrigin: CGFloat = leftContainerView.frame.origin.x
        var finalXOrigin: CGFloat = leftMinOrigin()
        
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
    
        var duration: NSTimeInterval = Double(SlideMenuOptions.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { [weak self]() -> Void in
            if let strongSelf = self {
                strongSelf.leftContainerView.frame = frame
                strongSelf.opacityView.layer.opacity = 0.0
                strongSelf.mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }
            }) { [weak self](Bool) -> Void in
                if let strongSelf = self {
                    strongSelf.removeShadow(strongSelf.leftContainerView)
                    strongSelf.enableContentInteraction()
                    strongSelf.leftViewController?.endAppearanceTransition()
                }
        }
    }
    
    
    
    
    public override func toggleLeft() {
        if isLeftOpen() {
            closeLeft()
            setCloseWindowLebel()
            // closeMenuはメニュータップ時にも呼ばれるため、closeタップのトラッキングはここに入れる
            
            track(.TapClose)
        } else {
            openLeft()
        }
    }
    
    public func isLeftOpen() -> Bool {
        return leftContainerView.frame.origin.x == 0.0
    }
    
    public func isLeftHidden() -> Bool {
        return leftContainerView.frame.origin.x <= leftMinOrigin()
    }
    
    
    public func changeMainViewController(mainViewController: UIViewController,  close: Bool) {
        
        removeViewController(self.mainViewController)
        self.mainViewController = mainViewController
        setUpViewController(mainContainerView, targetViewController: mainViewController)
        if (close) {
            closeLeft()
        }
    }
    
    public func changeLeftViewController(leftViewController: UIViewController, closeLeft:Bool) {
        
        removeViewController(self.leftViewController)
        self.leftViewController = leftViewController
        setUpViewController(leftContainerView, targetViewController: leftViewController)
        if closeLeft {
            self.closeLeft()
        }
    }
    
    
    private func leftMinOrigin() -> CGFloat {
        return  -SlideMenuOptions.leftViewWidth
    }
    
    
    
    private func panLeftResultInfoForVelocity(velocity: CGPoint) -> PanInfo {
        
        var thresholdVelocity: CGFloat = 1000.0
        var pointOfNoReturn: CGFloat = CGFloat(floor(leftMinOrigin())) + SlideMenuOptions.pointOfNoReturnWidth
        var leftOrigin: CGFloat = leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .Close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .Close : .Open;
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .Open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .Close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    
    private func applyLeftTranslation(translation: CGPoint, toFrame:CGRect) -> CGRect {
        
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        var minOrigin: CGFloat = leftMinOrigin()
        var maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    

    
    private func getOpenedLeftRatio() -> CGFloat {
        
        var width: CGFloat = leftContainerView.frame.size.width
        var currentPosition: CGFloat = leftContainerView.frame.origin.x - leftMinOrigin()
        return currentPosition / width
    }
    
    
    private func applyLeftOpacity() {
        
        var openedLeftRatio: CGFloat = getOpenedLeftRatio()
        var opacity: CGFloat = SlideMenuOptions.contentViewOpacity * openedLeftRatio
        opacityView.layer.opacity = Float(opacity)
    }
    
    

    
    private func applyLeftContentViewScale() {
        var openedLeftRatio: CGFloat = getOpenedLeftRatio()
        var scale: CGFloat = 1.0 - ((1.0 - SlideMenuOptions.contentViewScale) * openedLeftRatio);
        mainContainerView.transform = CGAffineTransformMakeScale(scale, scale)
    }
    

    
    private func addShadowToView(targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = false
        targetContainerView.layer.shadowOffset = SlideMenuOptions.shadowOffset
        targetContainerView.layer.shadowOpacity = Float(SlideMenuOptions.shadowOpacity)
        targetContainerView.layer.shadowRadius = SlideMenuOptions.shadowRadius
        targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).CGPath
    }
    
    private func removeShadow(targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = true
        mainContainerView.layer.opacity = 1.0
    }
    
    private func removeContentOpacity() {
        opacityView.layer.opacity = 0.0
    }
    

    private func addContentOpacity() {
        opacityView.layer.opacity = Float(SlideMenuOptions.contentViewOpacity)
    }
    
    private func disableContentInteraction() {
        mainContainerView.userInteractionEnabled = false
    }
    
    private func enableContentInteraction() {
        mainContainerView.userInteractionEnabled = true
    }
    
    private func setOpenWindowLevel() {
        if (SlideMenuOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    private func setCloseWindowLebel() {
        if (SlideMenuOptions.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    private func setUpViewController(targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            addChildViewController(viewController)
            viewController.view.frame = targetView.bounds
            targetView.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    
    private func removeViewController(viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.willMoveToParentViewController(nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    public func closeLeftNonAnimation(){
        setCloseWindowLebel()
        var finalXOrigin: CGFloat = leftMinOrigin()
        var frame: CGRect = leftContainerView.frame;
        frame.origin.x = finalXOrigin
        leftContainerView.frame = frame
        opacityView.layer.opacity = 0.0
        mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0)
        removeShadow(leftContainerView)
        enableContentInteraction()
    }
    
    
    //pragma mark – UIGestureRecognizerDelegate
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    
        var point: CGPoint = touch.locationInView(view)
        
        if gestureRecognizer == leftPanGesture {
            return slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        }else if gestureRecognizer == leftTapGetsture {
            return isLeftOpen() && !isPointContainedWithinLeftRect(point)
        }
        
        return true
    }
    
    private func slideLeftForGestureRecognizer( gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        return isLeftOpen() || SlideMenuOptions.panFromBezel && isLeftPointContainedWithinBezelRect(point)
    }
    
    private func isLeftPointContainedWithinBezelRect(point: CGPoint) -> Bool{
        var leftBezelRect: CGRect = CGRectZero
        var tempRect: CGRect = CGRectZero
        var bezelWidth: CGFloat = SlideMenuOptions.leftBezelWidth
        
        CGRectDivide(view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectEdge.MinXEdge)
        return CGRectContainsPoint(leftBezelRect, point)
    }
    
    private func isPointContainedWithinLeftRect(point: CGPoint) -> Bool {
        return CGRectContainsPoint(leftContainerView.frame, point)
    }
    
    
    

    
    private func isRightPointContainedWithinBezelRect(point: CGPoint) -> Bool {
        var rightBezelRect: CGRect = CGRectZero
        var tempRect: CGRect = CGRectZero
        //CGFloat bezelWidth = rightContainerView.frame.size.width;
        var bezelWidth: CGFloat = CGRectGetWidth(view.bounds) - SlideMenuOptions.rightBezelWidth
        
        CGRectDivide(view.bounds, &tempRect, &rightBezelRect, bezelWidth, CGRectEdge.MinXEdge)
        
        return CGRectContainsPoint(rightBezelRect, point)
    }
    
    private func isPointContainedWithinRightRect(point: CGPoint) -> Bool {
        return CGRectContainsPoint(rightContainerView.frame, point)
    }
    
}


extension UIViewController {

    public func slideMenuController() -> SlideMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is SlideMenuController {
                return viewController as? SlideMenuController
            }
            viewController = viewController?.parentViewController
        }
        return nil;
    }
    
    public func addLeftBarButtonWithImage(buttonImage: UIImage) {
        var leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "toggleLeft")
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    
    public func toggleLeft() {
        slideMenuController()?.toggleLeft()
    }
    
    public func openLeft() {
        slideMenuController()?.openLeft()
    }
    
    
    public func closeLeft() {
        slideMenuController()?.closeLeft()
    }
    
    
    // Please specify if you want menu gesuture give priority to than targetScrollView
    public func addPriorityToMenuGesuture(targetScrollView: UIScrollView) {
        if let slideControlelr = slideMenuController() {
            let recognizers =  slideControlelr.view.gestureRecognizers
            for recognizer in recognizers as! [UIGestureRecognizer] {
                if recognizer is UIPanGestureRecognizer {
                    targetScrollView.panGestureRecognizer.requireGestureRecognizerToFail(recognizer)
                }
            }
        }
    }
}