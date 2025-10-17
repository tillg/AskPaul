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

2. **Proximity Search**: `ProximityFinder` performs k-nearest-neighbor search using embedding distance calculations. The current implementation uses a naive O(n*log(n)) approach that sorts all chunks by distance.

3. **Data Model**:
   - `Chunk`: Represents document fragments with content, metadata, and optional cached vectors
   - `Embeddable` protocol: Defines interface for objects that can generate embedding vectors
   - `EmbeddingStore`: Actor-based async cache for embedding vectors with in-flight deduplication

4. **Embedding Extensions**:
   - `NLContextualEmbeddingExtension`: Adds `vectorNaive()` and `distanceNaive()` methods that compute mean vectors from token embeddings
   - Uses cosine similarity for distance calculations (1 - cosineSimilarity)

### Key Design Patterns

- **Protocol-Oriented**: Uses `Embeddable` protocol for vector caching and computation
- **Actor-Based Concurrency**: `EmbeddingStore` uses Swift actors for thread-safe async caching
- **Lazy Evaluation**: Vectors are computed on-demand and cached for reuse
- **SwiftUI + Combine**: Reactive UI with `@State` property wrappers

### Performance Considerations

- The app logs distance calculation count during proximity search for performance monitoring
- Vector mean computation iterates through all tokens, which may be expensive for long texts
- The playground files contain performance comparisons between `NLEmbedding` and `NLContextualEmbedding`

## Testing Approach

Tests use Swift Testing framework (not XCTest) with the `@Test` and `@Suite` macros. Integration tests verify that the naive mean vector computation matches the expected mathematical mean.