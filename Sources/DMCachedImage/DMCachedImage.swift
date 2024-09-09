// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import SwiftData

struct DMCachedImage<Content>: View where Content: View {
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    init(url: URL, scale: CGFloat = 1.0, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        if let cached = DMImageDatabase.shared.loadImage(fromURL: url.absoluteString) {
            content(.success(cached))
        } else {
            AsyncImage (
                url: url,
                scale: scale,
                transaction: transaction
            ) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    @MainActor
    private func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success(let image) = phase {
            DMImageDatabase.shared.save(image: image, withURL: url)
        }
        return content(phase)
    }
}
