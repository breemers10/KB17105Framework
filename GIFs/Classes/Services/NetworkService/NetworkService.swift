import RxSwift
import RxCocoa
import Reachability

final class NetworkService {
    private let bag = DisposeBag()
    private let reachability = try? Reachability()

    static let shared = NetworkService()

    let reachable = BehaviorRelay<Bool>(value: true)
    let didBecomeReachable = PublishRelay<Void>()

    init() {
        addHandlers()
    }

    private func addHandlers() {
        reachable.distinctUntilChanged()
            .compactMap { $0 ? () : nil }
            .bind(to: didBecomeReachable)
            .disposed(by: bag)

        reachable.accept(reachability?.connection != .unavailable)

        let changeCallback: (Reachability) -> Void = { [weak self] r in
            let hasConnection = r.connection != .unavailable
            self?.reachable.accept(hasConnection)
        }

        reachability?.whenReachable = changeCallback
        reachability?.whenUnreachable = changeCallback

        do {
            try reachability?.startNotifier()
        } catch { print("Unable to start notifier") }
    }
}
