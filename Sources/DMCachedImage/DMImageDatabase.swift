//
//  File.swift
//  
//
//  Created by Daniel Mori on 06/09/24.
//

import SwiftUI
import SwiftData

@MainActor
internal class ImageDatabase {
    static var shared = ImageDatabase()
    private let container: ModelContainer?
    private let context: ModelContext?
    
    private init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: DMCachedImageModel.self, configurations: config)
            self.context = container?.mainContext
            context?.autosaveEnabled = true
        } catch {
            container = nil
            context = nil
        }
    }
    
    func save(image: Image, withURL url: URL) {
        guard let context = context, let data = ImageRenderer(content: image).uiImage?.pngData() else {
            return
        }
        let cachedImage = DMCachedImageModel(imageURL: url.absoluteString, image: data)
        context.insert(cachedImage)
        try? context.save()
    }
    
    func loadImage(fromURL url: String) -> Image? {
        guard let context = context else {
            return nil
        }
        
        var descriptor = FetchDescriptor<DMCachedImageModel>(
            predicate: #Predicate { $0.imageURL == url }
        )
        descriptor.fetchLimit = 1
        
        do {
            let result = try context.fetch(descriptor)
            if let data = result.first?.image, let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
