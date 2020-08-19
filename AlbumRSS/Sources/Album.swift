//
//  Album.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import Combine
import Foundation

struct Album: Decodable {
	let artist: String
	let artworkURL: URL
	let copyright: String?
	let genres: [Genre]
	let location: URL
	let name: String
	let releaseDate: Date?

	enum CodingKeys: String, CodingKey {
		case artist = "artistName"
		case artworkURL = "artworkUrl100"
		case copyright
		case genres
		case location = "url"
		case name
		case releaseDate
	}
}

extension Album {
	static var dateFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}
}

struct Genre: Decodable {
	let name: String
}

struct AlbumRSS: Decodable {
	let feed: Feed
}

struct Feed: Decodable {
	let title: String
	let albums: [Album]

	enum CodingKeys: String, CodingKey {
		case albums = "results"
		case title
	}
}
