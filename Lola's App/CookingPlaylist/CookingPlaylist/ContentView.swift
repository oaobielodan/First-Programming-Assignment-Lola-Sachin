//
//  ContentView.swift
//  CookingPlaylist
//
//  Created by Olufunmilola Obielodan on 9/4/25.
//

import SwiftUI
import SwiftData
import PDFKit
import AuthenticationServices

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var showDocumentPicker = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        VStack {
                            Text(item.recipeURL.lastPathComponent)
                                .font(.headline)
                            Text(item.documentContent)
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        }
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: uploadFile) { // pressing the plus sign will lead you to uploading a new file
                        Label("Add Item", systemImage: "plus")
                    }.sheet(
                        isPresented: self.$showDocumentPicker, content: {DocumentPicker(onFilePick: onFilePick)}
                    )
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func uploadFile() {
        self.showDocumentPicker = true // opens files on phone
    }
    
    private func onFilePick(_ url: URL) {
        print("Picked file: \(url)")
        let documentContent = NSMutableAttributedString() // a mutable string with associated attributes for portions of its text.
        
        if let pdf = PDFDocument(url: url) {
            let pageCount = pdf.pageCount

            for i in 0 ..< pageCount {
                guard let page = pdf.page(at: i) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
            }
        }
        
        let documentContentString = documentContent.string.lowercased()
        let cleanedString = documentContentString.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression) // clean up string so no extra white spaces
        
        // initial explortaion of finding time in document
        if cleanedString.contains("minutes") || cleanedString.contains("mins") {
            print("is present in the sentence.")
        } else {
            print("is not present in the sentence.")
        }
        
        addItem(url, documentContentString) // add new item to storage
        SpotifyAPIController.shared.startAuthSession()
    }

    private func addItem(_ url: URL, _ documentContent: String) {
        withAnimation {
            let newItem = Item(timestamp: Date(), recipeURL: url, documentContent: documentContent)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onFilePick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFilePick: onFilePick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onFilePick: (URL) -> Void
               
        init(onFilePick: @escaping (URL) -> Void) {
            self.onFilePick = onFilePick
        }
               
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            onFilePick(url)
        }
               
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("User cancelled")
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
