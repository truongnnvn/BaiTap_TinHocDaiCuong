

import UIKit

internal class CircleMenuButton: UIButton {

    // MARK: properties

    internal weak var container: UIView?

    // MARK: life cycle

    init(size: CGSize, circleMenu: CircleMenu, distance: Float, angle: Float = 0) {
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))

        self.backgroundColor = UIColor(colorLiteralRed: 0.79, green: 0.24, blue: 0.27, alpha: 1)
        self.layer.cornerRadius = size.height / 2.0

        let aContainer = createContainer(CGSize(width: size.width, height:CGFloat(distance)), circleMenu: circleMenu)

        // hack view for rotate
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(self)
        //...

        aContainer.addSubview(view)
        container = aContainer

        view.layer.transform = CATransform3DMakeRotation(-CGFloat(angle.degrees), 0, 0, 1)

        self.rotatedZ(angle: angle, animated: false)
    }

    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: configure

    private func createContainer(size: CGSize, circleMenu: CircleMenu) -> UIView {

        guard let circleMenuSuperView = circleMenu.superview else {
            fatalError("wront circle menu")
        }

        let container = Init(UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size))) {
            $0.backgroundColor                           = UIColor.clearColor()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.anchorPoint                         = CGPoint(x: 0.5, y: 1)
        }
        circleMenuSuperView.insertSubview(container, belowSubview: circleMenu)

        // added constraints
        let height = NSLayoutConstraint(item: container,
                                   attribute: .Height,
                                   relatedBy: .Equal,
                                      toItem: nil,
                                   attribute: .Height,
                                  multiplier: 1,
                                    constant: size.height)
        height.identifier = "height"
        container.addConstraint(height)

        container.addConstraint(NSLayoutConstraint(item: container,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Width,
            multiplier: 1,
            constant: size.width))

        circleMenuSuperView.addConstraint(NSLayoutConstraint(item: circleMenu,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: container,
            attribute: .CenterX,
            multiplier: 1,
            constant:0))

        circleMenuSuperView.addConstraint(NSLayoutConstraint(item: circleMenu,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: container,
            attribute: .CenterY,
            multiplier: 1,
            constant:0))

        return container
    }

    // MARK: methods

    internal func rotatedZ(angle angle: Float, animated: Bool, duration: Double = 0, delay: Double = 0) {
        guard let container = self.container else {
            fatalError("contaner don't create")
        }

        let rotateTransform = CATransform3DMakeRotation(CGFloat(angle.degrees), 0, 0, 1)
        if animated {
            UIView.animateWithDuration(
                duration,
                delay: delay,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { () -> Void in
                    container.layer.transform = rotateTransform
                },
                completion: nil)
        } else {
            container.layer.transform = rotateTransform
        }
    }
}

// MARK: Animations

internal extension CircleMenuButton {

    internal func showAnimation(distance distance: Float, duration: Double, delay: Double = 0) {

        guard let container = self.container else {
            fatalError()
        }

        let heightConstraint = self.container?.constraints.filter {$0.identifier == "height"}.first

        guard heightConstraint != nil else {
            return
        }
        self.transform = CGAffineTransformMakeScale(0, 0)
        self.container?.layoutIfNeeded()

        self.alpha = 0

        heightConstraint?.constant = CGFloat(distance)
        UIView.animateWithDuration(
            duration,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                container.layoutIfNeeded()
                self.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.alpha = 1
            }, completion: { (success) -> Void in
        })
    }

    internal func hideAnimation(distance distance: Float, duration: Double, delay: Double = 0) {

        guard let container = self.container else {
            fatalError()
        }

        let heightConstraint = self.container?.constraints.filter {$0.identifier == "height"}.first

        guard heightConstraint != nil else {
            return
        }
        heightConstraint?.constant = CGFloat(distance)
        UIView.animateWithDuration(
            duration,
            delay: delay,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                container.layoutIfNeeded()
                self.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }, completion: { (success) -> Void in
                self.alpha = 0

                if let _ = self.container {
                    container.removeFromSuperview() // remove container
                }
        })
    }

    internal func changeDistance(distance: CGFloat, animated: Bool, duration: Double = 0, delay: Double = 0) {

        guard let container = self.container else {
            fatalError()
        }

        let heightConstraint = self.container?.constraints.filter {$0.identifier == "height"}.first

        guard heightConstraint != nil else {
            return
        }

        heightConstraint?.constant = distance

        UIView.animateWithDuration(
            duration,
            delay: delay,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                container.layoutIfNeeded()
            },
            completion: nil)
    }

    // MARK: layer animation

    internal func rotationLayerAnimation(angle: Float, duration: Double) {
        if let aContainer = container {
            rotationLayerAnimation(aContainer, angle: angle, duration: duration)
        }
    }
}

internal extension UIView {

    internal func rotationLayerAnimation(view: UIView, angle: Float, duration: Double) {

        let rotation = Init(CABasicAnimation(keyPath: "transform.rotation")) {
            $0.duration       = NSTimeInterval(duration)
            $0.toValue        = (angle.degrees)
            $0.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        }
        view.layer.addAnimation(rotation, forKey: "rotation")
    }
}
