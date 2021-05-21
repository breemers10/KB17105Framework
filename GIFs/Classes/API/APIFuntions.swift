import RxSwift

protocol PAPIFunctions {

    func trending(limit: Int, loadCount: Int) -> Observable<ImagesData>
    func search(with text: String, limit: Int, loadCount: Int) -> Observable<ImagesData>
}

final class APIFunctions: PAPIFunctions {

    static let shared = APIFunctions()

    func trending(limit: Int, loadCount: Int) -> Observable<ImagesData> {
        let path = APIConfig.APIPath.trending
        let params: Params = ["limit": String(limit), "offset": String(loadCount)]
        let route = APIRoute(path: path, params: params)
        return APIRequest(route: route).request()
    }

    func search(with text: String, limit: Int, loadCount: Int) -> Observable<ImagesData> {
        let path = APIConfig.APIPath.search
        let params: Params = ["limit": String(limit), "offset": String(loadCount), "q": text]
        let route = APIRoute(path: path, params: params)
        return APIRequest(route: route).request()
    }
}
