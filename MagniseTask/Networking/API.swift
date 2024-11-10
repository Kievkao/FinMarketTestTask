//
//  Networking.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation
import Combine

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var bodyParameters: [String: Any]? { get }
    var parameters: [String: Any]? { get }
}

protocol APIClient {
    associatedtype EndpointType: APIEndpoint
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error>
}

struct APIConstants {
    static let domain = "platform.fintacharts.com"
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidResponse
    case invalidData
}

enum Endpoint: APIEndpoint {
    case getToken
    case getInstruments
    case getHistoricalData(instrumentId: String, interval: Int, periodicity: String, count: Int)
    
    var baseURL: URL {
        URL(string: "https://\(APIConstants.domain)")!
    }
    
    var provider: String {
        "oanda"
    }
    
    var market: String {
        "forex"
    }
    
    var path: String {
        switch self {
        case .getToken:
            return "/identity/realms/fintatech/protocol/openid-connect/token"
        case .getInstruments:
            return "/api/instruments/v1/instruments"
        case .getHistoricalData:
            return "/api/bars/v1/bars/count-back"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getToken:
            return .post
        case .getInstruments, .getHistoricalData:
            return .get
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getToken:
            return nil
        case .getInstruments, .getHistoricalData:
            guard let token = TokenStorage.getToken() else {
                return nil
            }
            return ["Authorization": "Bearer \(token)"]
        }
    }
    
    var bodyParameters: [String: Any]? {
        switch self {
        case .getToken:
            return [
                "grant_type": "password",
                "client_id": "app-cli",
                "username": "r_test@fintatech.com",
                "password": "kisfiz-vUnvy9-sopnyv"
            ]
        case .getInstruments, .getHistoricalData:
            return nil
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getToken:
            return ["realm": "fintatech"]
        case .getInstruments:
            return ["provider": provider, "kind": market]
        case .getHistoricalData(let instrumentId, let interval, let periodicity, let count):
            return ["instrumentId": instrumentId, "provider": provider, "interval": interval, "periodicity": periodicity, "barsCount": count]
        }
    }
}

final  class URLSessionAPIClient<EndpointType: APIEndpoint>: APIClient {
    func request<T: Decodable>(_ endpoint: EndpointType) -> AnyPublisher<T, Error> {
        var url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        
        if let parameters = endpoint.parameters {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            url = components?.url ?? url
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        endpoint.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        if let bodyParameters = endpoint.bodyParameters {
            let bodyString = bodyParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
