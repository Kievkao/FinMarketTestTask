//
//  AssetSelectionViewModel.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 07.11.2024.
//

import Foundation
import Combine
import SwiftUI

protocol AssetSelectionViewModelProtocol: ObservableObject {
    var instruments: [Instrument] { get set }
    var selectedInstrument: Instrument? { get }
    var selectionOptions: [String] { get }
    
    func subscribe(to index: Int)
}

final class AssetSelectionViewModel: AssetSelectionViewModelProtocol {
    private var cancellables = Set<AnyCancellable>()
    private let subscribeHandler: ((Instrument) -> Void)
    
    @Binding var instruments: [Instrument]
    @Published var selectedInstrument: Instrument?
    
    init(instruments: Binding<[Instrument]>, subscribeHandler: @escaping ((Instrument) -> Void)) {
        self._instruments = instruments
        self.subscribeHandler = subscribeHandler
    }
    
    var selectionOptions: [String] {
        instruments.map { $0.symbol }
    }

    func subscribe(to index: Int) {
        guard index >= 0, index < instruments.count else { return }
                
        let instrument = instruments[index]
        selectedInstrument = instrument
        subscribeHandler(instrument)
    }
}

final class MockAssetSelectionViewModel: AssetSelectionViewModelProtocol {
    var instruments: [Instrument] = []
    var selectedInstrument: Instrument?
    var selectionOptions: [String] = []
    func subscribe(to index: Int) { }
}
