#if os(iOS)
import SwiftUI

struct CameraImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let onImagePicked: (Data?) -> Void
    
    func makeCoordinator() -> CameraImagePickerCoordinator {
        CameraImagePickerCoordinator(
            onImagePicked: onImagePicked,
            dismiss: dismiss
        )
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
#endif
