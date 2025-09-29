//
//  Time.swift
//  AskPaul
//
//  Created by Till Gartner on 29.09.25.
//

import Foundation

@discardableResult
func time<T>(_ label: String, _ body: () throws -> T) rethrows -> T {
    let start = CFAbsoluteTimeGetCurrent()
    defer {
        let end = CFAbsoluteTimeGetCurrent()
        print("\(label): \((end - start) * 1000) ms")
    }
    return try body()
}

@discardableResult
func time<T>(_ label: String, _ body: () async throws -> T) async rethrows -> T {
    let start = CFAbsoluteTimeGetCurrent()
    defer {
        let end = CFAbsoluteTimeGetCurrent()
        print("\(label): \((end - start) * 1000) ms")
    }
    return try await body()
}
