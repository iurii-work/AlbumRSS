//
//  AlbumTableViewController.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import Combine
import UIKit

class AlbumTableViewController: UITableViewController {
	private var albums: [Album]?
	private var cancellable: AnyCancellable?

	override func loadView() {
		super.loadView()

		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(reloadAlbums(_:)), for: .valueChanged)
		self.refreshControl = refreshControl
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.refreshControl?.beginRefreshing()
		self.reloadAlbums(self)
	}
}

extension AlbumTableViewController {
	func present(error: Error, retryHandler: @escaping () -> Void) {
		let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in retryHandler() }))
		self.present(alertController, animated: true, completion: nil)
	}

	@IBAction private func reloadAlbums(_ sender: Any) {
		let albumRSSURL = URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json")!
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(Album.dateFormatter)
		self.cancellable = URLSession.shared.dataTaskPublisher(for: albumRSSURL)
			.compactMap({ (data, response) -> Data? in
				guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
					return nil
				}

				guard let mime = response.mimeType, mime == "application/json" else {
					return nil
				}

				return data
			})
			.catch { (error) -> Just<Data?> in
				DispatchQueue.main.async { self.present(error: error) { self.reloadAlbums(self) } }
				return Just(nil)
			}
			.compactMap { (data) -> Data? in data }
			.decode(type: AlbumRSS.self, decoder: decoder)
			.compactMap { (albumRSS) -> AlbumRSS? in albumRSS }
			.receive(on: RunLoop.main)
			.catch { (error) -> Just<AlbumRSS?> in
				self.present(error: error) { self.reloadAlbums(self) }
				return Just(nil)
			}
			.compactMap { (albumRSS) -> AlbumRSS? in albumRSS }
			.sink { (albumRSS) in
				let feed = albumRSS.feed
				self.title = feed.title
				self.albums = feed.albums
				self.tableView.reloadData()
				self.refreshControl?.endRefreshing()
			}
	}
}

extension AlbumTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let album = self.albums?[indexPath.row] {
			let albumViewController = AlbumViewController(album: album)
			self.navigationController?.pushViewController(albumViewController, animated: true)
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.albums?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = String(describing: AlbumCell.self)
		var albumCell: AlbumCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? AlbumCell
		if albumCell == nil {
			albumCell = AlbumCell(style: .subtitle, reuseIdentifier: identifier)
		}
		if let album = self.albums?[indexPath.row] {
			albumCell.configure(with: album)
		}
		return albumCell
	}
}
