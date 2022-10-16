//
//  CheckboxView.swift
//  Push Notify
//
//  Created by Manh Pham on 13/10/2022.
//

import SwiftUI

struct CheckboxView: View {
    
    let text: String
    @Binding var isChecked: Bool
    let callback: (Bool) -> Void
    
    var body: some View {
        HStack {
            Button {
                isChecked.toggle()
                callback(isChecked)
            } label: {
                Image(systemName: isChecked ? "checkmark.square" : "square")
            }
            Text(text)
        }
    }
}
