//
//  AssetSelectorViewModel.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 07.11.2024.
//

import Foundation
import Combine
import SwiftUI

final class AssetSelectorViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let liveDataService = LiveMarketUpdatesService()
    
    @Published var instruments: [Instrument] = []
    @Published var selectedInstrument: Instrument?    
    @Published var latestMarketData: AssetMarketData?
    
    var selectionOptions: [String] {
        instruments.map { $0.symbol }
    }
        
    func subscribe(to index: Int) {
        guard index >= 0, index < instruments.count else { return }
                
        let instrument = instruments[index]
        self.selectedInstrument = instrument
        
        liveDataService.subscribe(to: instrument.id)
        liveDataService.$latestOperation
            .compactMap { $0 }
            .map { AssetMarketData(from: $0, symbol: instrument.symbol, currencySign: instrument.currency) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestMarketData)
    }
}
