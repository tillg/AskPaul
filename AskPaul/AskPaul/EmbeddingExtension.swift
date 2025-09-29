//
//  EmbeddingExtension.swift
//  AskPaul
//
//  Created by Till Gartner on 28.09.25.
//

import Foundation
import NaturalLanguage

extension NLContextualEmbedding {
    func vector(for sentence : String, language: NLLanguage?) throws -> [Double] {
        
        let result = try self.embeddingResult(for: sentence, language: language)
//        let resultDesc = "NLEmbeddingResult: language: \(result.language), sequenceLength: \(result.sequenceLength), string: \(result.string)"
//        print (resultDesc)
        
        if let meanVector = meanTokenVector(in: result.string.startIndex..<result.string.endIndex, using: result.enumerateTokenVectors) {
            return(meanVector)
        } else {
            print("Error! No mean vector found!")
           return []
        }
    }
    
    func distance(between firstString: String, and secondString: String) throws -> Double {
        let firstVector =  try self.vector(for: firstString, language: nil) ?? []
        let secondVector = try self.vector(for: secondString, language: nil) ?? []
        
        let cosineSim = cosineSimilarity(firstVector, secondVector) ?? 0.0
        let distance = 1 - cosineSim
        return distance
    }
}
