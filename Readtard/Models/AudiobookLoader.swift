//
//  AudiobookLoader.swift
//  Readtard
//

import Foundation

enum AudiobookLoader {
    static func loadBundledAudiobook() throws -> Audiobook {
        guard let metadataURL = Bundle.main.url(
            forResource: "metadata",
            withExtension: "json",
            subdirectory: "Audiobook"
        ) else {
            throw AudiobookLoaderError.missingMetadata
        }

        let data = try Data(contentsOf: metadataURL)
        let metadata = try JSONDecoder().decode(AudiobookMetadata.self, from: data)
        let audiobook = Audiobook(
            title: metadata.title,
            author: metadata.author,
            publisher: metadata.publisher,
            badge: metadata.badge,
            duration: metadata.durationSeconds ?? 0,
            coverImageFileName: metadata.coverImageFileName,
            audioFileName: metadata.audioFileName,
            audioFileExtension: metadata.audioFileExtension,
            theme: PlayerTheme(
                backgroundTop: .fromHex(metadata.theme.backgroundTopHex),
                backgroundBottom: .fromHex(metadata.theme.backgroundBottomHex),
                coverStripe: .fromHex(metadata.theme.coverStripeHex)
            )
        )

        guard audiobook.audioURL != nil else {
            throw AudiobookLoaderError.missingAudioFile(
                "\(metadata.audioFileName).\(metadata.audioFileExtension)"
            )
        }

        return audiobook
    }
}

enum AudiobookLoaderError: LocalizedError {
    case missingMetadata
    case missingAudioFile(String)

    var errorDescription: String? {
        switch self {
        case .missingMetadata:
            return "Missing Audiobook/metadata.json in the app bundle."
        case let .missingAudioFile(fileName):
            return "Missing Audiobook/\(fileName) in the app bundle."
        }
    }
}
