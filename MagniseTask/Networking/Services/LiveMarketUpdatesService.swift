//
//  LiveMarketUpdatesService.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation
import Combine

protocol LiveMarketUpdatesServiceProtocol {
    func subscribe(to instrumentId: String)
    
    var latestOperationPublisher: Published<ExchangeOperation?>.Publisher { get }
    var latestOperation: ExchangeOperation? { get }
}

final class LiveMarketUpdatesService: LiveMarketUpdatesServiceProtocol {
    private let baseURL = URL(string: "wss://\(APIConstants.domain)/api/streaming/ws/v1/realtime")!
    private var webSocketConnection: WebSocketConnection<StreamingRequest>?
    
    var latestOperationPublisher: Published<ExchangeOperation?>.Publisher { $latestOperation }
    @Published var latestOperation: ExchangeOperation?
    
    func subscribe(to instrumentId: String) {
        guard let token = TokenStorage.getToken() else { return }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: "token", value: token)]
        guard let url = urlComponents.url else { return }
        
        unsubscribe()
        
        let webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketConnection = WebSocketConnection(webSocketTask: webSocketTask)
        
        let request = StreamingRequest(instrumentId: instrumentId)
        
        Task {
            do {
                try await webSocketConnection?.send(request)
                print("Subscribed to instrument with ID \(instrumentId)")
                await receiveUpdates()
            } catch {
                print("Failed to subscribe: \(error)")
            }
        }
    }
    
    private func receiveUpdates() async {
        guard let connection = webSocketConnection else { return }
            
        do {
            for try await result in connection.receive(type: ExchangeResponse.self) {
                await MainActor.run {
                    self.latestOperation = result.last
                }
            }
        } catch {
            print("WebSocket receive error: \(error)")
        }
    }
    
    func unsubscribe() {
        latestOperation = nil
        webSocketConnection?.close()
        webSocketConnection = nil
    }
}
