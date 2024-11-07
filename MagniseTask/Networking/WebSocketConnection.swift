//
//  WebSocketConnection.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation

public enum WebSocketConnectionError: Error {
    case connectionError
    case transportError
    case encodingError
    case decodingError
    case disconnected
    case closed
}

public final class WebSocketConnection<Outgoing: Encodable & Sendable>: NSObject, Sendable {
    private let webSocketTask: URLSessionWebSocketTask
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    internal init(
        webSocketTask: URLSessionWebSocketTask,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.webSocketTask = webSocketTask
        self.encoder = encoder
        self.decoder = decoder
        super.init()
        webSocketTask.resume()
    }

    deinit {
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }

    private func receiveSingleMessage<Incoming>(type: Incoming.Type) async -> Incoming? where Incoming: Decodable & Sendable {
        switch try? await webSocketTask.receive() {
            case let .data(messageData):
                return try? decoder.decode(Incoming.self, from: messageData)
                
            case let .string(text):
                guard let messageData = text.data(using: .utf8) else { return nil }
                return try? decoder.decode(Incoming.self, from: messageData)
                
            case .none:
                return nil
                
            @unknown default:
                assertionFailure("Unknown message type")
                webSocketTask.cancel(with: .unsupportedData, reason: nil)
                return nil
        }
    }
}

extension WebSocketConnection {
    func send(_ message: Outgoing) async throws {
        guard let messageData = try? encoder.encode(message) else {
            throw WebSocketConnectionError.encodingError
        }

        do {
            try await webSocketTask.send(.data(messageData))
        } catch {
            throw mapError(from: webSocketTask.closeCode)
        }
    }

    private func mapError(from closeCode: URLSessionWebSocketTask.CloseCode) -> WebSocketConnectionError {
        switch closeCode {
            case .invalid:
                return .connectionError
            case .goingAway:
                return .disconnected
            case .normalClosure:
                return .closed
            default:
                return .transportError
        }
    }

    func receive<Incoming>(type: Incoming.Type) -> AsyncThrowingStream<Incoming, Error> where Incoming: Decodable & Sendable {
        AsyncThrowingStream { continuation in
            Task { [weak self] in
                while let self = self, !Task.isCancelled {
                    do {
                        if let message = await self.receiveSingleMessage(type: type) {
                            continuation.yield(message)
                        } else {
                            // Add a short delay to prevent busy looping
                            try await Task.sleep(nanoseconds: 100_000_000) // 100 ms
                        }
                    } catch {
                        // Handle and propagate the error
                        continuation.finish(throwing: error)
                        break
                    }
                }
            }
        }
    }

    func close() {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
    }
}
