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
                        VStack(alignment: .leading) {
                            Text(item.recipeName)
                            Text("⏱️ \(item.cookingTime)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
        
        // Extract cooking time from document
        let cookingTime = extractCookingTime(from: cleanedString)
        
        addItem(documentName, url, documentTitle, documentContentString, cookingTime) // add new item to storage
        // SpotifyAPIController.shared.startAuthSession() // attempting
    }

    private func extractCookingTime(from text: String) -> String {
        let patterns = [
            "\\b(\\d+)\\s*(?:minutes?|mins?)\\b",
            "\\b(\\d+)\\s*(?:hours?|hrs?)\\b",
            "\\b(\\d+)\\s*(?:seconds?|secs?)\\b"
        ]
        
        for pattern in patterns {
            if let range = text.range(of: pattern, options: .regularExpression) {
                let match = String(text[range])
                return match.capitalized
            }
        }
        return "Unknown"
    }
    
    private func addItem(_ fileName: String, _ url: URL, _ title: String, _ documentContent: String, _ cookingTime: String) {
        withAnimation {
            let newItem = Item(timestamp: Date(), recipeURL: url, recipeName: title, documentContent: documentContent, cookingTime: cookingTime)
            modelContext.insert(newItem) // add to model for view
            FirebaseController.shared.saveRecipeToFirestore(fileName, url, title, documentContent) // add to firebase for storage
            FirebaseController.shared.getPlaylist("rock", 30) // get playlist for user
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
