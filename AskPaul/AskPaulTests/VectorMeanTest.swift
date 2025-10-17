//
//  VectorMeanTest.swift
//  AskPaul
//
//  Created by Till Gartner on 03.10.25.
//

import Testing
import NaturalLanguage
@testable import AskPaul

@Suite("Integration: NLContextualEmbedding mean")
struct EmbeddingMeanIntegrationTests {

    @Test("getMeanVectorNaive matches recomputed mean from enumerated token vectors")
    func meanMatchesRecomputed() async throws {
        guard let embedding = NLContextualEmbedding(language: .english) else {
            // Skip if embedding is not available on this device/OS
            return
        }
        if embedding.hasAvailableAssets {
            try await embedding.requestAssets()
        }
        try embedding.load()

        let sentence = "This is a small test."
        let result = try embedding.embeddingResult(for: sentence, language: .english)

        // Compute expected mean by capturing all token vectors, then using the simple mean helper.
        var collected: [[Double]] = []
        result.enumerateTokenVectors(in: result.string.startIndex..<result.string.endIndex) { vector, _ in
            collected.append(vector)
            return true
        }

        let expected = mean(of: collected)  // or mean2(of:)
        let actual = getMeanVectorNaive(result: result)

        let exp = try #require(expected)
        let act = try #require(actual)

        #expect(exp.count == act.count)
        for i in 0..<exp.count {
            #expect(abs(exp[i] - act[i]) < 1e-9)
        }
    }
}
