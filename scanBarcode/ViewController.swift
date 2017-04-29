//
//  ViewController.swift
//  scanBarcode
//
//  Created by Swaroop Kurra on 22/02/17.
//  Copyright © 2017 Swaroop Kurra. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode,
                              AVMetadataObjectTypeInterleaved2of5Code,
                              AVMetadataObjectTypeDataMatrixCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            view.bringSubview(toFront: messageLabel)
            barCodeFrameView = UIView()
            
            if let barCodeFrameView = barCodeFrameView {
                barCodeFrameView.layer.borderColor = UIColor.green.cgColor
                barCodeFrameView.layer.borderWidth = 2
                view.addSubview(barCodeFrameView)
                view.bringSubview(toFront: barCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No barcode is detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
}
