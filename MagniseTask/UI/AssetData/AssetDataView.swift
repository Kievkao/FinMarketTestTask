//
//  AssetDataView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct AssetDataView<Model, ChartModel, SelectionModel>: View
where SelectionModel: AssetSelectionViewModelProtocol,
      ChartModel: AssetChartModelProtocol,
      Model: AssetDataViewModelProtocol {
    
    @ObservedObject var model: Model
    @ObservedObject var selectionViewModel: SelectionModel
    @ObservedObject var chartModel: ChartModel
    
    @State private var showErrorAlert = false
    @State private var apiError: LocalizedError?

    var body: some View {
        Group {
            if model.instruments.isEmpty {
                ProgressView("Loading...")
                    .onAppear {
                        model.loadData()
                    }
            } else {
                VStack {
                    AssetSelectionView(model: selectionViewModel)
                        .frame(height: 80)
                    AssetDetailsView(marketData: $model.latestMarketData)
                        .frame(height: 100)
                    AssetChartView(model: chartModel)
                        .padding(.vertical)
                }
            }
        }
        .onReceive(model.errorPublisher) { error in
            apiError = error
            showErrorAlert = error != nil
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text(apiError?.failureReason ?? "Error"),
                message: Text(apiError?.localizedDescription ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    AssetDataView(
        model: MockAssetDataViewModel(),
        selectionViewModel: MockAssetSelectionViewModel(),
        chartModel: MockAssetChartModel()
    )
}
