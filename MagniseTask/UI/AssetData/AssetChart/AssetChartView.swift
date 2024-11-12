//
//  AssetChartView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI
import Charts

struct AssetChartView<Model>: View where Model: AssetChartModelProtocol {
    @ObservedObject var model: Model
    
    var body: some View {
        Chart(model.chartItems) { item in
            createLineMark(for: item)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                AxisValueLabel(format: .dateTime.day(), centered: true)
            }
        }
        .chartYScale(domain: model.minValue...model.maxValue)
        .padding()
    }
}

private extension AssetChartView {
    
    func createLineMark(for item: ChartDataItem) -> some ChartContent {
        LineMark(
            x: .value("Day", item.date, unit: .day),
            y: .value("Price", item.price)
        )
        .symbol(.circle)
        .interpolationMethod(.catmullRom)
    }    
}

#Preview {
    AssetChartView(model: MockAssetChartModel())
}
