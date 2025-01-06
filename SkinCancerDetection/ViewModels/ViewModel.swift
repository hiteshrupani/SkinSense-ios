//
//  ViewModel.swift
//  SkinCancerDetection
//
//  Created by Hitesh Rupani on 13/10/24.
//

import Foundation

import UIKit
import PhotosUI

import CoreML
import Vision

import CoreData

class ViewModel: ObservableObject {
    @Published var image: UIImage?
    
    @Published var result: String?
    @Published var resultProbability: [String: Double]?
    
    @Published var resultWithProbability: (String, Double)?
    
    func getResultWithProbability(_ response: [String: Double]) -> (String, Double) {
        let maxValue = response.max(by: { $0.value < $1.value })
        let (key, value) = maxValue!
        return (key, value)
    }
    
    // MARK: - CreateML Functions
//    func detect(_ image: UIImage, completion: @escaping (String?) -> Void) {
//        // Loading the MLModel
//        guard let model = try? VNCoreMLModel(for: SCD_BenignMalignant().model) else {
//            print("Error loading model")
//            completion(nil)
//            return
//        }
//        
//        // Converting UIImage to CIImage
//        guard let ciImage = CIImage(image: image) else {
//            print("Error converting image to CIImage")
//            completion(nil)
//            return
//        }
//        
//        // Request to classify the image
//        let request = VNCoreMLRequest(model: model) { request, error in
//            if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
//                print(topResult.identifier)
//                completion(topResult.identifier)
//            } else {
//                print("No results found or error occured: \(String(describing: error))")
//                completion(nil)
//            }
//        }
//        
//        // Handler to process the image
//        let handler = VNImageRequestHandler(ciImage: ciImage)
//        
//        // Performing the request on background thread
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try handler.perform([request])
//            } catch {
//                print("Failed to perform request: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//    }
    
    // MARK: test function to get percentage of result
    func classifyImage(_ image: UIImage, completion: @escaping ([String: Double]?) -> Void) {
        // Load the MLModel
        guard let model = try? VNCoreMLModel(for: SCD_BenignMalignant().model) else {
            print("Error loading model")
            completion(nil)
            return
        }

        // Convert the UIImage to a CIImage
        guard let ciImage = CIImage(image: image) else {
            print("Error converting UIImage to CIImage")
            completion(nil)
            return
        }

        // Create a request for image classification
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation] {
                // Create a dictionary of labels and confidence scores
                var predictions: [String: Double] = [:]
                
                for classification in results {
                    predictions[classification.identifier] = Double(classification.confidence)
                }
                
                // Return the dictionary of predictions
                print(predictions)
                completion(predictions)
            } else {
                print("No results found or error occurred: \(String(describing: error))")
                completion(nil)
            }
        }

        // Create a request handler to process the image
        let handler = VNImageRequestHandler(ciImage: ciImage)

        // Perform the request
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform request: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // MARK: - History Core Data Functions
    let container: NSPersistentContainer
    @Published var savedHistory: [DetectionHistoryEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "HistoryContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("ERROR LOADING HISTORY: \(error)")
            }
        }
        fetchHistory()
    }
    
    func addHistory(date: Date, result: String) {
        let newHistoryItem = DetectionHistoryEntity(context: container.viewContext)
        newHistoryItem.date = date
        newHistoryItem.result = result
        
        saveHistory()
    }
    
    func fetchHistory() {
        let request = NSFetchRequest<DetectionHistoryEntity>(entityName: "DetectionHistoryEntity")
        
        do {
            savedHistory = try container.viewContext.fetch(request)
        } catch {
            print("ERROR FETCHING HISTORY: \(error)")
        }
    }
    
    func deleteHistory(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let entity = savedHistory[index]
        container.viewContext.delete(entity)
        
        saveHistory()
    }
    
    func saveHistory() {
        do {
            try container.viewContext.save()
            fetchHistory()
        } catch {
            print("ERROR SAVING HISTORY: \(error)")
        }
    }
    
}
