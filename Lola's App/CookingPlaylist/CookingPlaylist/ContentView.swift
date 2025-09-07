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
                        Text(item.recipeName)
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
        self.showDocumentPicker = true // opens files on device
    }
    
    private func onFilePick(_ url: URL) {
        let documentName = url.lastPathComponent
        var documentTitle = "n/a"
        let documentContent = NSMutableAttributedString() // a mutable string with associated attributes for portions of its text.
        
        // gets all the text from the file
        if let pdf = PDFDocument(url: url) {
            documentTitle = pdf.documentAttributes?[PDFDocumentAttribute.titleAttribute] as! String
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
        
        addItem(documentName, url, documentTitle, documentContentString) // add new item to storage
        SpotifyAPIController.shared.startAuthSession() // attempting
    }

    private func addItem(_ fileName: String, _ url: URL, _ title: String, _ documentContent: String) {
        withAnimation {
            let newItem = Item(timestamp: Date(), recipeURL: url, recipeName: title, documentContent: documentContent)
            modelContext.insert(newItem) // as to model for view
            FirebaseController.shared.saveRecipeToFirestore(fileName, url, title, documentContent) // as to firebase for storage
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

// struct for picking documents from device file system
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
