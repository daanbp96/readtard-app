//
//  AskConversationController.swift
//  Readtard
//

import Combine
import Foundation

@MainActor
final class AskConversationController: ObservableObject {
    @Published var messages: [AskMessage] = []
    @Published var draft = ""
    @Published var isSending = false
    @Published private(set) var contextSummary: String?

    private var context: AskContext?

    func configure(book: Audiobook?, currentTime: TimeInterval, duration: TimeInterval) {
        guard messages.isEmpty else {
            return
        }

        guard let book else {
            contextSummary = "I could not load the current audiobook context yet."
            return
        }

        context = AskContext(
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            currentTime: currentTime,
            duration: duration
        )
        contextSummary = "\(book.title) · \(formattedTime(currentTime))"
    }

    func sendCurrentQuestion() {
        let trimmedDraft = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDraft.isEmpty, !isSending else {
            return
        }

        draft = ""
        isSending = true
        messages.append(AskMessage(role: .user, text: trimmedDraft))

        let responseContext = context

        Task {
            try? await Task.sleep(for: .milliseconds(700))

            let responseText: String
            if let responseContext {
                responseText = """
                Placeholder answer for the future LLM backend.

                Question received for "\(responseContext.title)" at \(formattedTime(responseContext.currentTime)) of \(formattedTime(responseContext.duration)). The backend request can include the book metadata plus the listening position, then return the assistant response here.
                """
            } else {
                responseText = "The ask assistant is not ready because the audiobook context is missing."
            }

            messages.append(AskMessage(role: .assistant, text: responseText))
            isSending = false
        }
    }

    private func formattedTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds.rounded(.down))
        let minutes = totalSeconds / 60
        let remainder = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}

struct AskMessage: Identifiable {
    enum Role {
        case assistant
        case user

        var title: String {
            switch self {
            case .assistant:
                return "Assistant"
            case .user:
                return "You"
            }
        }
    }

    let id = UUID()
    let role: Role
    let text: String
}

private struct AskContext {
    let title: String
    let author: String
    let publisher: String
    let currentTime: TimeInterval
    let duration: TimeInterval
}
