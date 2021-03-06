import Foundation

struct CacheConfig {
    private static let mbCount = 300
    static let bytesCount = 1024 * 1024

    static var imagesSize: Int {
        return mbCount * bytesCount
    }
}
