//
//  ChunkListView.swift
//  AskPaul
//
//  Created by Till Gartner on 27.09.25.
//

import SwiftUI

struct ChunkListView: View {
    let chunk: Chunk
    
    var body: some View {
        VStack(alignment: .leading) {
            Link(chunk.title, destination: URL(string: chunk.original_url)!)
            Text(chunk.content.prefix(100))
        }
    }
}

#Preview {
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    List {
        ChunkListView(chunk: chunks.randomElement()!)
        ChunkListView(chunk: chunks.randomElement()!)
        ChunkListView(chunk: chunks.randomElement()!)
        ChunkListView(chunk: chunks.randomElement()!)
    }
}
