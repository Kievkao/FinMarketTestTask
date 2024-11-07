//
//  AuthService.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func authenticate() -> AnyPublisher<TokenResponse, Error>
}

struct TokenResponse: Decodable {
    let access_token: String
}

final class AuthService: AuthServiceProtocol {
    let apiClient = URLSessionAPIClient<Endpoint>()
    private var cancellables = Set<AnyCancellable>()
    
    func authenticate() -> AnyPublisher<TokenResponse, Error> {
        apiClient.request(.getToken)
            .handleEvents(receiveOutput: { tokenResponse in
                TokenStorage.storeToken(tokenResponse.access_token)
            })
            .eraseToAnyPublisher()
    }
}
