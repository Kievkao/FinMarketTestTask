//
//  AssetDetailsView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct AssetDetailsView: View {
    private let spacerMinLength: CGFloat = 12
    
    @Binding var marketData: AssetMarketData?
    
    var body: some View {
        HStack {
            Spacer(minLength: spacerMinLength)
            AssetDetailItemView(title: "Symbol", value: marketData?.symbol)
            Spacer()
            AssetDetailItemView(title: "Price", value: marketData?.priceString)
            Spacer()
            AssetDetailItemView(title: "Time", value: marketData?.time)
            Spacer(minLength: spacerMinLength)
        }
    }
}

#Preview {
    return AssetDetailsView(marketData: .constant(AssetMarketData.mock()))
}
