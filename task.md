Rewrite my embedding store so:
- It deals directly with Chunks, i.e. uses teh chunk's id for indexing in cache and accesses the chunk.content
- Has a function embeddingStore.loadChunks(with: chunk[]) to initiate it's internal chunk store and calculating all their vectors
- Once the chunks are loaded provides a function distance(question: String, chunk: Chunk) that calculates the cosine distance without await, using the cached vector of the chunk
- A function closests(to:String, k:Int = 3) that returns the closest chunks by cosine distance. Does so by sorting the chunks.