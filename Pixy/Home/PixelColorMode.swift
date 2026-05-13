enum PixelColorMode: String, CaseIterable, Identifiable {
    case color, grayscale, blackAndWhite
    
    nonisolated var id: Self {
        self
    }
    
    nonisolated var title: String {
        switch self {
        case .color: "Color"
        case .grayscale: "Grayscale"
        case .blackAndWhite: "Black & White"
        }
    }
    
    nonisolated var fileNameSuffix: String {
        switch self {
        case .color: ""
        case .grayscale: "-grayscale"
        case .blackAndWhite: "-black-white"
        }
    }
}
