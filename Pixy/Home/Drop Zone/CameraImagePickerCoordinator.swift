#if os(iOS)
import SwiftUI

final class CameraImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private let onImagePicked: (Data?) -> Void
    private let dismiss: DismissAction
    
    init(onImagePicked: @escaping (Data?) -> Void, dismiss: DismissAction) {
        self.onImagePicked = onImagePicked
        self.dismiss = dismiss
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let image = info[.originalImage] as? UIImage
        onImagePicked(image?.jpegData(compressionQuality: 1))
        dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onImagePicked(nil)
        dismiss()
    }
}
#endif
