//
//  ArtworkCard.swift
//  Readtard
//

import SwiftUI
import UIKit

struct ArtworkCard: View {
    let book: Audiobook

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.01, green: 0.02, blue: 0.10))

            if let coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(height: 344)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.28), radius: 24, y: 14)
    }

    private var coverImage: UIImage? {
        guard let coverURL = book.coverURL else {
            return nil
        }

        return UIImage(contentsOfFile: coverURL.path)
    }
}
