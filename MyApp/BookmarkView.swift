//
//  BookmarkView.swift
//  MyApp
//
//  Created by Vladislav Stolyarov on 20.03.2023.
//

import UIKit

class BookmarkView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        // Create the path for the bookmark shape
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX - 20, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + 20, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + 20, y: 40))
        path.addLine(to: CGPoint(x: rect.midX, y: 30))
        path.addLine(to: CGPoint(x: rect.midX - 20, y: 40))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.systemGray2.cgColor
        shapeLayer.fillColor = UIColor.systemGray2.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.frame = rect

        self.layer.addSublayer(shapeLayer)
    }
}

