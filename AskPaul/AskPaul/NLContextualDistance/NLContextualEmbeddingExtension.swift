//
//  EmbeddingExtension.swift
//
//  Created by Till Gartner on 28.09.25.
//

import Accelerate
import Foundation
import NaturalLanguage

extension NLContextualEmbedding {
    
   
    
    func vector(for sentence: String, language: NLLanguage?) throws -> [Double] {

        let result = try timerTrack("Embedding") {
            try embeddingResult(for: sentence, language: language)
        }
        let meanVector: [Double]? = timerTrack("MeanVector") {
            result.meanVector()
        }

        // Unwrap and return
        if let mean = meanVector {
            return mean
        } else {
            fatalError("Could not calculate mean vector")
        }
    }
    
    
}

extension NLContextualEmbeddingResult {
    
   
    
    func meanVector() -> [Double]? {
        var sumVector: [Double]? = nil
        var count = 0
        self.enumerateTokenVectors(in: self.string.startIndex..<self.string.endIndex) { vector, _ in
            if sumVector == nil {
                sumVector = vector
            } else {
                precondition(sumVector!.count == vector.count, "All vectors must have the same length")
                sumVector = vDSP.add(sumVector!, vector)
            }
            count += 1
            return true
        }
        
        // Check that we are not facing an empty arry of vectors - avoid div by 0
        guard var sumVector = sumVector, count > 0 else {
            print("meanVectorDSP: No token vectors to average")
            return nil
        }
        
        let divisor = Double(count)
        sumVector = vDSP.multiply(divisor, sumVector)
        return sumVector
    }
}
