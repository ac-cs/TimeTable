//
//  ViewController.swift
//  TimeTable
//
//  Created by Mason on 2015-11-09.
//  Copyright © 2015 Mason. All rights reserved.
//

import UIKit
import AVFoundation
let isInDevMode = true

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var session         : AVCaptureSession!
    var previewLayer    : AVCaptureVideoPreviewLayer!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarNext: UIBarButtonItem!
    @IBOutlet weak var barcodeLabel: UILabel!
    var barCode :String = ""

    @IBAction func NextPress(sender: UIBarButtonItem) {
    }

    @IBAction func rescanButtonPress(sender: UIButton) {
        navBarNext.enabled = false
        startCapture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if(barCode == "" || barCode == "rescan") {
            if let _ = appDelegate.getBarcode() {
                nextPage()
            } else {
                navBarNext.enabled = false
                startCapture()
            }
        } else {
            nextPage()
        }
    }

    func nextPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ViewControllerTimetable") as! ViewControllerTableDetail
        self.presentViewController(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
      BARCODE STUFF
    */
    func startCapture() {
        // For the sake of discussion this is the camera
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        session = AVCaptureSession()
        
        let input : AVCaptureDeviceInput?
        do {
            try input = AVCaptureDeviceInput(device: device)
        } catch {
            input = nil
            barcodeLabel.text = "Error initializing camera"
            navBarNext.enabled = isInDevMode
        }
        // If our input is not nil then add it to the session, otherwise we’re kind of done!
        if input != nil {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session) as AVCaptureVideoPreviewLayer
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        view.bringSubviewToFront(navBar)
        session.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var detectionString : String?
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeAztecCode
        ]
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            for barcodeType in barCodeTypes {
                if metadata.type == barcodeType {
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.session.stopRunning()
                    break
                }
            }
        }
        if let scannedBarcode = detectionString {
            barCode = scannedBarcode
            printSavedBarcode()
            [previewLayer.removeFromSuperlayer()]
            previewLayer = nil
            session = nil
            navBarNext.enabled = true
        }
    }
    
    func printSavedBarcode() {
        print(barCode)
        barcodeLabel.text = "Your barcode: \(barCode)"
        appDelegate.setBarcode(barCode)
    }
}

