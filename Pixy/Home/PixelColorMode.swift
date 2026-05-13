enum PixelColorMode: String, CaseIterable, Identifiable {
    case color, grayscale, blackAndWhite
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .color: "Color"
        case .grayscale: "Grayscale"
        case .blackAndWhite: "Black & White"
        }
    }
    
    var fileNameSuffix: String {
        switch self {
        case .color: ""
        case .grayscale: "-grayscale"
        case .blackAndWhite: "-black-white"
        }
    }
}
