//
//  Token.swift
//  AskPaul
//
//  Created by Till Gartner on 03.10.25.
//

import Foundation
import NaturalLanguage
import Playgrounds

#Playground {
    _ = """
    A Playground to try cutting token-based substrings out of a longer string.
    Use case: Imagine we try to calculate the embedding vector of a string. How can we make sure that the entire string was embedded? If the string is longer, the embedding model doesn't report this as a problem. 
    """
    let text = TextSamples().englishMid
    if let contextModel = NLContextualEmbedding(language: .english) {
        
        // Contextual Model
        print("Calc'ing embedding with contextual model")
        let result = try contextModel.embeddingResult(for: text, language: nil)
    }
}

#Playground {
    _ = """
    A Playground to try identifying similarities on how NLContextualEmbedding and NLTokenizer tokenize text.
    Result: They are completely different... 😥
    """
    let text = TextSamples().englishMid + TextSamples().englishMid + TextSamples().englishMid
    
    if let contextModel = NLContextualEmbedding(language: .english) {
        
        // Contextual Model
        print("Calc'ing embedding with contextual model")
        let result = try contextModel.embeddingResult(for: text, language: nil)
        // Collect the tokens in result
        var resTokens = [String]()
        result.enumerateTokenVectors(in: result.string.startIndex..<result.string.endIndex) {_, range in
            let part = String(result.string[range])
            resTokens.append(part)
            return true
        }
        print("No of result Tokens: \(resTokens.count)")
        print("No of takens that Contextual Embedding can handle: \(contextModel.maximumSequenceLength)")
        
        // Tokenizer
        print("Calc'ing toekns with Tokenizer")
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var tokenizerTokens = [String]()
        tokenizer.enumerateTokens(in: tokenizer.string!.startIndex..<result.string.endIndex) {range, _ in
            let part = String(tokenizer.string![range])
            tokenizerTokens.append(part)
            return true
        }
        print("No of tokenizer Tokens: \(tokenizerTokens.count)")

        
        for i:Int in 0..<resTokens.count {
            if resTokens[i] != tokenizerTokens[i] {
                fatalError("Token mismatch")
            }
        }
        

    }
}

