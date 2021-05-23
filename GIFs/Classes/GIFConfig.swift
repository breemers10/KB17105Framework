import Kingfisher

class GIFConfig {
    static var apiKey: String?
}

public class GIFFrame {
    public init (apiKey: String) {
        ImageCache.default.memoryStorage.config.totalCostLimit = CacheConfig.imagesSize
        GIFConfig.apiKey = apiKey
    }

    public var onCellSelect: ((String?) -> Void)?
    public var onSearchBarTouch: (() -> Void)?

    public func controller() -> UINavigationController {
        let controller = GIFListVC()
        let gifListVM = GIFListVM()
        controller.viewModel = gifListVM
        controller.onCellSelect = { [weak self] value in
            self?.onCellSelect?(value)
        }
        controller.onSearchBarTouch = { [weak self] in
            self?.onSearchBarTouch?()
        }
        return UINavigationController(rootViewController: controller)
    }
}
