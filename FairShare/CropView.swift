//
//  CropView.swift
//  FairShare
//
//  Created by Sankritya Thakur on 5/17/24.
//

import SwiftUI
import CropViewController

struct CropView: UIViewControllerRepresentable {
    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: CropView

        init(_ parent: CropView) {
            self.parent = parent
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            cropViewController.dismiss(animated: true) {
                self.parent.onCrop(image)
            }
        }

        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }

    var image: UIImage
    var onCrop: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) { }
}
