//
//  HasContentProtocol.swift
//  AskPaul
//
//  Created by Till Gartner on 27.09.25.
//

import Foundation

protocol Embeddable {
    var content: String { get }
    var vector: [Double]? { get set }
}
