//
//  SelectFileView.swift
//  Push Notify
//
//  Created by Manh Pham on 16/10/2022.
//

import SwiftUI

struct SelectFileView: View {
    
    let label: String
    let fileType: String
    @Binding var file: URL?
    
    var body: some View {
        HStack {
            Text(file?.lastPathComponent ?? "Filename")
            Button {
                let panel = NSOpenPanel()
                panel.allowedFileTypes = [fileType]
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                panel.canCreateDirectories = false
                panel.title = label

                if panel.runModal() == .OK,
                    let url = panel.url {
                    self.file = url
                }
            } label: {
                Text(label)
            }
        }
    }
}
