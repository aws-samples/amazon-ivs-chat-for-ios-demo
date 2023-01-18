//
//  ImageLoader.swift
//  SimpleChat
//
//  Created by Uldis Zingis on 07/09/2021.
//  

import SwiftUI
import Combine

struct RemoteImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()

    init(imageURL url: String) {
        imageLoader = ImageLoader(urlString: url)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .onReceive(imageLoader.didChange) { image in
                self.image = image
            }
    }
}

class ImageLoader: ObservableObject {
    var didChange = CurrentValueSubject<UIImage, Never>(UIImage())
    @Published var image = UIImage() {
        didSet { didChange.send(image) }
    }

    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if let cachedImage = ImageCache.singleton.getImage(from: url) {
            self.image = cachedImage
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let loadedImage = UIImage(data: data) else { return }
                ImageCache.singleton.set(loadedImage, url: urlString)
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
            task.resume()
        }
    }
}

final class ImageCache {
    public static let singleton = ImageCache()
    private var cache = NSCache<NSString, UIImage>()

    func getImage(from url: URL) -> UIImage? {
        let cacheUrl = url.absoluteString
        return cache.object(forKey: cacheUrl as NSString)
    }

    func set(_ image: UIImage, url: String) {
        ImageCache.singleton.cache.setObject(image, forKey: url as NSString)
    }
}
