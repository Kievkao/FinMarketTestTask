//
//  AssetDataViewModel.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 07.11.2024.
//

import Foundation
import Combine

enum AssetDataError: Error {
    case auth(String)
    case loadInstruments(String)
    case liveData(String)
}

extension AssetDataError: LocalizedError {
    var failureReason: String? {
        switch self {
        case .auth:
            "Authentication error"
        case .loadInstruments:
            "Instruments loading error"
        case .liveData:
            "Live data update error"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .auth(description),
             let .loadInstruments(description),
             let .liveData(description):
            return description
        }
    }
}

protocol AssetDataViewModelProtocol: ObservableObject {
    var latestMarketData: AssetMarketData? { get set }
    var instruments: [Instrument] { get }
    var error: PassthroughSubject<AssetDataError, Never> { get }
    
    func loadData()
}

final class AssetDataViewModel: AssetDataViewModelProtocol {
    private let authService: AuthServiceProtocol
    private let instrumentsService: InstrumentsServiceProtocol
    private let liveDataService: LiveMarketUpdatesServiceProtocol

    private var cancellables = Set<AnyCancellable>()
    private var latestOperationSubscription: AnyCancellable?
        
    @Published var instruments: [Instrument] = []
    @Published var latestMarketData: AssetMarketData?
    
    let error = PassthroughSubject<AssetDataError, Never>()
    
    init(
        authService: AuthServiceProtocol,
        instrumentsService: InstrumentsServiceProtocol,
        liveDataService: LiveMarketUpdatesServiceProtocol
    ) {
        self.authService = authService
        self.instrumentsService = instrumentsService
        self.liveDataService = liveDataService
    }
    
    func loadData() {
        authService.authenticate()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error.send(.auth(error.localizedDescription))
                }
            }, receiveValue: { [weak self] _ in
                self?.loadInstruments()
            })
            .store(in: &cancellables)
    }
    
    func subscribe(to instrument: Instrument) {
        latestMarketData = nil
        latestOperationSubscription?.cancel()
        
        liveDataService.subscribe(to: instrument.id)
        latestOperationSubscription = liveDataService.latestOperationPublisher
            .compactMap { $0 }
            .map { AssetMarketData(from: $0, symbol: instrument.symbol, currencySign: instrument.currency) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] in
                if case .failure(let error) = $0 {
                    self?.error.send(.liveData(error.localizedDescription))
                }
            }, receiveValue: { [weak self] in
                self?.latestMarketData = $0
            })
        
        latestOperationSubscription?.store(in: &cancellables)
    }
}

private extension AssetDataViewModel {
    func loadInstruments() {        
        instrumentsService.getInstruments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] in
                if case .failure(let error) = $0 {
                    self?.error.send(.loadInstruments(error.localizedDescription))
                }
            }, receiveValue: { [weak self] instruments in
                self?.instruments = instruments
            })
            .store(in: &cancellables)
    }
}

final class MockAssetDataViewModel: AssetDataViewModelProtocol {
    @Published var instruments: [Instrument] = []
    var error = PassthroughSubject<AssetDataError, Never>()
    var latestMarketData: AssetMarketData?
    
    func loadData() {}
}
