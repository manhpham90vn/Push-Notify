//
//  TextFieldView.swift
//  Push Notify
//
//  Created by Manh Pham on 16/10/2022.
//

import SwiftUI

struct TextFieldView: View {
    
    let label: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(label)
            TextField(label, text: $text)
        }
    }
}
