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

final class AuthService: AuthServiceProtocol {
    let apiClient = URLSessionAPIClient<Endpoint>()
    
    func authenticate() -> AnyPublisher<TokenResponse, Error> {
        apiClient.request(.getToken)
            .handleEvents(receiveOutput: { tokenResponse in
                TokenStorage.storeToken(tokenResponse.access_token)
            })
            .eraseToAnyPublisher()
    }
}
