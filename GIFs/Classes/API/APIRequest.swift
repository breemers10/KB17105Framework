import RxCocoa
import RxSwift

final class APIRequest {

    static let session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default)
    }()

    let route: APIRoute
    let decoder: JSONDecoder

    init(route: APIRoute, decoder: JSONDecoder = JSONDecoder()) {
        self.route = route
        self.decoder = decoder
    }

    func request<T: Decodable>() -> Observable<T> {
        let route = self.route
        let decoder = self.decoder

        return Single<T>.create { single in
            let task = type(of: self).session.dataTask(with: route.asURLRequest()) { (data, _, error) in
                do {
                    let model: T = try decoder.decode(T.self, from: data ?? Data())
                    single(.success(model))
                } catch let error {
                    single(.error(error))
                    return
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
        .asObservable()
        .retryWhen { _ -> Observable<Void> in NetworkService.shared.didBecomeReachable.asObservable() }
    }
}
