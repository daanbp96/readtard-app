//
//  AudiobookMetadata.swift
//  Readtard
//

import Foundation

struct AudiobookMetadata: Decodable {
    let title: String
    let author: String
    let publisher: String
    let coverImageFileName: String?
    let audioFileName: String
    let audioFileExtension: String
    let badge: String
    let durationSeconds: TimeInterval?
    let theme: ThemeMetadata

    struct ThemeMetadata: Decodable {
        let backgroundTopHex: String
        let backgroundBottomHex: String
        let coverStripeHex: String
    }
}
