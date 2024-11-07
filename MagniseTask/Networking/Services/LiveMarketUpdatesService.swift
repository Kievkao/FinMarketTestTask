//
//  LiveMarketUpdatesService.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation
import Combine

final class LiveMarketUpdatesService {
    private let baseURL = "wss://platform.fintacharts.com/api/streaming/ws/v1/realtime?token="
    private var webSocketConnection: WebSocketConnection<StreamingRequest>?
    
    @Published var latestOperation: ExchangeOperation?
    
    func subscribe(to instrumentId: String) {
        guard let token = TokenStorage.getToken() else { return }
        let urlString = baseURL.appending(token)
        guard let url = URL(string: urlString) else { return }
        
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
                DispatchQueue.main.async {
                    self.latestOperation = result.last
                }
            }
        } catch {
            print("WebSocket receive error: \(error)")
        }
    }
    
    func unsubscribe() {
        webSocketConnection?.close()
        webSocketConnection = nil
    }
}
