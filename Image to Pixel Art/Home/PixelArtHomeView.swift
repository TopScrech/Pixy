//
//  PixelArtHomeView.swift
//  Image to Pixel Art
//
//  Created by Sergei Saliukov on 11/03/2026
//

import SwiftUI
import UniformTypeIdentifiers

struct PixelArtHomeView: View {
    @State private var viewModel = PixelArtViewModel()
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    PixelArtHeroView(viewModel: viewModel)
                    PixelArtDropZoneView(viewModel: viewModel)
                    
                    if viewModel.hasImage {
                        PixelArtPreviewCardView(
                            title: "Pixelized",
                            subtitle: viewModel.pixelGridLabel,
                            image: viewModel.pixelizedImage,
                            isLoading: viewModel.isRenderingPixelArt
                        )
                    }
                    
                    PixelArtControlsView(viewModel: viewModel)
                }
                .frame(maxWidth: 1120)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .background {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.95, blue: 0.90),
                            Color(red: 0.93, green: 0.87, blue: 0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Circle()
                        .fill(.orange.opacity(0.18))
                        .frame(width: 320)
                        .blur(radius: 30)
                        .offset(x: -180, y: -260)
                    
                    Circle()
                        .fill(.red.opacity(0.12))
                        .frame(width: 280)
                        .blur(radius: 40)
                        .offset(x: 240, y: 320)
                }
                .ignoresSafeArea()
            }
            .navigationTitle("Image to Pixel Art")
        }
        .fileImporter(isPresented: $viewModel.isImportingImage, allowedContentTypes: [.image]) {
            viewModel.handleImportResult($0)
        }
        .alert(item: $viewModel.importError) { error in
            Alert(
                title: Text("Couldn’t import image"),
                message: Text(error.message)
            )
        }
    }
}
