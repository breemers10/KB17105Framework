import UIKit

struct ImagesData: Codable {
    var data: [GIFData]
}

struct GIFData: Codable, Hashable {
    var id: String?
    var images: Images?
}

struct Images: Codable, Hashable {
    var original: ImageInfo?
    var downsized: ImageInfo?

    enum CodingKeys: String, CodingKey {
        case original
        case downsized = "fixed_width_small"
    }
}

struct ImageInfo: Codable, Hashable {
    var height: String?
    var width: String?
    var url: String?

    var address: URL {
        return url?.asURL() ?? URL(string: "https://media.giphy.com/media/8L0Pky6C83SzkzU55a/giphy.gif")!
    }

    var aspectRatio: Double {
        let heightDouble = NumberFormatter().number(from: height ?? "0")?.doubleValue ?? 0
        let widthDouble = NumberFormatter().number(from: width ?? "0")?.doubleValue ?? 0
        return heightDouble / widthDouble
    }

    var w: CGFloat {
        return (UIScreen.main.bounds.width/2)
    }

    var h: CGFloat {
        return CGFloat(aspectRatio) * w
    }
}
