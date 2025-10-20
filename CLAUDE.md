# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AskPaul is a SwiftUI-based macOS application that uses Apple's NaturalLanguage framework for semantic search and text similarity. The app loads document chunks from a JSON file and finds the most relevant chunks based on user queries using embedding-based proximity search.

## Build and Development Commands

### Building
```bash
# Build for Debug
xcodebuild -project AskPaul/AskPaul.xcodeproj -scheme AskPaul -configuration Debug build

# Build for Release
xcodebuild -project AskPaul/AskPaul.xcodeproj -scheme AskPaul -configuration Release build

# Clean build
xcodebuild -project AskPaul/AskPaul.xcodeproj -scheme AskPaul clean
```

### Testing
```bash
# Run all tests
xcodebuild test -project AskPaul/AskPaul.xcodeproj -scheme AskPaul -destination 'platform=macOS'

# Run specific test
xcodebuild test -project AskPaul/AskPaul.xcodeproj -scheme AskPaul -destination 'platform=macOS' -only-testing:AskPaulTests/VectorMeanTest
```

## Architecture

### Core Components

1. **Embedding System**: The app uses two embedding approaches:
   - `NLEmbedding.sentenceEmbedding`: Apple's standard sentence embeddings (currently used in production)
   - `NLContextualEmbedding`: Newer contextual embeddings with token-level vectors (experimental, used in playgrounds)

2. **Proximity Search**: Two implementations exist:
   - `ProximityFinder`: Uses `NLEmbedding.sentenceEmbedding` with O(n*log(n)) sorting during search (legacy, used in ContentView)
   - `EmbeddingStore.closest()`: Actor-based async search that pre-computes and caches all vectors, then sorts by pre-calculated distances

3. **Data Model**:
   - `Chunk`: Represents document fragments with content, metadata, and SHA256-based ID. Loads from `merged_chunks.json` or `merged_chunks_all.json`
   - `Embeddable` protocol: Defines interface for objects that can generate embedding vectors (requires `content` and `id`)
   - `EmbeddingStore`: Actor-based async cache that pre-computes vectors for all chunks using task groups, with separate caches for chunk vectors and question vectors

4. **Vector Computation Methods**: The codebase has two approaches for computing mean vectors from contextual embeddings:
   - **Naive**: Pure Swift loops for vector addition/averaging (`vectorNaive()`, `meanVectorNaive()`)
   - **DSP**: Uses Apple's Accelerate framework with vDSP for SIMD-accelerated operations (`vectorDSP()`, `meanVectorDSP()`)

5. **Embedding Extensions**:
   - `NLContextualEmbeddingExtension`: Adds methods to `NLContextualEmbedding` and `NLContextualEmbeddingResult`
   - Both naive and DSP variants compute mean vectors by enumerating token embeddings
   - Uses cosine similarity for distance calculations (distance = 1 - cosineSimilarity)
   - Three cosine similarity implementations: `cosineSimilarityNaive()`, `cosineSimilarityZip()`, and `cosineSimilarity2()` (vDSP-based)

### Key Design Patterns

- **Protocol-Oriented**: Uses `Embeddable` protocol for vector caching and computation
- **Actor-Based Concurrency**: `EmbeddingStore` uses Swift actors for thread-safe async caching
- **Lazy Evaluation**: Vectors are computed on-demand and cached for reuse
- **SwiftUI + Combine**: Reactive UI with `@State` property wrappers

### Performance Considerations

- `EmbeddingStore` pre-computes all vectors using concurrent task groups for better performance
- `ProximityFinder.findClosest()` calculates O(n²) distances during sort (logs count for monitoring)
- `EmbeddingStore.closest()` pre-computes O(n) distances, then sorts - more efficient for repeated queries
- Vector caching strategies: `EmbeddingStore` caches both chunk vectors and question vectors separately
- DSP-based implementations use SIMD acceleration for faster vector operations on large datasets

### Playgrounds

The `Playgrounds/` directory contains performance comparison experiments:
- `01-NLEmbeddingPlayground.swift`: Tests standard `NLEmbedding.sentenceEmbedding`
- `02-NLContextrualNaivePlayground.swift`: Tests naive contextual embedding approach
- `03-NLContextrualNaiveOptimizedPlayground.swift`: Optimized naive implementation
- `04-NLContextrualNaiveBigDataPlayground.swift`: Tests with larger dataset (`merged_chunks_all.json`)
- `05-NLContextrualNaiveBigDataTimer.swift`: Timed benchmarks with big data
- `06-vForce.swift`: Tests using vForce/Accelerate framework
- `07-NLContextrualDSP.swift`: DSP-based implementation tests

Use playgrounds to benchmark performance changes before modifying production code.

## Utility Functions

Key helpers in `VectorsMean.swift`:
- `mean(of: [[Double]])`: Computes mean of vector arrays using pure Swift
- `mean2(of: [[Double]])`: vDSP-accelerated mean computation
- `meanTokenVector(in:using:)`: Generic function that works with any token vector enumerator
- `cosineSimilarityNaive()`: Pure Swift cosine similarity
- `cosineSimilarityZip()`: Functional approach using `zip()` and `map()`
- `cosineSimilarity2()`: vDSP-accelerated using `vDSP_dotprD` and `vDSP_svesqD`

Timing utilities in `Time.swift` and `Timer.swift`:
- `time()`: Synchronous timing wrapper that prints duration
- `timerTrack()`: Generic timing function that returns closure result
- Both support async operations via `await time()`

## Testing Approach

Tests use Swift Testing framework (not XCTest) with the `@Test` and `@Suite` macros:
- `VectorMeanTest.swift`: Integration test that verifies `meanVectorNaive()` computes the correct mathematical mean
- Tests collect all token vectors, compute mean using `mean()` helper, and compare against extension method output
- Floating point comparisons use tolerance of `1e-9` for numerical stability
- Tests handle async operations and may skip if embedding models are unavailable on the device