//
//  AssetDetailsView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct AssetDetailsView: View {
    @Binding var marketData: AssetMarketData?
    
    var body: some View {
        HStack {
            Spacer(minLength: 12)
            AssetDetailItemView(title: "Symbol", value: marketData?.symbol)
            Spacer()
            AssetDetailItemView(title: "Price", value: marketData?.priceString)
            Spacer()
            AssetDetailItemView(title: "Time", value: marketData?.time)
            Spacer(minLength: 12)
        }
    }
}

#Preview {
    return AssetDetailsView(marketData: .constant(AssetMarketData.mock()))
}
