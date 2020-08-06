//
//  ArtworkCache.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import Combine
import UIKit

class ArtworkCache {
	private let cache = NSCache<NSURL, UIImage>()
	static let shared = ArtworkCache()

	func artwork(for artworkURL: URL) -> UIImage? { self.cache.object(forKey: artworkURL as NSURL) }

	func artworkPublisher(for artworkURL: URL) -> AnyPublisher<UIImage?, Never> {
		var result: AnyPublisher<UIImage?, Never>!
		if let artwork = self.cache.object(forKey: artworkURL as NSURL) {
			result = Just(artwork).eraseToAnyPublisher()
		} else {
			result = URLSession.shared.dataTaskPublisher(for: artworkURL)
				.map { (data, _) -> UIImage? in UIImage(data: data) }
				.catch { _ in Just(nil) }
				.handleEvents(receiveOutput: { image in
					if let image = image {
						self.cache.setObject(image, forKey: artworkURL as NSURL)
					}
				})
				.eraseToAnyPublisher()
		}
		return result
	}
}
