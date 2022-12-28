//
//  JLSelectView.swift
//  JanLi
//
//  Created by admin on 2021/10/25.
//  Copyright © 2021 com.baoluchuling.janli. All rights reserved.
//

import UIKit

class JLSelectView: UIView {
    
    var inoutLabel: UIView?
    
    
    init() {
        self.select = false
        self.strokeColor = UIColor.white
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var click: ((Bool) -> Void)?
    
    var select: Bool = false {
        willSet {
            if click != nil {
                click!(newValue)
            }
            
            if newValue {
                self.backgroundColor = UIColor.clear
            } else {
                self.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            }
        }
    }
        
    var strokeColor: UIColor? {
        didSet {
            if !select {
                self.setNeedsDisplay()
            }
        }
    }
    
    var selectColor: UIColor? {
        didSet {
            if select {
                self.setNeedsDisplay()
            }
        }
    }
    
    @objc func onClick() -> Void {
        self.select = !self.select
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: rect.size))
        
        let radius: CGFloat = 15 / 2 - 1
        let arcCenter = CGPoint(x: rect.maxX - 5 - 15 + radius, y: rect.maxY - 5 - 15 + radius)
        
        if select {
            context?.addArc(center: arcCenter, radius: radius, startAngle: 0, endAngle: 2*CGFloat(Double.pi), clockwise: true)
            context?.setFillColor(self.selectColor?.cgColor ?? UIColor.clear.cgColor)
            context?.fillPath()
        }
        
        context?.setStrokeColor(self.strokeColor?.cgColor ?? UIColor.clear.cgColor)
        context?.setLineWidth(1.5)
        context?.addArc(center: arcCenter, radius: radius, startAngle: 0, endAngle: 2*CGFloat(Double.pi), clockwise: true)
        context?.strokePath()
    }
}
