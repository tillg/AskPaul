//
//  NLEmbedding.swift
//  AskPaul
//
//  Created by Till Gartner on 01.10.25.
//

import NaturalLanguage
import Playgrounds


#Playground("Basic embedding & distance")
{
    let question = """
        How can I extend a protocol?
    """
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
        if let vector = sentenceEmbedding.vector(for: question) {
            print(vector)
        }
        let distance = sentenceEmbedding.distance(between: question, and: "That is a sentence.")
        print(distance.description)
    }
}


#Playground("Calc Embeddings")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating embedding vector for \(chunks.count) chunks")
    
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {

        time("Calculating \(chunks.count) vectors with NLEmbedding") {
            for chunk in chunks {
                _ = sentenceEmbedding.vector(for: chunk.content)
            }
        }
        print("Done calculating vectors with NLEmbedding")
    }
}


#Playground("Calc Distances")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    
    print("Calculating distance between \(chunks.count) pairs of sentences")
    
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {

        time("Calculating \(chunks.count) distances with NLEmbedding") {
            for chunk in chunks {
                _ = sentenceEmbedding.distance(between: chunk.content, and: chunks.randomElement()!.content)
            }
        }
        print("Done calculating distances with NLEmbedding")
    }
}

#Playground("Calc closest in arry")
{
    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
    print("Calculating the closest chunks in an array of \(chunks.count) chunks")

    func findClosest<T: Embeddable>(to question: String, in chunks: [T], k: Int = 3) -> [T] {
        guard let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) else {
            // Fallback if embedding is unavailable
            return Array(chunks.prefix(k))
        }
        var distanceCalculations = 0
        let sorted = chunks.sorted { lhs, rhs in
            let dl = sentenceEmbedding.distance(between: question, and: lhs.content)
            let dr = sentenceEmbedding.distance(between: question, and: rhs.content)
            distanceCalculations += 2
            return dl < dr
        }
        print("\(distanceCalculations) distance calculations done.")
        return Array(sorted.prefix(k))
    }
    
    time("Calculating the closest chunks in an array of \(chunks.count) chunks") {
        let closeOnes = findClosest(to: "What is the capital of France?", in: chunks)
    }
}

