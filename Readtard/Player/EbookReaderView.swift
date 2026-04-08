//
//  EbookReaderView.swift
//  Readtard
//

import ReadiumNavigator
import SwiftUI
import UIKit

struct EbookReaderView: View {
    @ObservedObject var reader: EbookReaderController
    let book: Audiobook
    let onAskTapped: () -> Void
    let onSwitchToAudiobook: () -> Void
    let onReturnToLibrary: () -> Void
    @State private var isSettingsPresented = false
    @State private var isContentsPresented = false

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.13)
                    .ignoresSafeArea()

                if reader.hasLoadedEbook {
                    if let navigator = reader.navigator {
                        EbookNavigatorContainerView(navigator: navigator) { zone in
                            switch zone {
                            case .left:
                                reader.goToPreviousPage()
                            case .center:
                                reader.toggleControls()
                            case .right:
                                reader.goToNextPage()
                            }
                        }
                            .padding(.top, topContentInset(isLandscape: isLandscape))
                            .padding(.bottom, bottomContentInset(isLandscape: isLandscape))
                            .ignoresSafeArea()

                        Color.black
                            .opacity((1 - reader.appearance.brightness) * 0.55)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)

                        readerChromeProtection(isLandscape: isLandscape)

                        overlayControls(isLandscape: isLandscape)
                    } else if reader.isLoading {
                        loadingView
                    } else {
                        loadingFailureView
                    }
                } else {
                    missingEbookView
                }
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            EbookReaderSettingsSheet(reader: reader)
        }
        .sheet(isPresented: $isContentsPresented) {
            EbookContentsSheet(reader: reader)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)

            Text("Opening ebook…")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.84))
        }
    }

    private var loadingFailureView: some View {
        VStack(spacing: 18) {
            Spacer()

            Text(reader.loadingError ?? "Unable to open ebook.")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .multilineTextAlignment(.center)

            Button("Switch to audiobook") {
                onSwitchToAudiobook()
            }
            .font(.system(size: 18, weight: .semibold))
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.12))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .buttonStyle(.plain)

            Button("Back to library") {
                onReturnToLibrary()
            }
            .font(.system(size: 18, weight: .semibold))
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08))
            .foregroundStyle(.white.opacity(0.9))
            .clipShape(Capsule())
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(24)
    }

    private var missingEbookView: some View {
        VStack {
            Spacer()

            Text("No ebook loaded")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))

            Spacer()

            HStack(spacing: 16) {
                Button("Library") {
                    onReturnToLibrary()
                }
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .foregroundStyle(.white.opacity(0.9))
                .clipShape(Capsule())
                .buttonStyle(.plain)

                Button("Switch to audiobook") {
                    onSwitchToAudiobook()
                }
                .font(.system(size: 17, weight: .semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .buttonStyle(.plain)
            }
            .padding(.bottom, 34)
        }
    }

    private func readerChromeProtection(isLandscape: Bool) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.12, blue: 0.13),
                    Color(red: 0.12, green: 0.12, blue: 0.13).opacity(0.88),
                    Color(red: 0.12, green: 0.12, blue: 0.13).opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: fixedTopChromeHeight(isLandscape: isLandscape))

            Spacer()

            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.12, blue: 0.13).opacity(0),
                    Color(red: 0.12, green: 0.12, blue: 0.13).opacity(0.9),
                    Color(red: 0.12, green: 0.12, blue: 0.13)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: fixedBottomChromeHeight(isLandscape: isLandscape))
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func topContentInset(isLandscape: Bool) -> CGFloat {
        isLandscape ? 86 : 108
    }

    private func bottomContentInset(isLandscape: Bool) -> CGFloat {
        isLandscape ? 86 : 104
    }

    private func fixedTopChromeHeight(isLandscape: Bool) -> CGFloat {
        isLandscape ? 104 : 120
    }

    private func fixedBottomChromeHeight(isLandscape: Bool) -> CGFloat {
        isLandscape ? 106 : 126
    }

    @ViewBuilder
    private func overlayControls(isLandscape: Bool) -> some View {
        if reader.controlsVisible {
            VStack {
                HStack {
                    Spacer()

                    Button {
                        onReturnToLibrary()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 48, height: 48)
                            .background(Color.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Text("\(reader.pagesLeftInChapter) pages left in chapter")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, isLandscape ? -34 : 4)

                Spacer()

                HStack(alignment: .bottom) {
                    Button {
                        onAskTapped()
                    } label: {
                        Text("Ask me")
                            .font(.system(size: 17, weight: .semibold))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 11)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(.leading, 24)

                    Spacer()

                    Text("\(reader.currentPageNumber) of \(reader.totalPages)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Menu {
                        Button("Contents") {
                            isContentsPresented = true
                        }

                        Button("Switch to audiobook") {
                            onSwitchToAudiobook()
                        }

                        Button("Themes & Settings") {
                            isSettingsPresented = true
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 22, weight: .medium))
                            .frame(width: 54, height: 54)
                            .background(Color.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(.trailing, 24)
                }
                .padding(.bottom, isLandscape ? 24 : 34)
            }
        } else {
            VStack {
                Text(reader.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.top, 42)

                Spacer()

                Text("\(reader.currentPageNumber)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 24)
            .allowsHitTesting(false)
        }
    }
}

private struct EbookNavigatorContainerView: UIViewControllerRepresentable {
    enum TapZone {
        case left
        case center
        case right
    }

    let navigator: VisualNavigator & UIViewController
    let onTapZone: (TapZone) -> Void

    func makeUIViewController(context: Context) -> EbookNavigatorHostViewController {
        EbookNavigatorHostViewController(navigator: navigator, onTapZone: onTapZone)
    }

    func updateUIViewController(_ uiViewController: EbookNavigatorHostViewController, context: Context) {
        uiViewController.setNavigator(navigator)
        uiViewController.onTapZone = onTapZone
    }
}

private final class EbookNavigatorHostViewController: UIViewController {
    private var navigator: (VisualNavigator & UIViewController)
    var onTapZone: ((EbookNavigatorContainerView.TapZone) -> Void)?
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()

    init(
        navigator: VisualNavigator & UIViewController,
        onTapZone: @escaping (EbookNavigatorContainerView.TapZone) -> Void
    ) {
        self.navigator = navigator
        self.onTapZone = onTapZone
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init?(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addGestureRecognizer(tapRecognizer)
        embedCurrentNavigator()
    }

    func setNavigator(_ newNavigator: VisualNavigator & UIViewController) {
        guard navigator !== newNavigator else {
            return
        }

        removeCurrentNavigator()
        navigator = newNavigator

        if isViewLoaded {
            embedCurrentNavigator()
        }
    }

    private func embedCurrentNavigator() {
        addChild(navigator)
        navigator.view.frame = view.bounds
        navigator.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigator.view.backgroundColor = .clear
        view.addSubview(navigator.view)
        navigator.didMove(toParent: self)
    }

    private func removeCurrentNavigator() {
        navigator.willMove(toParent: nil)
        navigator.view.removeFromSuperview()
        navigator.removeFromParent()
    }

    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else {
            return
        }

        let location = recognizer.location(in: view)
        let width = max(view.bounds.width, 1)
        let zone: EbookNavigatorContainerView.TapZone

        switch location.x / width {
        case ..<0.33:
            zone = .left
        case ..<0.66:
            zone = .center
        default:
            zone = .right
        }

        onTapZone?(zone)
    }
}

#Preview {
    ContentView()
}
