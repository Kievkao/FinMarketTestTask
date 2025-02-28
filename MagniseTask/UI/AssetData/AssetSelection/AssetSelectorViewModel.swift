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
    var selectionOptions: [String] { get }
    var selectedInstrument: PassthroughSubject<Instrument, Never> { get }
    
    func subscribe(to index: Int)
    func update(instruments: [Instrument])
}

final class AssetSelectionViewModel: AssetSelectionViewModelProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    let selectedInstrument = PassthroughSubject<Instrument, Never>()
    @Published var instruments = [Instrument]()
    
    var selectionOptions: [String] {
        instruments.map { $0.symbol }
    }

    func subscribe(to index: Int) {
        guard index >= 0, index < instruments.count else { return }
                
        let instrument = instruments[index]
        selectedInstrument.send(instrument)
    }
    
    func update(instruments: [Instrument]) {
        self.instruments = instruments
    }
}

final class MockAssetSelectionViewModel: AssetSelectionViewModelProtocol {
    var selectedInstrument: PassthroughSubject<Instrument, Never> = .init()    
    var instruments: [Instrument] = []
    var selectionOptions: [String] = []
    func subscribe(to index: Int) { }
    func update(instruments: [Instrument]) { }
}
