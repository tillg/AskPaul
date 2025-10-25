//
//  ContentView.swift
//  AskPaul
//
//  Created by Till Gartner on 26.09.25.
//

import SwiftUI
import NaturalLanguage

struct ContentView: View {
    let chunks:[Chunk] = Chunk.chunks
    @State private var question: String = ""
    @State private var bestChunks : [Chunk] = []
    @State private var showSpinner : Bool = false
    @State private var embeddingStore: EmbeddingStore?

    var body: some View {
        VStack {
            Form {
                Text("Question")
                    .padding(.horizontal)
                    .font(.title2)
                TextEditor(text: $question)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5))
                    )
                Button("Find Answer") {
                    showSpinner = true
                    Task {
                        await getBestChunks()
                        await MainActor.run { showSpinner = false }
                    }
                }
                .padding()
                if showSpinner {
                    ProgressView() // default spinning indicator
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5) // make it bigger
                        .padding()
                } else {
                    List(bestChunks) { chunk in
                        Text(chunk.content)
                    }
                }
            }
        }
        .task {
            guard let contextModel = NLContextualEmbedding(language: .english) else {
                assertionFailure("Cannot create the NLContextualEmbedding")
                return
            }
            showSpinner = true
            do {
                if contextModel.hasAvailableAssets {
                    print("Loading assets...")
                    try await contextModel.requestAssets()
                    print("Loading assets... - Done")
                }
                print("Loading contextModel...")
                try contextModel.load()
                print("Loading contextModel... - Done")
                embeddingStore = EmbeddingStore(model: contextModel)
                print("Loading chunks into embeddingStore...")
                await embeddingStore?.loadChunks(chunks)
                print("Loading chunks into embeddingStore... - Done")
            } catch {
                print("Failed to prepare NLContextualEmbedding: \(error)")
            }
            showSpinner = false
        }
    }

    func getBestChunks() async {
        guard let embeddingStore = embeddingStore else {
            print("Embedding store not ready yet")
            await MainActor.run { bestChunks = [] }
            return
        }
        self.bestChunks = await embeddingStore.closest(to: self.question, k: 20)
    }
}

#Preview {
    ContentView()
}
