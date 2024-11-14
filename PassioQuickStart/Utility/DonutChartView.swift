//
//  DonutChartView.swift
//  PassioQuickStart
//
//  Created by Pratik on 29/10/24.
//

import UIKit

class DonutChartView: UIView {
    
    var datasource: [ChartDatasource] = []
    
    struct ChartDatasource {
        var color: UIColor
        var percent: Double
    }
    
    private var radius: CGFloat { (bounds.height - lineWidth) / 2 }
    private let baseLayer = CAShapeLayer()
    private var progressLayers: [CALayer] = []
    
    @IBInspectable var lineWidth: CGFloat = 10 {
        didSet {
            self.baseLayer.lineWidth = lineWidth
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        baseLayer.fillColor = UIColor.clear.cgColor
        baseLayer.strokeColor = UIColor.clear.cgColor
        baseLayer.lineCap = .round
        baseLayer.strokeEnd = 1.0
        layer.addSublayer(baseLayer)
        self.backgroundColor = .clear
    }
    
    func updateData(data: [ChartDatasource]) {
        
        progressLayers.forEach { $0.removeFromSuperlayer() }
        let padding = CGFloat(data.filter({$0.percent > 0}).count) * 0.17
        let totalRotationAngle = (CGFloat.pi * 2) - padding
        var startAngle = CGFloat.zero
        
        let total = data.reduce(0, {$0 + $1.percent})
        if total == 0 { return }
        
        for obj in data {
            if obj.percent > 0 {
                let layer = CAShapeLayer()
                let progressAngle = obj.percent / 100 * totalRotationAngle
                
                let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
                let path = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: startAngle,
                                        endAngle: startAngle + progressAngle,
                                        clockwise: true)
                layer.path = path.cgPath
                layer.strokeColor = obj.color.cgColor
                layer.fillColor = UIColor.clear.cgColor
                layer.lineWidth = self.lineWidth
                layer.lineCap = .round
                layer.strokeEnd = 1
                
                self.progressLayers.append(layer)
                self.layer.addSublayer(layer)
                
                startAngle += progressAngle + 0.17
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        baseLayer.frame = bounds
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let basePath = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: .initialAngle,
                                    endAngle: .endAngle(progress: 1),
                                    clockwise: true)
        baseLayer.path = basePath.cgPath
    }
}

private extension CGFloat {
    
    static var initialAngle: CGFloat = -(.pi / 2)
    static func endAngle(progress: CGFloat) -> CGFloat {
        .pi * 2 * progress + .initialAngle
    }
}
