//
//  Playground.swift
//  AskPaul
//
//  Created by Till Gartner on 26.09.25.
//

import FoundationModels
import NaturalLanguage
import Playgrounds



#Playground {
    if let embeddingModel = NLContextualEmbedding(language: .english)
    {
        let status = """
        Created Sentence Embedding 👍🏼.
          Dimension: \(embeddingModel.dimension),
          Description: \(embeddingModel.description),
          Languages: \(embeddingModel.languages)
        """
        print (status)
        if embeddingModel.hasAvailableAssets {
            print("Loading assets...")
            try await embeddingModel.requestAssets()
            print("Assets loaded 👍🏼")
        }
        try embeddingModel.load()
        let sentence1 = "This is a sentence."
        let sentence2 = "This is another sentence"
        let distance = try embeddingModel.distance(between: sentence1, and: sentence2)
        print (distance)

    } else {
        print("Error: Failed to create NLContextualEmbedding for English.")
    }
}


//#Playground {
//    if let embeddingModel = NLContextualEmbedding(language: .english)
//    {
//        let status = """
//        Created Sentence Embedding 👍🏼.
//          Dimension: \(embeddingModel.dimension),
//          Description: \(embeddingModel.description),
//          Languages: \(embeddingModel.languages)
//        """
//        print (status)
//        if embeddingModel.hasAvailableAssets {
//            print("Loading assets...")
//            try await embeddingModel.requestAssets()
//            print("Assets loaded 👍🏼")
//        }
//        try embeddingModel.load()
//        let sentence = "This is a sentence."
//        let result = try embeddingModel.embeddingResult(for: sentence, language: .english)
//        let resultDesc = "NLEmbeddingResult: language: \(result.language), sequenceLength: \(result.sequenceLength), string: \(result.string)"
//        print (resultDesc)
//        
//        // Inspect tokens + their vectors
//        result.enumerateTokenVectors(in: result.string.startIndex..<result.string.endIndex) { vector, range in
//            let token = result.string[range]
//            print("Vector for token \(token), dimension: \(vector.count)")
//            
//            // Return true to keep enumerating, false to stop early
//            return true
//        }
//        
//        if let meanVector = meanTokenVector(in: result.string.startIndex..<result.string.endIndex, using: result.enumerateTokenVectors) {
//            print(meanVector)
//        }
//
//    } else {
//        print("Error: Failed to create NLContextualEmbedding for English.")
//    }
//}
//
//#Playground {
//    let question = """
//        How do I define a protocol?
//        """
//    let chunks:[Chunk] = Bundle.main.decode("merged_chunks.json")
//    print("No of chunks: \(chunks.count)")
//    let proxFinder = try ProximityFinder()
//    let bestAnswers = proxFinder.findClosest(to: question, in: chunks)
//    print(bestAnswers.count)
//    print("\(bestAnswers)")
//}

//#Playground {
//    let sentence = "This is a sentence."
//    let sentences = ["This is a sentence.", "This is another sentence."]
//    let proxFinder = try ProximityFinder()
//    let closests = proxFinder.findClosest(to: sentence, in: sentences)
//    print(closests)
//
//}



#Playground
{
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
        let sentence = "This is a sentence."


        if let vector = sentenceEmbedding.vector(for: sentence) {
            print(vector)
        }
        
        let distance = sentenceEmbedding.distance(between: sentence, and: "That is a sentence.")
        print(distance.description)
    }

}

//
//#Playground {
//    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
//        let sentence = "This is a sentence."
//        
//        if let vector = sentenceEmbedding.vector(for: sentence) {
//            print(vector)
//        }
//        
//        let dist = sentenceEmbedding.distance(between: sentence, and: "That is a sentence.")
//        print(dist)
//    } else {
//        print("No SentenceEmbedding")
//    }
//}
//
//

//

//
//
//
//#Playground {
//    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
//        let sentence = "This is a sentence."
//        if let vector = sentenceEmbedding.vector(for: sentence) {
//            print(vector)
//        }
//        let distance = sentenceEmbedding.distance(between: sentence, and: "That is a sentence.")
//        print(distance.description)
//    } else {
//        print("No sentenceEmbedding!")
//    }
//}
//

