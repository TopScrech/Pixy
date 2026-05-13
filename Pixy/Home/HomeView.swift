import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var vm = PixyVM()
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        @Bindable var vm = vm
        
        ScrollView {
            VStack(alignment: .leading) {
                DropZone()
                
                if vm.hasImage {
                    PreviewCard()
                    ControlsView()
                }
            }
            .frame(maxWidth: 1120)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .navigationTitle("Image to Pixel Art")
        .scrollIndicators(.never)
        .background(HomeViewBackground())
        .task {
            await vm.restorePersistedImageIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ImageImportMenu(title: "Import", icon: "photo.on.rectangle")
            }
            
            if vm.hasImage {
                ToolbarItem(placement: .topBarTrailing) {
                    ExportImageButton()
                }
            }
        }
        .environment(vm)
        .fileImporter(isPresented: $vm.isImportingImage, allowedContentTypes: [.image]) {
            vm.handleImportResult($0)
        }
        .photosPicker(
            isPresented: $vm.isPickingPhoto,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else {
                return
            }
            
            Task {
                vm.handlePhotoPickerData(try? await newItem.loadTransferable(type: Data.self))
                selectedPhotoItem = nil
            }
        }
#if os(iOS)
        .sheet(isPresented: $vm.isTakingPhoto) {
            CameraImagePicker {
                vm.handleCameraData($0)
            }
        }
#endif
        .alert(item: $vm.importError) { error in
            Alert(
                title: Text("Couldn’t import image"),
                message: Text(error.message)
            )
        }
    }
}
