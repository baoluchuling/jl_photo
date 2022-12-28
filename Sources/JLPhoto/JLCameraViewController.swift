//
//  JLCameraViewController.swift
//  JanLi
//
//  Created by admin on 2022/12/1.
//  Copyright © 2022 com.baoluchuling.janli. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

public class JLCameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    public var cancel: (() -> Void)?
    public var complete: (([JLAsset]) -> Void)?
        
    var closeBtn: UIButton?
    var takeBtn: UIButton?
    
    lazy var sessionQueue: DispatchQueue = {
        let queue = DispatchQueue(label: "com.baoluchuling.janli.capture_session")
        return queue
    }()
    
    var sessionRuning: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.isNavigationBarHidden = true
        
        self.previewView = JLCameraCapturePreviewView()
        self.previewView?.backgroundColor = UIColor.clear
        self.previewView?.layer.cornerRadius = 2
        self.previewView?.layer.masksToBounds = true
        self.previewView?.videoPreviewLayer.session = self.avsession
        self.view.addSubview(self.previewView!)
        
        self.previewView?.snp.makeConstraints({ maker in
            maker.edges.equalToSuperview()
        })
        
        self.takeBtn = UIButton()
        self.takeBtn!.backgroundColor = UIColor.clear
        self.takeBtn!.setBackgroundImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        self.takeBtn!.tintColor = UIColor.white
        self.takeBtn!.addTarget(self, action: #selector(take), for: .touchUpInside)
        self.view.addSubview(self.takeBtn!)
        
        self.takeBtn!.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        let s1 = UIView()
        self.view.addSubview(s1)
        
        let s2 = UIView()
        self.view.addSubview(s2)
        
        self.closeBtn = UIButton()
        self.closeBtn!.backgroundColor = UIColor.clear
        self.closeBtn!.setBackgroundImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        self.closeBtn!.tintColor = UIColor.white
        self.closeBtn!.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.view.addSubview(self.closeBtn!)
        
        
        s1.snp.makeConstraints { make in
            make.leading.equalToSuperview()
        }
        
        self.closeBtn!.snp.makeConstraints { make in
            make.centerY.equalTo(self.takeBtn!)
            make.leading.equalTo(s1.snp.trailing)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        s2.snp.makeConstraints { make in
            make.leading.equalTo(self.closeBtn!.snp.trailing)
            make.trailing.equalTo(self.takeBtn!.snp.leading)
            make.width.equalTo(s1)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: nil)

        authority {
            DispatchQueue.main.async {
                self.configBasicDevice()
            }
        }
    }
    
    func authority(_ complete: @escaping () -> Void) -> Void {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            complete()
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { res in
                if (res == true) {
                    complete()
                }
            }
            break
        case .denied, .restricted:
            break
        default:
            break
        }
    }
    
    let avsession: AVCaptureSession = AVCaptureSession()
    var previewView: JLCameraCapturePreviewView?
    var device: AVCaptureDevice?
    let metadataTypes: [AVMetadataObject.ObjectType] = [.ean13, .ean8, .code128]
    
    let photoOutput = AVCapturePhotoOutput()

    func configBasicDevice() {
        self.sessionQueue.async { [self] in
            guard let device = AVCaptureDevice.default(for: .video) else {
                return
            }
            
            guard let deviceInput = try? AVCaptureDeviceInput(device: device) else {
                return
            }
            
            self.device = device
            
            guard self.avsession.canSetSessionPreset(.hd1920x1080) else { return }
            self.avsession.sessionPreset = .hd1920x1080
            self.avsession.beginConfiguration()
        
            guard self.avsession.canAddInput(deviceInput) else { return }
            self.avsession.addInput(deviceInput)
            
            guard self.avsession.canAddOutput(self.photoOutput) else { return }
            self.avsession.sessionPreset = .photo
            self.avsession.addOutput(self.photoOutput)
            
            let connection = self.photoOutput.connection(with: .video)
            connection?.isEnabled = true
                        
            self.avsession.commitConfiguration()
            
            self.avsession.startRunning()
            self.sessionRuning = self.avsession.isRunning
        }
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                self.avsession.stopRunning()
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                self.avsession.stopRunning()
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        self.sessionQueue.async {
            if self.avsession.isRunning {
                self.avsession.stopRunning()
            }
        }
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")

        if error.code == .mediaServicesWereReset {
            self.sessionQueue.async {
                if self.sessionRuning {
                    self.avsession.startRunning()
                }
            }
        }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        self.avsession.stopRunning()
        super.viewDidDisappear(animated)
    }
    
    @objc func take() {
        // 如何暂停session，而不抖动
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc func close(_ refresh: Bool = false) {
        
        self.dismiss(animated: true)
        
        guard self.cancel != nil else {
            return
        }
        self.cancel!()
    }
        
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        self.avsession.stopRunning()
        
        let data = photo.fileDataRepresentation()
        guard self.complete != nil else {
            self.avsession.startRunning()
            return
        }
        
        maybePop()
        
        self.complete!([
            JLAsset(data: data)
        ])
    }
}

class JLCameraCapturePreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoPreviewLayer.frame = self.frame
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
    }
}
