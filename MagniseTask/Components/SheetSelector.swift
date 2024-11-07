//
//  SheetSelector.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import SwiftUI

struct SheetSelector: View {
    @State private var isSheetPresented = false
    @Binding var selectedIndex: Int?
    let options: [String]

    var body: some View {
        VStack {
            Button(action: {
                isSheetPresented.toggle()
            }) {
                HStack {
                    Text(selectedIndex.map { options[$0] } ?? "Select an Option")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    Text("Select an Option")
                        .font(.headline)
                        .padding()

                    ScrollView {
                        ForEach(options.indices, id: \.self) { index in
                            Text(options[index])
                                .padding()
                                .onTapGesture {
                                    selectedIndex = index
                                    isSheetPresented = false
                                }
                            Divider()
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}
#Preview {
    SheetSelector(selectedIndex: .constant(1), options: ["Apple", "Banana", "Orange", "Mango", "Pineapple", "Grapes"])
}
