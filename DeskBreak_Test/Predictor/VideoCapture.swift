//
//  VideoCapture.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 19/01/25.
//

import Foundation
import AVFoundation

class VideoCapture: NSObject {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    
    let predictor = Predictor()
    
    override init() {
        super.init()
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        
        frontCamera = availableDevices.first { $0.position == .front }
        backCamera = availableDevices.first { $0.position == .back }
    }
    
    func startCaptureSession(useFrontCamera: Bool = false) {
        guard let selectedCamera = useFrontCamera ? frontCamera : backCamera else {
            print("No camera found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: selectedCamera)
            captureSession.inputs.forEach { captureSession.removeInput($0) } // Remove old inputs
            captureSession.addInput(input)
            captureSession.sessionPreset = .high
            
            if captureSession.outputs.isEmpty {
                captureSession.addOutput(videoOutput)
                videoOutput.alwaysDiscardsLateVideoFrames = true
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            }
            captureSession.startRunning()
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
        }
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferIsValid(sampleBuffer) else {
            print("Invalid sample buffer")
            return
        }
        predictor.estimation(sampleBuffer: sampleBuffer)
    }
}
