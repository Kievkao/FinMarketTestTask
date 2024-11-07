//
//  AssetDataView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct AssetDataView: View {
    @StateObject var model = AssetDataViewModel()
    @StateObject var selectorViewModel = AssetSelectorViewModel()
    @StateObject var chartModel = AssetChartModel()
        
    var body: some View {
        if model.instruments.isEmpty {
            ProgressView("Loading...")
                .onAppear {
                    model.loadData()
                }
        } else {
            VStack {
                AssetSelectionView(model: selectorViewModel)
                    .frame(height: 80)
                AssetDetailsView(marketData: $selectorViewModel.latestMarketData)
                    .frame(height: 100)
                AssetChartView(model: chartModel)
                    .padding(.vertical)
            }
            .onReceive(model.$instruments) { newInstruments in
                selectorViewModel.instruments = newInstruments
            }
            .onChange(of: selectorViewModel.selectedInstrument) {
                chartModel.instrumentId = selectorViewModel.selectedInstrument?.id
            }
        }
    }
}

#Preview {
    AssetDataView(model: AssetDataViewModel(), selectorViewModel: AssetSelectorViewModel())
}
