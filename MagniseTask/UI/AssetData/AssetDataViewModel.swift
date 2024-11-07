//
//  AssetDataViewModel.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 07.11.2024.
//

import Foundation
import Combine

final class AssetDataViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    let authService = AuthService()
    let apiService = InstrumentsService()
    
    @Published var instruments: [Instrument] = []
    
    func loadData() {
        authService.authenticate()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Authentication failed: \(error)")
                }
            }, receiveValue: { [weak self] _ in
                self?.loadInstruments()
            })
            .store(in: &cancellables)
    }
}

private extension AssetDataViewModel {
    func loadInstruments() {        
        apiService.getInstruments()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] instruments in
                self?.instruments = instruments
            }
            .store(in: &cancellables)
    }
}
