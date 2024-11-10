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
    
    var body: some Scene {
        WindowGroup {
            AssetDataView(
                model: mainViewModel,
                selectionViewModel: AssetSelectionViewModel(
                    instruments: $mainViewModel.instruments,
                    subscribeHandler: {
                        mainViewModel.subscribe(to: $0)
                        chartViewModel.loadData(for: $0.id)
                    }),
                chartModel: chartViewModel
            )
        }
    }
}
