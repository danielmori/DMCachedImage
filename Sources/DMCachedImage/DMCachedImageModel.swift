//
//  File.swift
//  
//
//  Created by Daniel Mori on 06/09/24.
//

import Foundation
import SwiftData

@Model
class DMCachedImageModel {
    @Attribute(.unique) var id: UUID = UUID()
    var imageURL: String
    @Attribute(.externalStorage) var image: Data?
    
    init(imageURL: String, image: Data? = nil) {
        self.imageURL = imageURL
        self.image = image
    }
}
