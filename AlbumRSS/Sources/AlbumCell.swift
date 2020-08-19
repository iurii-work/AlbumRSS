//
//  AlbumCell.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import Combine
import UIKit

class AlbumCell: UITableViewCell {
	private var cancellable: AnyCancellable?

	func configure(with album: Album) {
		if let imageView = self.imageView {
			let artworkURL = album.artworkURL
			if let artwork = ArtworkCache.shared.artwork(for: artworkURL) {
				imageView.image = artwork
				self.setNeedsLayout()
			} else {
				self.cancellable = ArtworkCache.shared.artworkPublisher(for: artworkURL)
					.receive(on: RunLoop.main)
					.sink { (artwork) in
						imageView.image = artwork
						self.setNeedsLayout()
					}
			}
		}
		if let textLabel = self.textLabel {
			textLabel.text = album.name
		}
		if let detailTextLabel = self.detailTextLabel {
			detailTextLabel.text = album.artist
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.cancellable?.cancel()
		self.imageView?.image = nil
		self.textLabel?.text = nil
		self.detailTextLabel?.text = nil
	}
}
