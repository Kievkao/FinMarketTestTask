//
//  AssetChartView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI
import Charts

struct AssetChartView: View {    
    @ObservedObject var model: AssetChartModel
    
    var body: some View {
        Chart(model.chartItems) {
            LineMark(
                x: .value("Day", $0.date, unit: .day),
                y: .value("Price", $0.price)
            )
            .symbol(.circle)
            .interpolationMethod(.catmullRom)          
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
//
//#Preview {
//    AssetChartView(model: AssertChartModel(instrumentId: .constant(nil)))
//}
