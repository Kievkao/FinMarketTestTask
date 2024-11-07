//
//  AssetDetailItemView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct AssetDetailItemView: View {
    let title: String
    let value: String?
    
    var body: some View {
        VStack {
            Text(title).font(.headline)
            Text(value ?? "").font(.body)
        }        
    }
}

#Preview {
    AssetDetailItemView(title: "Symbol", value: "BTC/USD")
}
