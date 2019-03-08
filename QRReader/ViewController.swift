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

    // 카메라가 동영상을 찍는 부분 뷰
    @IBOutlet var videoPreview: UIView!
    
    // QR코드를 받아서 String으로 변환해주어 stringURL을 저장한다.
    var stringURL = String()
    
    enum error: Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            try scanQRCode()
        } catch {
             print("Failed to scan the QR code.")
        }
    }
    
    func captureOutput (_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects : [Any], from connection : AVCaptureConnection!) {
        
        if metadataObjects.count > 0 { // 매개변수로 들어온 데이터가 있으면
            
            let machineReaderbleCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            // metadataObjects[0]을 AVMetadataMachineReadableCodeObject로 타입캐스팅 해준다.
            // Barcode information detected by a metadata capture output.
            // AVMetadataMachineReadableCodeOject는 메타데이터 캡쳐 아웃풋으로 캡쳐된 바코드 정보이다.
            
            
            if machineReaderbleCode.type == AVMetadataObject.ObjectType.qr {
                // 만약 카메라가 읽은 데이터가 qr코드 타입이면 string value로 바꿔 준뒤 stringURL에 넣어준다.
                stringURL = machineReaderbleCode.stringValue!
                performSegue(withIdentifier: "openLink", sender: self )
            }
        }
        
    }
    
    func scanQRCode() throws {
        
        // An object that manages capture activity and coordinates the flow of data from input devices to capture outputs.
        // AVCaptureSession 은 캡쳐를 관리하고, 데이터의 흐름을 인풋디바이스에서 캡쳐 아웃풋까지를 관리하는 객체이다.
        let avCaptureSession = AVCaptureSession()
        
        // QR코드를 제공하는 디바이스의 미디어 타입이 비디오가 아니면 Error
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("There is No Camera.")
            throw error.noCameraAvailable
        }
        
        // 카메라가 제공한 캡쳐 인풋이 없으면 Error
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            print("Failed to init Camera.")
            throw error.videoInputInitFail
        }
        
        // 캡쳐 세션에 의해 생성된 캡쳐 메타데이터 아웃풋
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        // 콜백함수를 관리하기위해 Delegate를 설정해준다.
        // 새로운 메타데이터 객체들이 캡쳐되었을 때, 모든 델리게이트 메소드들이 디스패치 큐에서 실행되어진다
        // 모든 메타데이터들이 시기적절하고 드랍되지 않게 진행되려면 dispatch 큐를 특정해줘야한다.
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // 세션에 캡쳐정보를 인풋으로 넣어주고
        avCaptureSession.addInput(avCaptureInput)
        // 세션에 아웃풋으로 메타데이터 아웃풋을 받아준다.
        avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        // 캡쳐의 메타데이터 아웃풋의 오브젝트 타입은 qr을 대입해준다.
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        avCaptureVideoPreviewLayer.frame = videoPreview.bounds
        
        self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        avCaptureSession.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openLink" {
            let destination = segue.destination as! WebViewController
            destination.url = URL(string: stringURL)
        }
    }


}

