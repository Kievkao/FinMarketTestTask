//
//  AssetSelectionView.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct AssetSelectionView: View {
    @ObservedObject var model: AssetSelectorViewModel
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        HStack {
            SheetSelector(
                selectedIndex: $selectedIndex,
                options: model.selectionOptions
            )
            Button("Subscribe") {
                selectedIndex.map { model.subscribe(to: $0) }
            }.disabled(selectedIndex == nil)
        }.padding()
    }
}

#Preview {
    AssetSelectionView(model: AssetSelectorViewModel())
}
