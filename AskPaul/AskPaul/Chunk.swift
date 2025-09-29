//
//  Chunk.swift
//  AskPaul
//
//  Created by Till Gartner on 27.09.25.
//

import Foundation

struct Chunk: Identifiable, Codable, Embeddable {
    var id: String {chunk_file}
    let chunk_file: String
    let original_url: String
    let title: String
    let content: String
    var vector: [Double]?
}
