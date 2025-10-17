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

        let sentence = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sit amet tempus nibh, at aliquam lorem. Donec finibus sapien nisi, ullamcorper viverra diam viverra sed. Morbi efficitur ante in faucibus venenatis. Nam sem lectus, porttitor hendrerit bibendum bibendum, gravida sed felis. Nullam ullamcorper quam et sem finibus gravida. Proin pulvinar, mauris at sollicitudin porttitor, velit neque consequat risus, eu varius arcu ligula eget magna. Donec eget dui eget augue pulvinar molestie quis id libero. In purus nisl, consectetur eu mauris et, vulputate dictum ex. Aliquam erat volutpat. Aenean pulvinar maximus gravida. Mauris vitae turpis sit amet turpis luctus ultrices. Vestibulum vulputate mattis neque vel posuere. Donec malesuada malesuada consectetur. Sed eu felis eget sapien hendrerit ultrices. Maecenas tincidunt turpis magna, id malesuada arcu faucibus ut. Cras elementum orci sed elit dictum elementum.

            Praesent a odio non elit venenatis laoreet. Sed lectus neque, vulputate quis augue vitae, rutrum congue velit. Nulla eu nisl eros. Mauris a fermentum enim, ut feugiat nibh. Aliquam id libero vitae turpis ullamcorper condimentum. Ut in ex imperdiet, aliquet odio vel, dapibus risus. Proin vel tincidunt sem.

            Morbi vulputate consequat imperdiet. Etiam fringilla consequat porta. Quisque nec egestas eros, ac iaculis dolor. Duis quis risus eu ex facilisis accumsan. Sed at pretium magna. Nulla mauris tellus, elementum sit amet felis sit amet, consequat pharetra nunc. Integer eu augue justo. Quisque nec varius nisi, eu condimentum sem. Nulla mattis ipsum et ullamcorper consectetur.

            Donec ac venenatis eros. Donec vel quam volutpat, molestie elit a, aliquet orci. Proin consequat eros rhoncus eros blandit, non consequat arcu varius. Morbi imperdiet vehicula eleifend. Donec ex odio, pulvinar dictum odio eu, sollicitudin sodales augue. Maecenas mollis orci in laoreet lacinia. Maecenas quis ex id mi cursus laoreet.

            Vivamus faucibus justo sed congue molestie. Curabitur elementum, ex vel gravida congue, turpis ante ultricies quam, in pretium libero justo sit amet augue. Praesent interdum lacus ultrices fringilla vehicula. Mauris vitae ligula et ligula aliquam auctor non eu risus. Nullam sed risus ut nisl dictum bibendum. Donec vel hendrerit elit, sit amet pellentesque nulla. Nulla blandit dolor quam. Vivamus ultricies vulputate massa, vel tincidunt ante venenatis non. Mauris volutpat, ligula eu ultrices semper, tellus risus aliquam ipsum, sed volutpat nulla est quis arcu. Sed at dui vitae mi consequat posuere. Donec pulvinar tincidunt nisi, a luctus dui eleifend sed.
            """
        let result = try embedding.embeddingResult(for: sentence, language: .english)

        // Compute expected mean by capturing all token vectors, then using the simple mean helper.
        var collected: [[Double]] = []
        result.enumerateTokenVectors(in: result.string.startIndex..<result.string.endIndex) { vector, _ in
            collected.append(vector)
            return true
        }
        print("Shape of result: \(collected.count)x\(collected[0].count)")

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
