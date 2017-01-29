//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import QuartzCore

extension CALayer {
    func transform(x:CGFloat, y:CGFloat, z:CGFloat, angle:CGFloat, duration:CFTimeInterval, beginTime:CFTimeInterval) {
        var transform = CATransform3DMakeRotation(angle, x, y, z)
        
        // Add perspective
        if y > 0 {
            transform.m34 = 0.0006
        } else {
            transform.m34 = -0.0006
        }
        
        let animation = CABasicAnimation(keyPath: "transform")
        
        animation.toValue = transform
        animation.duration = duration
        animation.beginTime = beginTime
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.add(animation, forKey: "transform-\(x)-\(y)-\(z)")
    }
    
    func hideAfterDelay(_ beginTime: CFTimeInterval,_ hide:Bool = true) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.toValue = hide ? 0 : 1.0
        animation.duration = 0.1
        animation.beginTime = beginTime
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.add(animation, forKey: "hide-\(beginTime)")
    }
    
    func diagonalFold(_ xValue:CGFloat,_ duration:CFTimeInterval = 2.0,_ beginTime:CFTimeInterval) {
        self.transform(x: xValue, y: 1, z: 0, angle: CGFloat.pi, duration: duration, beginTime: beginTime)
    }
    
    func horizontalFold(_ yValue:CGFloat,_ duration:CFTimeInterval = 2.0,_ beginTime:CFTimeInterval) {
        self.transform(x: 0, y: yValue, z: 0, angle: CGFloat.pi, duration: duration, beginTime: beginTime)
    }
    
    func moveX(_ xValue:CGFloat,_ duration:CFTimeInterval,_ beginTime: CFTimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "position.x")
        
        animation.byValue = xValue
        animation.duration = duration
        animation.beginTime = beginTime
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.add(animation, forKey: "move-\(xValue)")
    }
    
    func moveY(_ yValue:CGFloat,_ duration:CFTimeInterval,_ beginTime: CFTimeInterval) {
        
        let animation = CABasicAnimation(keyPath: "position.y")
        
        animation.byValue = yValue
        animation.duration = duration
        animation.beginTime = beginTime
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.add(animation, forKey: "move-\(yValue)")
    }
}

extension CGPath {
    func mirror() -> CGPath {
        return PathUtils.mirrorPath(path: self)
    }
}

class PathUtils {
    static func trianglePath(rect:CGRect, transform:CGAffineTransform = .identity) -> CGPath {
        let path = CGMutablePath()
        
        path.move(to: .zero, transform: transform)
        
        path.addLine(to: CGPoint(x: rect.width, y: 0), transform: transform)
        
        path.addLine(to: CGPoint(x: 0, y: rect.height), transform: transform)
        
        path.addLine(to: .zero, transform: transform)
        
        return path.copy()!
    }
    
    static func trapezoidPath(rect: CGRect, b lengthOfB:CGFloat, transform:CGAffineTransform = .identity) -> CGPath {
        
        let path = CGMutablePath()
        
        path.move(to: .zero, transform: transform)
        
        path.move(to: CGPoint(x: 0.0, y: lengthOfB), transform: transform)
        
        path.addLine(to: CGPoint(x: 0.0, y: rect.height), transform: transform)
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height), transform: transform)
        
        path.addLine(to: CGPoint(x: rect.width, y: 0.0), transform: transform)
        
        path.addLine(to: CGPoint(x: 0.0, y: lengthOfB), transform: transform)
        
        return path.copy()!
    }
    
    static func mirrorPath(path: CGPath) -> CGPath {
        let mutalbePath = UIBezierPath(cgPath: path)
        
        mutalbePath.apply(CGAffineTransform.identity.scaledBy(x: -1, y: 1))

        mutalbePath.apply(CGAffineTransform.identity.translatedBy(x: mutalbePath.bounds.width, y: 0))
        
        return mutalbePath.cgPath
    }
}

class Paper: UIView {
    
    private let topLeftSide = CAShapeLayer()
    private let topRightSide = CAShapeLayer()
    private let farLeftSide = CAShapeLayer()
    private let nearLeftSide = CAShapeLayer()
    private let farRightSide = CAShapeLayer()
    private let nearRightSide = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        self.layer.addSublayer(self.farLeftSide)
        self.layer.addSublayer(self.nearLeftSide)
        self.layer.addSublayer(self.nearRightSide)
        self.layer.addSublayer(self.farRightSide)
        self.layer.addSublayer(self.topLeftSide)
        self.layer.addSublayer(self.topRightSide)
        
        self.layer.sublayers?.forEach({ (layer) in
//            layer.borderWidth = 1.0
            
            if let shape = layer as? CAShapeLayer {
                shape.fillColor = UIColor.red.cgColor
            }
        })
        
        self.setupAnchorsPoints()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let bSideLength = round(self.bounds.width * 0.25)
        
        self.topLeftSide.frame = CGRect(x: 0,
                                        y: 0,
                                        width: round(self.bounds.width * 0.5),
                                        height: round(self.bounds.width * 0.5))
        
        self.topRightSide.frame = CGRect(x: round(self.bounds.width * 0.5),
                                         y: 0,
                                         width: round(self.bounds.width * 0.5),
                                         height: round(self.bounds.width * 0.5))
        
        self.farLeftSide.frame = CGRect(x: 0,
                                     y: bSideLength,
                                     width: bSideLength,
                                     height: self.bounds.height - bSideLength)
        self.nearLeftSide.frame = CGRect(x: bSideLength,
                                         y: 0,
                                         width: bSideLength,
                                         height: self.bounds.height)
        self.nearRightSide.frame = CGRect(x: round(self.bounds.width * 0.5),
                                        y: 0,
                                        width: bSideLength,
                                        height: self.bounds.height)
        self.farRightSide.frame = CGRect(x: round(self.bounds.width * 0.75),
                                         y: bSideLength,
                                         width: bSideLength,
                                         height: self.bounds.height - bSideLength)
        
        // Setup paths
        self.setupPaths()
    }
    
    func setupPaths() {
        let bSideLength = round(self.bounds.width * 0.25)
        
        self.topLeftSide.path = PathUtils.trianglePath(rect: self.topLeftSide.bounds)
        
        self.topRightSide.path = PathUtils.trianglePath(rect: self.topRightSide.bounds).mirror()
        
        self.farLeftSide.path = PathUtils.trapezoidPath(rect: self.farLeftSide.bounds, b: bSideLength)
        
        self.nearLeftSide.path = PathUtils.trapezoidPath(rect: self.nearLeftSide.bounds, b: bSideLength)
        
        self.farRightSide.path = PathUtils.trapezoidPath(rect: self.farRightSide.bounds, b: bSideLength).mirror()
        
        self.nearRightSide.path = PathUtils.trapezoidPath(rect: self.nearRightSide.bounds, b: bSideLength).mirror()
    }
    
    func setupAnchorsPoints() {
        self.farRightSide.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.nearRightSide.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        self.farLeftSide.anchorPoint = CGPoint(x: 2.0, y: 0.5)
        self.nearLeftSide.anchorPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    func animate() {
        let duration: Double = 1.0
        
        let beginTime = CACurrentMediaTime() + 1
        
        self.topLeftSide.diagonalFold(-1, duration, beginTime + 0)
        self.topLeftSide.hideAfterDelay(beginTime + duration)
        
        self.topRightSide.diagonalFold(1, duration, beginTime + 1)
        self.topRightSide.hideAfterDelay(beginTime + 1 + duration)
        
        self.farLeftSide.horizontalFold(1, duration, beginTime + 2)
        //self.farLeftSide.hideAfterDelay(beginTime + 2 + duration)
        
        self.nearLeftSide.horizontalFold(1, duration, beginTime + 2)
        self.nearLeftSide.hideAfterDelay(beginTime + 2 + duration)
    
        //self.RightSide.horizontalFold(-1, duration, beginTime + 3)
        self.farRightSide.horizontalFold(-1, duration, beginTime + 3)
        //self.farRightSide.hideAfterDelay(beginTime + 3 + duration)
        
        self.nearRightSide.transform(x: 0, y: -1, z: 0, angle: .pi * 0.5, duration: duration, beginTime: beginTime + 4)

        // Postion
        self.farRightSide.moveX(-self.farRightSide.bounds.width, duration, beginTime + 4)
        self.farLeftSide.moveX(-self.farLeftSide.bounds.width, duration, beginTime + 4)
        
        self.farRightSide.moveY(-self.bounds.height, duration, beginTime + 5)
        self.farLeftSide.moveY(-self.bounds.height, duration, beginTime + 5)
    }
}

let paperSize = CGSize(width:400,height:500)

let sheet = Paper(frame: CGRect(origin: .zero, size: paperSize))

sheet.animate()

PlaygroundPage.current.liveView = sheet
