//
//  MagniseTaskApp.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

@main
struct MagniseTaskApp: App {
    @StateObject private var mainViewModel = AssetDataViewModel(
        authService: AuthService(),
        instrumentsService: InstrumentsService(),
        liveDataService: LiveMarketUpdatesService()
    )
    @StateObject private var chartViewModel = AssetChartModel(chartService: ChartDataService())
    @StateObject private var selectionViewModel = AssetSelectionViewModel()
    
    var body: some Scene {
        WindowGroup {
            AssetDataView(
                model: mainViewModel,
                selectionViewModel: selectionViewModel,
                chartModel: chartViewModel
            )
            .onReceive(selectionViewModel.selectedInstrument) { instrument in
                mainViewModel.subscribe(to: instrument)
                chartViewModel.loadData(for: instrument.id)
            }
            .onChange(of: mainViewModel.instruments) { old, new in
                selectionViewModel.update(instruments: new)
            }
        }
    }
}
