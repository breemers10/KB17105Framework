import RxCocoa
import RxSwift
import Reachability

public class GIFListVC: UIViewController {
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private var collectionView: UICollectionView!
    private let noResultsLabel = UILabel()

    var onCellSelect: ((String) -> Void)?
    var onSearchBarTouch: (() -> Void)?

    var viewModel: PGIFListVM!
    private let bag = DisposeBag()

    private let cellId = "cellID"

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureNavBar()
        configureSearchBar()
        setupCollectionViewLayout()
        configureCollectionView()

        addCollectionViewHandlers()
        addSearchBarHandlers()
        addHandlers()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let layout: BaseLayout = PinterestLayout()
    private func setupViews() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewLayout())
        collectionView.register(GIFCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(collectionView)
        view.addSubview(noResultsLabel)
        
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        noResultsLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).constant = 16
        noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).constant = 16
    }

    // MARK: - Handlers -
    private func addCollectionViewHandlers() {
        viewModel.gifImages
            .asDriver()
            .drive(collectionView.rx.items(cellIdentifier: "cellID",
                                           cellType: GIFCell.self)) { _, data, cell in
                cell.configure(url: data.images.downsized.address)
            }.disposed(by: bag)

        collectionView.rx.itemSelected
            .do(onNext: { [weak self] _ in self?.searchController.searchBar.endEditing(true) })
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.onCellSelect?(self.viewModel.gifImages.value[indexPath.row].images.original.url)
            })
            .disposed(by: bag)

        // MARK: Pagination
        let canLoadMore = PublishRelay<(Int, Int)>()
        collectionView.rx.willDisplayCell
            .withLatestFrom(Observable.combineLatest(viewModel.isLoading,
                                                     viewModel.loadedAllImages.asObservable())) { ($0, $1) }
            .filter { !$1.0 && !$1.1 }  // isLoading is false & loadedAllImages is false -> then pass
            .map { $0.0.1.row }         // take collection view row
            .compactMap { [weak self] row in (self?.viewModel.gifsCount ?? 0, row) }
            .bind(to: canLoadMore)
            .disposed(by: bag)

        canLoadMore
            .filter { $0-1 == $1 }
            .map { [weak self] _ in self?.searchController.searchBar.text }
            .bind(to: viewModel.loadMoreTrigger)
            .disposed(by: bag)
    }

    private func addSearchBarHandlers() {
        searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchTextTrigger)
            .disposed(by: bag)

        searchController.searchBar.rx.cancelButtonClicked
            .bind(to: viewModel.searchCancelButtonTrigger)
            .disposed(by: bag)

        searchController.searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [weak self] in
                self?.onSearchBarTouch?()
            }).disposed(by: bag)
    }

    private func addHandlers() {
        viewModel.showLabelTrigger
            .map { !$0 }
            .drive(noResultsLabel.rx.isHidden)
            .disposed(by: bag)

        refreshControl.rx.controlEvent(.valueChanged)
            .withLatestFrom(searchController.searchBar.rx.text)
            .bind(to: viewModel.refreshControlTrigger)
            .disposed(by: bag)

        viewModel.isLoading
            .asDriver()
            .compactMap { !$0 ? false : nil }
            .delay(.milliseconds(500))
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: bag)

        viewModel.error
            .subscribe(onNext: { [weak self] in self?.showError($0) })
            .disposed(by: bag)

        NetworkService.shared
            .didBecomeReachable
            .map { false }
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: bag)
    }

    // MARK: - UI -
    private func configureNavBar() {
        title = ""
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let navBar = navigationController?.navigationBar
        navBar?.prefersLargeTitles = false
        navBar?.isTranslucent = false
        navBar?.tintColor = .white
    }

    private func configureSearchBar() {
        definesPresentationContext = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "searchbar_text".localized()
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.sizeToFit()
    }

    private func configureCollectionView() {
        collectionView.refreshControl = refreshControl
    }

    private func setupCollectionViewLayout() {
        layout.delegate = self
        layout.cellsPadding = ItemsPadding(horizontal: 1, vertical: 1)
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }
}

// MARK: - Pinterest layout delegate -
extension GIFListVC: LayoutDelegate {
    public func cellSize(indexPath: IndexPath) -> CGSize {
        let image = viewModel.gifImages.value[indexPath.row]
        return CGSize(width: image.images.downsized.w, height: image.images.downsized.h)
    }
}
