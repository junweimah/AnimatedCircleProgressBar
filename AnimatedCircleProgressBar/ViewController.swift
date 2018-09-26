//
//  ViewController.swift
//  AnimatedCircleProgressBar
//
//  Created by Tandem on 23/05/2018.
//  Copyright © 2018 Tandem. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    var shapeLayer = CAShapeLayer()
    
    var pulsatingLayer: CAShapeLayer! //! so dont have to unwrap later
    
    let urlString = "https://www.hdwallpapers.in/download/for_honor_season_6_rite_of_champions_4k_8k-HD.jpg"
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    //make the status bar visible
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //this is to solve a bug, when the app enter backgorund and come back, there will be no animation
    private func setupNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name:.UIApplicationWillEnterForeground , object: nil)
    }
    
    @objc private func handleEnterForeground(){
        animatePulsatingLayer()
    }
    
    private func createCircleShaperLayer(srokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = srokeColor.cgColor
        layer.lineWidth = 20 //the width of the bar
        layer.fillColor = fillColor.cgColor //amek the middle area have clear color
        layer.lineCap = kCALineCapRound //this to make the bar has rounded corner
        layer.position = view.center
        return layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObservers()
        
        view.backgroundColor  = UIColor.backgroundColor
        
        //start drawing circle
        setupCircleLayers()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        setupPercentageLabel()
    }
    
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    private func setupCircleLayers(){
        pulsatingLayer = createCircleShaperLayer(srokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        //this is the bar behind the progress bar
        //create the track layer, the softer color underneath the bar that it is going to fill
        let trackLayer = createCircleShaperLayer(srokeColor: UIColor.trackStrokeColor, fillColor: UIColor.backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        //this is the red bar
        shapeLayer = createCircleShaperLayer(srokeColor: UIColor.outlineStrokeColor, fillColor: .clear)
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    private func animatePulsatingLayer(){
        let animation = CABasicAnimation(keyPath: "transform.scale") // the animation type you want
        
        animation.toValue = 1.4 //scale 1.4 times
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) //an animation type, ease out
        animation.autoreverses = true //so the pulsing can come back to initial size
        animation.repeatCount = Float.infinity //infinite number of times
        
        pulsatingLayer.add(animation, forKey: "pulsing") //any string here, just to identify
    }
    
    //the require func for URLSessionDownloadDelegate delegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("finish downloading file")
    }
    
    //optional func from the delegate URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        print(totalBytesWritten, totalBytesExpectedToWrite)
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print("percentage : ", percentage)
        
        //this need to be in the main thread because the url session downloading is not on the main thread, so if without DispatchQueue.main, then the UI wont update
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage
        }
        
    }
    
    private func begindDownloadFile(){
        
        //this fix the bar going back and forth
        shapeLayer.strokeEnd = 0
        
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else { return }
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd") //animate the shapeLayer.strokeEnd
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 2
        
        //need these 2 lines to make the bar stopped at the final point, if not it will be removed upon completion
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation,forKey: "customString")
    }
    
    @objc private func handleTap(){
        print("animate here")
        
        begindDownloadFile()
        
//        animateCircle()//custom string for forKey value, not sure where will use it later
        
    }


}

