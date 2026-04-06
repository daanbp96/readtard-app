//
//  Audiobook.swift
//  Readtard
//

import Foundation

struct Audiobook {
    let title: String
    let author: String
    let publisher: String
    let badge: String
    let duration: TimeInterval
    let coverImageFileName: String?
    let audioFileName: String
    let audioFileExtension: String
    let theme: PlayerTheme

    var audioURL: URL? {
        Bundle.main.url(
            forResource: audioFileName,
            withExtension: audioFileExtension,
            subdirectory: "Audiobook"
        )
    }

    var coverURL: URL? {
        guard let coverImageFileName else {
            return nil
        }

        let fileName = coverImageFileName as NSString

        return Bundle.main.url(
            forResource: fileName.deletingPathExtension,
            withExtension: fileName.pathExtension,
            subdirectory: "Audiobook"
        )
    }
}
