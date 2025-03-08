//
//  Predictor.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 19/01/25.
//

import Foundation
import Vision
import CoreML

protocol PredictorDelegate: AnyObject {
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint])
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double)
}

class Predictor {
    weak var delegate: PredictorDelegate?

    private var posesWindow: [VNHumanBodyPoseObservation] = []
    
    private let model: DeskBreakHighFiveActionClassifier1 // Assuming you have a CoreML model named HandRaiseModel
    
    init() {
        guard let model = try? DeskBreakHighFiveActionClassifier1(configuration: MLModelConfiguration()) else {
            fatalError("Unable to load the ML model.")
        }
        self.model = model
    }

    func estimation(sampleBuffer: CMSampleBuffer) {
        let orientation: CGImagePropertyOrientation = .leftMirrored // Adjusted for front camera
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: orientation, options: [:])

        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            if let error = error {
                print("Error in body pose detection: \(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNHumanBodyPoseObservation], !observations.isEmpty else {
                print("No observations found")
                return
            }
            observations.forEach { self?.processObservation($0) }
            if let result = observations.first {
                self?.storeObservation(result)
                self?.labelActionType()
            }
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform Vision request: \(error.localizedDescription)")
        }
    }

    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            let recognizedPoints = try observation.recognizedPoints(forGroupKey: .all)
            
            let filteredPoints = recognizedPoints.values.filter { $0.confidence > 0.6 }
                .map { CGPoint(x: $0.x, y: 1 - $0.y) } // Invert Y-axis
            
            // Send the filtered points to the delegate
            delegate?.predictor(self, didFindNewRecognizedPoints: filteredPoints)
        } catch {
            print("Error processing observation: \(error.localizedDescription)")
        }
    }

    private func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        posesWindow.append(observation)
        if posesWindow.count > 60 {
            posesWindow.removeFirst() // Keep only the last 60 observations
        }
    }

    private func labelActionType() {
        guard let poseMultiArray = prepareInputWithObservations(posesWindow) else { return }
        
        do {
            let prediction = try model.prediction(poses: poseMultiArray)
            let action = prediction.label // This will be "Hand_Raise" if the form is correct
            let confidence = prediction.labelProbabilities[action] ?? 0.0
            delegate?.predictor(self, didLabelAction: action, with: confidence)
        } catch {
            print("Error in predicting action: \(error.localizedDescription)")
        }
    }

    private func prepareInputWithObservations(_ observations: [VNHumanBodyPoseObservation]) -> MLMultiArray? {
        let requiredFrameCount = 60
        let jointCount = 18
        let axisCount = 3

        var paddedObservations = observations
        if paddedObservations.count < requiredFrameCount {
            if let lastObservation = observations.last {
                paddedObservations.append(contentsOf: Array(repeating: lastObservation, count: requiredFrameCount - paddedObservations.count))
            } else {
                return nil
            }
        } else {
            paddedObservations = Array(paddedObservations.prefix(requiredFrameCount))
        }

        do {
            let multiArray = try MLMultiArray(shape: [NSNumber(value: requiredFrameCount), NSNumber(value: axisCount), NSNumber(value: jointCount)], dataType: .float)
            
            // Populate MLMultiArray with the keypoints of the observations
            for (frameIndex, observation) in paddedObservations.enumerated() {
                if let jointMultiArray = try? observation.keypointsMultiArray() {
                    for jointIndex in 0..<jointMultiArray.count {
                        multiArray[frameIndex * jointMultiArray.count + jointIndex] = jointMultiArray[jointIndex]
                    }
                }
            }
            return multiArray
        } catch {
            print("Failed to create MLMultiArray: \(error.localizedDescription)")
            return nil
        }
    }
}
