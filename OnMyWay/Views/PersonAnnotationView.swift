//
//  PersonAnnotationView.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation
import MapKit

class PersonAnnotationView : MKAnnotationView {
    
    
    static let pinSize = CGSize(width: 60, height: 66)
    //static let pinSize = CGSize(width: 50, height: 57)
    
    //let unselectedTransform = CGAffineTransform(translationX: 0, y: pinSize.height * (1 - 0.45) / 2 ).scaledBy(x: 0.45, y: 0.45)
    
    private let strokW:CGFloat = 1
    
    private var particleEmitter:CAEmitterLayer!
    
    var annotText = ""
    
    private var transportType:TransportType?
    private var arrivalTime:Int?
    
    func initLayout(){
        
        let size = PersonAnnotationView.pinSize
        self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.backgroundColor = UIColor.clear
        self.calloutOffset = CGPoint(x: 0, y: 0)
        self.centerOffset = CGPoint(x: 0, y: -size.height / 2)
        //createParticles(type: .walk, eta: 1)
    }
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        if ctx == nil { return }
        
        //        let rectPadShadow = CGRect(x: rect.origin.x + 1, y: rect.origin.y + 1, width: rect.size.width - 2, height: rect.size.height - 2)
        
        UIGraphicsPushContext(ctx!);
        
        //**** Fill color
        createPath(ctx: ctx!, rect: rect)
        ctx!.setFillColor(UIColor.omwGreen.cgColor)
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 2, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3376498288).cgColor)
        ctx?.fillPath()
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor)
        
                //**** Border color
                createPath(ctx: ctx!, rect: rect)
                ctx?.setLineWidth(strokW)
                ctx?.setStrokeColor(UIColor.omwGreen.cgColor)
                ctx?.strokePath()
        
//        //**** Image
//        ctx!.setFillColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor)
//        let width = self.bounds.width
//        let rPad = width/5
//        #imageLiteral(resourceName: "Lion").draw(in: CGRect(x: rPad, y: rPad, width: width - 2*rPad, height: width - 2*rPad))

        
        //**** text
        ctx!.setFillColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor)
        let width = self.bounds.width
        let rPad = width/5
        let label = UILabel(frame: CGRect(x: rPad, y: rPad, width: width - 2*rPad, height: width - 2*rPad))
        label.text = annotText
        label.font = UIFont.omwFont(size: 24)
        //label.textColor = UIColor.black.withAlphaComponent(0.85)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.adjustsFontSizeToFitWidth = true
        
        label.drawText(in: CGRect(x: rPad, y: rPad, width: width - 2*rPad, height: width - 2*rPad))
        //#imageLiteral(resourceName: "Lion").draw(in: CGRect(x: rPad, y: rPad, width: width - 2*rPad, height: width - 2*rPad))
        
        UIGraphicsPopContext();
    }
    
    private func createPath(ctx:CGContext, rect:CGRect) {
        let bounds = self.bounds
        
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        
        let midBottom = CGPoint(x: rect.midX, y: rect.maxY + strokW / 2)
        
        let width = bounds.size.width
        
        //draw semi circle
        ctx.beginPath()
        let angle = .pi/2.3
        ctx.addArc(center: CGPoint(x: width/2, y: width/2 + strokW / 2),
                   radius: width/2 - strokW / 2,
                   startAngle: CGFloat(angle),
                   endAngle: CGFloat(.pi - angle),
                   clockwise: true)
        
        //draw bottom cone
        ctx.addLine(to: midBottom)
        ctx.addLine(to: CGPoint(x: topRight.x - width / 2 * (1 - CGFloat(cos(angle))),
                                y: topRight.y + width / 2 * (1 + CGFloat(sin(angle)))
        ))
        ctx.closePath()
    }
    
    public func createParticles(type:TransportType, eta:Int) {
        
        if transportType == type, arrivalTime?.roundedTimeString() == eta.roundedTimeString() {
            return
        }
        transportType = type
        arrivalTime = eta
        stopParticles()
        
        particleEmitter = CAEmitterLayer()

        particleEmitter.emitterPosition = CGPoint(x: self.frame.size.width/2, y: 0)

        particleEmitter.emitterShape = kCAEmitterLayerPoint
        //particleEmitter.emitterSize = CGSize(width: self.frame.size.width/2, height: 1)
        
        let omwCell = makeEmitterCell(0, image: #imageLiteral(resourceName: "Omw"))
        
        var image = #imageLiteral(resourceName: "foot")
        switch type {
        case .car:
            image = #imageLiteral(resourceName: "car")
        case .walk:
            image = #imageLiteral(resourceName: "foot")
        case .bike:
            image = #imageLiteral(resourceName: "bike")
        case .transit:
            image = #imageLiteral(resourceName: "train")
        }
        
        let typeCell = makeEmitterCell(0.33, image: image)
        
        let strokeTextAttributes: [NSAttributedStringKey: Any] = [
            .strokeColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            .foregroundColor : UIColor.omwBlue,
            .strokeWidth : -5.0,
            .font : UIFont.omwFont(size: 17, weight: .heavy)
        ]

        let label = UILabel(frame: CGRect.zero)
        let eta = transportType == .bike ? eta/2 : eta
        label.attributedText = NSMutableAttributedString(string: eta.roundedTimeString(), attributes: strokeTextAttributes)
        label.sizeToFit()

        let etaCell = makeEmitterCell(0.66, image: UIImage.imageWithLabel(label: label))

        particleEmitter.emitterCells = [omwCell, typeCell, etaCell]
        particleEmitter.birthRate = 0
        
        particleEmitter.beginTime = CACurrentMediaTime()
        particleEmitter.birthRate = 1
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//            self?.particleEmitter.birthRate = 2
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            particleEmitter.birthRate = 0
//        }

        self.layer.insertSublayer(particleEmitter, at: 0)
    }
    
    public func stopParticles() {
        
        if particleEmitter == nil { return }
        
        particleEmitter.birthRate = 0
        particleEmitter.removeFromSuperlayer()
        particleEmitter = nil
        
        
        
        
    }
    
    private func makeEmitterCell(_ beginTime:Double, image:UIImage?) -> CAEmitterCell {
        
        
        let cell = CAEmitterCell()
        cell.birthRate = 1
        cell.beginTime = beginTime
        cell.lifetime = 1.0
        cell.lifetimeRange = 0.0
        //cell.color = color.cgColor
        cell.velocity = 100
        cell.velocityRange = 5
        cell.emissionLongitude = -CGFloat.pi/2
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 0
        cell.spinRange = 0
        cell.scale = 0.15
        cell.scaleRange = 0
        cell.scaleSpeed = 0.95
        cell.alphaRange = 0
        cell.alphaSpeed = -1
        
        if image != nil {
            cell.contents = image!.cgImage
        }


        return cell
    }
    
    
}





