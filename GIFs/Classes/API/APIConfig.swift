import Foundation

public struct APIConfig {
    static let baseURL = "https://api.giphy.com/v1/gifs"

    struct APIPath {
        static let trending = "/trending"
        static let search = "/search"
    }
}
