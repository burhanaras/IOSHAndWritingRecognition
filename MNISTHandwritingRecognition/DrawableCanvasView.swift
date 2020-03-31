//
//  DrawableCanvasView.swift
//  MNISTHandwritingRecognition
//
//  Created by BURHAN ARAS on 8.01.2020.
//  Copyright © 2020 Brian Advent. All rights reserved.
//

import Foundation
import UIKit


protocol CanvasDelegate{
  func onCanvasEditFinished()
}

struct Line {
    let strokeWidth: Float
    let color: UIColor
    var points: [CGPoint]
}

class DrawableCanvasView: UIView{
  
  private var canvasDelegate: CanvasDelegate!
  fileprivate var strokeColor = UIColor.white
     fileprivate var strokeWidth = 10.0
     
     func setStrokeWidth(width: Float) {
         self.strokeWidth = Double(CGFloat(width))
     }
     
     func setStrokeColor(color: UIColor) {
         self.strokeColor = color
     }
     
     func undo() {
         _ = lines.popLast()
         setNeedsDisplay()
     }
     
     func clearCanvas() {
         lines.removeAll()
         setNeedsDisplay()
     }
     
     var lines = [Line]()
     
  override func layoutSubviews() {
    self.clipsToBounds = false
    self.isMultipleTouchEnabled = false
  }
     override func draw(_ rect: CGRect) {
         super.draw(rect)
         
         guard let context = UIGraphicsGetCurrentContext() else { return }
         
         lines.forEach { (line) in
             context.setStrokeColor(line.color.cgColor)
             context.setLineWidth(CGFloat(line.strokeWidth))
             context.setLineCap(.butt)
             for (i, p) in line.points.enumerated() {
                 if i == 0 {
                     context.move(to: p)
                 } else {
                     context.addLine(to: p)
                 }
             }
             
             context.strokePath()
         }
         
         context.strokePath()
         
     }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         lines.append(Line.init(strokeWidth: Float(strokeWidth), color: strokeColor, points: []))
     }
     
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let point = touches.first?.location(in: self) else { return }

         guard var lastLine = lines.popLast() else { return }
         lastLine.points.append(point)
         lines.append(lastLine)
      
      print("Lines count: \(lines.count) - Point: \(point)")
         
         setNeedsDisplay()
     }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    perform(#selector(onCanvasEditFinished), with: nil, afterDelay: 1)
  }
  
  @objc func onCanvasEditFinished(){
    canvasDelegate?.onCanvasEditFinished()
  }
  
  func setDelegate(delegate: CanvasDelegate){
    self.canvasDelegate = delegate
  }
  
}
