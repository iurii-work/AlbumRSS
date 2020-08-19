//
//  AlbumViewController.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import Combine
import UIKit

class AlbumViewController: UIViewController {
	private let album: Album
	private var cancellable: AnyCancellable?

	private let activityIndicatorView: UIActivityIndicatorView = {
		let result = UIActivityIndicatorView()
		result.isHidden = true
		result.style = .large
		result.translatesAutoresizingMaskIntoConstraints = false
		result.setContentHuggingPriority(.defaultLow, for: .horizontal)
		result.setContentHuggingPriority(.defaultLow, for: .vertical)
		return result
	}()

	private let albumLabel: UILabel = {
		let result = UILabel()
		result.lineBreakMode = .byWordWrapping
		result.numberOfLines = 0
		result.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return result
	}()

	private let artistLabel: UILabel = {
		let result = UILabel()
		result.lineBreakMode = .byWordWrapping
		result.numberOfLines = 0
		result.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		result.textColor = .systemBlue
		return result
	}()

	private let artworkView: UIImageView = {
		let result = UIImageView()
		result.contentMode = .scaleAspectFit
		return result
	}()

	private let button: UIButton = {
		let result = UIButton(type: .system)
		result.translatesAutoresizingMaskIntoConstraints = false
		result.setTitle("Open", for: .normal)
		result.addTarget(self, action: #selector(open(_:)), for: .touchUpInside)
		return result
	}()

	private let copyrightLabel: UILabel = {
		let result = UILabel()
		result.lineBreakMode = .byWordWrapping
		result.numberOfLines = 0
		result.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		result.textColor = .systemGray
		return result
	}()

	private let genreLabel: UILabel = {
		let result = UILabel()
		result.lineBreakMode = .byWordWrapping
		result.numberOfLines = 0
		result.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		result.textColor = .systemGray
		return result
	}()

	private let releaseDateLabel: UILabel = {
		let result = UILabel()
		result.textColor = .systemGray
		return result
	}()

	private let scrollView: UIScrollView = {
		let result = UIScrollView()
		result.translatesAutoresizingMaskIntoConstraints = false
		return result
	}()

	private let stackView: UIStackView = {
		let result = UIStackView()
		result.axis = .vertical
		result.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
		result.isLayoutMarginsRelativeArrangement = true
		result.spacing = UIStackView.spacingUseSystem
		result.translatesAutoresizingMaskIntoConstraints = false
		return result
	}()

	init(album: Album) {
		self.album = album
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		let album = self.album
		let artworkURL = album.artworkURL
		let artworkView = self.artworkView
		if let artwork = ArtworkCache.shared.artwork(for: artworkURL) {
			artworkView.image = artwork
		} else {
			let activityIndicatorView = self.activityIndicatorView
			activityIndicatorView.startAnimating()
			activityIndicatorView.isHidden = false
			self.cancellable = ArtworkCache.shared.artworkPublisher(for: artworkURL)
				.receive(on: RunLoop.main)
				.sink(receiveCompletion: { _ in
					activityIndicatorView.isHidden = true
					activityIndicatorView.stopAnimating()
				}, receiveValue: { image in
					artworkView.image = image
				})
		}
		self.albumLabel.text = album.name.uppercased()
		self.artistLabel.text = album.artist
		self.button.isEnabled = UIApplication.shared.canOpenURL(album.location)
		self.genreLabel.text = album.genres.map({ $0.name }).joined(separator: "/")
		if let copyright = album.copyright {
			self.copyrightLabel.text = copyright
		} else {
			self.copyrightLabel.isHidden = true
		}
		if let releaseDate = album.releaseDate {
			self.releaseDateLabel.text = Album.dateFormatter.string(from: releaseDate)
		} else {
			self.releaseDateLabel.isHidden = true
		}
	}

	override func loadView() {
		// Artwork View
		let artworkView = self.artworkView
		let activityIndicatorView = self.activityIndicatorView
		artworkView.addSubview(activityIndicatorView)
		activityIndicatorView.leadingAnchor.constraint(equalTo: artworkView.leadingAnchor).isActive = true
		activityIndicatorView.topAnchor.constraint(equalTo: artworkView.topAnchor).isActive = true
		activityIndicatorView.trailingAnchor.constraint(equalTo: artworkView.trailingAnchor).isActive = true
		activityIndicatorView.bottomAnchor.constraint(equalTo: artworkView.bottomAnchor).isActive = true

		// Stack View
		let stackView = self.stackView
		stackView.addArrangedSubview(artworkView)
		stackView.addArrangedSubview(self.albumLabel)
		stackView.addArrangedSubview(self.artistLabel)
		stackView.addArrangedSubview(self.genreLabel)
		stackView.addArrangedSubview(self.releaseDateLabel)
		stackView.addArrangedSubview(self.copyrightLabel)

		// Scroll View
		let scrollView = self.scrollView
		scrollView.addSubview(stackView)
		let button = self.button
		scrollView.addSubview(button)
		stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
		stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		let views = [
			"stackView": stackView,
			"button": button
		]
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]-[button]-20-|", options: [], metrics: nil, views: views))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[button]-20-|", options: [], metrics: nil, views: views))

		// View
		let view = UIView()
		self.view = view
		view.backgroundColor = .systemBackground
		view.addSubview(scrollView)
		scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	@IBAction private func open(_ sender: Any) {
		UIApplication.shared.open(self.album.location)
	}
}
