//
//  ViewController.swift
//  QRReader
//
//  Created by 정기욱 on 07/03/2019.
//  Copyright © 2019 Kiwook. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate    {

    @IBOutlet var videoPreview: UIView!
    
    var stringURL = String()
    
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            
        } catch {
             print("Failed to scan the QR code.")
        }
    }
    
    func captureOutput (_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects : [Any], from connection : AVCaptureConnection!) {
        
        if metadataObjects.count > 0 { // 매개변수로 들어온 데이터가 있으면
            let machineReaderbleCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            // metadataObjects[0]을 AVMetadataMachineReadableCodeObject로 타입캐스팅 해준다.
            if machineReaderbleCode.type == AVMetadataObject.ObjectType.qr {
                // 만약 카메라가 읽은 데이터가 qr코드 타입이면 string value로 바꿔 준뒤 stringURL에 넣어준다.
                stringURL = machineReaderbleCode.stringValue!
                performSegue(withIdentifier: "openLink", sender: self )
            }
        }
        
    }


}

