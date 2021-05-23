import RxSwift
import RxCocoa
import Kingfisher

protocol PGIFListVM {
    var isLoading: BehaviorRelay<Bool> { get }
    var error: PublishRelay<Error> { get }
    var bag: DisposeBag { get }

    var gifImages: BehaviorRelay<[GIFData]> { get }
    var gifsCount: Int { get }

    var showLabelTrigger: Driver<Bool> { get }
    var loadedAllImages: Driver<Bool> { get }

    var searchCancelButtonTrigger: PublishRelay<Void> { get }
    var searchTextTrigger: PublishRelay<String?> { get }
    var refreshControlTrigger: PublishRelay<String?> { get }
    var loadMoreTrigger: PublishRelay<String?> { get }
}

final class GIFListVM: PGIFListVM {

    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<Error>()
    let bag = DisposeBag()

    let apiFunctions = APIFunctions.shared

    let gifImages = BehaviorRelay<[GIFData]>(value: [])

    private let _showLabelTrigger = PublishRelay<Bool>()
    var showLabelTrigger: Driver<Bool> {
        return _showLabelTrigger.asDriver(onErrorJustReturn: false)
    }

    private let _loadedAllImages = BehaviorRelay<Bool>(value: false)
    var loadedAllImages: Driver<Bool> {
        return _loadedAllImages.asDriver()
    }

    let searchCancelButtonTrigger = PublishRelay<Void>()
    let searchTextTrigger = PublishRelay<String?>()
    let refreshControlTrigger = PublishRelay<String?>()
    let loadMoreTrigger = PublishRelay<String?>()

    private var isRefreshing = false
    private var isSearching = false
    private let diskCacheSize = BehaviorRelay<Int>(value: 0)

    private let limit = 25
    private let onePageSize = 25
    private var currentOffset = 0

    var gifsCount: Int {
        return gifImages.value.count
    }

    init() {
        addHandlers()
        showTrending()
    }

    // MARK: - Handlers -
    private func addHandlers() {
        searchCancelButtonTrigger
            .subscribe(onNext: { [weak self] _ in
                guard self?.isSearching == true else { return }
                self?.currentOffset = 0
                self?.gifImages.accept([])
                self?._loadedAllImages.accept(false)
                self?.showTrending()
            }).disposed(by: bag)

        searchTextTrigger
            .subscribe(onNext: { [weak self] text in
                self?.currentOffset = 0
                self?.gifImages.accept([])
                self?._loadedAllImages.accept(false)
                guard text?.isEmpty == false else {
                    self?.showTrending()
                    return
                }
                ImageDownloader.default.cancelAll()
                self?.searchGif(text)
            }).disposed(by: bag)

        refreshControlTrigger
            .subscribe(onNext: { [weak self] searchBarText in
                self?.currentOffset = 0
                self?.isRefreshing = true
                self?._loadedAllImages.accept(false)
                self?.isSearching == true ? self?.searchGif(searchBarText) : self?.showTrending()
            }).disposed(by: bag)

        loadMoreTrigger
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                ImageDownloader.default.cancelAll()
                self.currentOffset += self.onePageSize
                self.isSearching ? self.searchGif(text) : self.showTrending()
            }).disposed(by: bag)
    }

    // MARK: - API Calls -
    private func showTrending() {
        isSearching = false
        isLoading.accept(true)
        apiFunctions
            .trending(limit: limit, loadCount: currentOffset)
            .observeOn(MainScheduler.asyncInstance)
            .asObservable()
            .materialize()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .error(let error):
                    print(error)
                    self?.error.accept(error)
                case .next(var images):
                    images.data.removeAll { (a) -> Bool in
                        return a.images?.downsized?.url == nil
                    }
                    print(images)
                    self?.addImages(images)
                case .completed:
                    self?.isLoading.accept(false)
                }
            }).disposed(by: bag)
    }

    private func searchGif(_ text: String?) {
        guard let text = text else { return }
        isSearching = true
        isLoading.accept(true)
        apiFunctions
            .search(with: text, limit: limit, loadCount: currentOffset)
            .observeOn(MainScheduler.asyncInstance)
            .asObservable()
            .materialize()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .error(let error):
                    self?.error.accept(error)
                case .next(var images):
                    if images.data.isEmpty { self?._showLabelTrigger.accept(true) }
                    images.data.removeAll { (a) -> Bool in
                        return a.images?.downsized?.url == nil
                    }
                    self?.addImages(images)
                case .completed:
                    self?.isLoading.accept(false)
                }
            }).disposed(by: bag)
    }

    private func addImages(_ images: ImagesData) {
        _showLabelTrigger.accept(images.data.isEmpty)
        var allImages = gifImages.value

        if isRefreshing {
            isRefreshing = false
            guard let firstImage = images.data.first else { return }
            if !allImages.contains(firstImage) {
                gifImages.accept(images.data)
            }
            return
        }

        guard !Set(images.data).isSubset(of: Set(allImages)) else {
            _loadedAllImages.accept(true)
            return
        }
        _loadedAllImages.accept(false)

        allImages.append(contentsOf: images.data)
        gifImages.accept(allImages)
    }
}
