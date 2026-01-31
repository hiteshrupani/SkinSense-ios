//
//  ContentView.swift
//  SkinCancerDetection
//
//  Created by Hitesh Rupani on 13/10/24.
//

import SwiftUI
import PhotosUI
import UIKit

struct DashboardView: View {
    @ObservedObject var vm: ViewModel
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showActionSheet = false
    @State private var showPhotoPicker = false
    @State private var showCameraPicker = false
    
    @State private var width100 = UIScreen.main.bounds.width
    @State private var width80 = UIScreen.main.bounds.width * 0.8
    
    var body: some View {
        ZStack {
            VStack {
                // MARK: - Header
                Header()
                
                Spacer()
                
                // MARK: - Detect Button
                Button {
                    vm.classifyImage(vm.image!) { response in
                        DispatchQueue.main.async {
                            vm.resultProbability = response
                            let result = vm.getResultWithProbability(vm.resultProbability!)
                            
                            // assigning result to vm
                            vm.resultWithProbability = result
                            
                            // adding result to history
                            vm.addHistory(date: Date(), result: result.0)
                        }
                    }
                    
                } label: {
                    DetectButton()
                }
                .disabled(vm.image == nil)
                .padding()
            }
            
            // MARK: - Upload Image Placeholder
            Button {
                showActionSheet = true
            } label: {
                ZStack {
                    // Check if the image exists
                    if let image = vm.image {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width80, height: width80)
                                .clipShape(RoundedRectangle(cornerRadius: 17))
                                .padding()
                            
                            // MARK: - Result
                            if let result = vm.resultWithProbability {
                                VStack {
                                    ProgressBarView(progress: result.1)
                                    
                                    // Format: The lesion has a 20% chance of being malignant.
                                    Text ("The lesion has a \(String(format: "%.2f", result.1 * 100))% chance of being \(result.0.capitalized).")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(.label))
                                        .multilineTextAlignment(.center)
                                        .padding(.top)
                                }
                            }
                        }
                        .frame(width: width80)
                        
                    } else {
                        // MARK: - Placeholder Image
                        ZStack {
                            Color(.systemGray3)
                                .aspectRatio(1, contentMode: .fill)
                            
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundStyle(.white)
                                .opacity(0.75)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width * 0.3)
                                .padding()
                        }
                        .frame(width: width80, height: width80)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                    }
                }
            }
        }
        .confirmationDialog("Upload an image", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("Photos") { showPhotoPicker = true }
            Button("Camera") { showCameraPicker = true }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photosPickerItem, matching: .images)
        .fullScreenCover(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: .camera) { image in
                vm.image = image
                vm.result = nil
            }
        }
        .accentColor(Color(.label))
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem,
                   let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        // updating view model
                        vm.image = image
                        vm.result = nil
                    }
                }
                photosPickerItem = nil // for next time
            }
        }
    }
}

#Preview {
    DashboardView(vm: ViewModel())
}

struct Header: View {
    var body: some View {
        Text("Detect Skin Cancer")
            .font(.largeTitle)
            .bold()
            .foregroundStyle(Color(.label))
            .padding()
            .padding(.top)
    }
}

struct DetectButton: View {
    var body: some View {
        VStack {
            Text("\(Image(systemName: "magnifyingglass")) Start Detection")
                .font(.title2)
                .fontWeight(.semibold)
            
        }
        .foregroundStyle(Color(.systemBackground))
        .padding()
        .background {
            Capsule()
                .frame(width: UIScreen.main.bounds.width * 0.8)
        }
    }
}

// MARK: - UIImagePickerController Wrapper for Camera
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    var sourceType: UIImagePickerController.SourceType = .camera
    var completion: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
