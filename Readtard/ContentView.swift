//
//  ContentView.swift
//  Readtard
//
//  Created by Daan Barsukoff Poniatowsky on 06/04/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var player = AudioPlayerController()
    @State private var isAskSheetPresented = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: backgroundColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let _ = player.book {
                AudiobookPlayerView(
                    player: player,
                    onAskTapped: presentAskSheet
                )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            } else {
                MissingAudiobookView(message: player.loadingError ?? "Unable to load audiobook.")
                    .padding(24)
            }

            if isAskSheetPresented {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)

                AskConversationSheet(
                    player: player,
                    onClose: dismissAskSheet
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.spring(response: 0.34, dampingFraction: 0.88), value: isAskSheetPresented)
    }

    private var backgroundColors: [Color] {
        if let theme = player.book?.theme {
            return [theme.backgroundTop, theme.backgroundBottom]
        }

        return [Color(red: 0.14, green: 0.06, blue: 0.09), Color(red: 0.08, green: 0.03, blue: 0.05)]
    }

    private func presentAskSheet() {
        player.pausePlayback()
        isAskSheetPresented = true
    }

    private func dismissAskSheet() {
        isAskSheetPresented = false
    }
}

#Preview {
    ContentView()
}

private struct MissingAudiobookView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            Text("Audiobook files not found")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)

            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
        }
    }
}
