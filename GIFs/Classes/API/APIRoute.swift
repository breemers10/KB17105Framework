import Foundation

typealias Params = [String: String]

public enum HTTPMethod: String {
    case get = "GET"
}

final class APIRoute {
    private var method: HTTPMethod
    private var path: String
    private var params: Params?

    init(path: String, method: HTTPMethod = .get, params: Params? = nil) {
        self.method = method
        self.path = path
        self.params = params
    }

    func asURLRequest() -> URLRequest {
        let hasBase = path.contains(APIConfig.baseURL)
        let urlString = hasBase ? path : APIConfig.baseURL + path
        let url = urlString.asURL()

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = params?.compactMap {
            URLQueryItem(name: String($0), value: String($1))
        }
        components?.queryItems?.append(URLQueryItem(name: "api_key", value: GIFConfig.apiKey))

        let finishedUrl = components?.string ?? ""
        var urlRequest = URLRequest(url: finishedUrl.asURL())
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 30
        urlRequest.cachePolicy = .reloadIgnoringCacheData

        return urlRequest
    }
}

extension String {
    func asURL() -> URL {
        guard let url = URL(string: self) else {
            fatalError("Unconstructable URL: \(self)")
        }
        return url
    }
}
