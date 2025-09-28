//
//  ContentView.swift
//  AskPaul
//
//  Created by Till Gartner on 26.09.25.
//

import SwiftUI

struct ContentView: View {
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    @State private var question: String = ""
    @State private var bestChunks : [Chunk] = []
    @State private var showSpinner : Bool = false
    
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
                    getBestChunks()
                    showSpinner = false
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
        
    }
    
    func getBestChunks() {
        do {
            let proxFinder = try ProximityFinder()
            bestChunks = proxFinder.findClosest(to: question, in: chunks, k: 10)
        } catch {
            print("Error creating ProximityFinder: \(error)")
            bestChunks = []
        }
    }
}

#Preview {
    ContentView()
}
