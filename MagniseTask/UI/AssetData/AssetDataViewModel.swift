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
            "Authenication error"
        case .loadInstruments:
            "Instruments loading error"
        case .liveData:
            "Live data update error"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .auth(let description):
            description
        case .loadInstruments(let description):
            description
        case .liveData(let description):
            description
        }
    }
}

protocol AssetDataViewModelProtocol: ObservableObject {
    var latestMarketData: AssetMarketData? { get set }
    
    var instrumentsPublisher: Published<[Instrument]>.Publisher { get }
    var instruments: [Instrument] { get }
    
    var errorPublisher: Published<AssetDataError?>.Publisher { get }
    
    func loadData()
}

final class AssetDataViewModel: AssetDataViewModelProtocol {
    private var cancellables = Set<AnyCancellable>()
    private var latestOperationSubscription: AnyCancellable?
    
    private let authService: AuthServiceProtocol
    private let instrumentsService: InstrumentsService
    private let liveDataService: LiveMarketUpdatesServiceProtocol
        
    @Published var instruments: [Instrument] = []
    var instrumentsPublisher: Published<[Instrument]>.Publisher { $instruments }
    
    @Published var latestMarketData: AssetMarketData?
    
    @Published var apiError: AssetDataError?
    var errorPublisher: Published<AssetDataError?>.Publisher { $apiError }
    
    init(
        authService: AuthServiceProtocol,
        instrumentsService: InstrumentsService,
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
                    self?.apiError = .auth(error.localizedDescription)
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
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.apiError = .liveData(error.localizedDescription)
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
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.apiError = .loadInstruments(error.localizedDescription)
                }
            }, receiveValue: { [weak self] instruments in
                self?.instruments = instruments
            })
            .store(in: &cancellables)
    }
}

final class MockAssetDataViewModel: AssetDataViewModelProtocol {
    @Published var instruments: [Instrument] = []
    var instrumentsPublisher: Published<[Instrument]>.Publisher { $instruments }
    
    @Published var apiError: AssetDataError?
    var errorPublisher: Published<AssetDataError?>.Publisher { $apiError }
    var latestMarketData: AssetMarketData?
    
    func loadData() {}
}
