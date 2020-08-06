//
//  AlbumTests.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import Combine
import XCTest
@testable import AlbumRSS

class AlbumTests: XCTestCase {
	func testDecode() throws {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(Album.dateFormatter)
		let bundle = Bundle(for: type(of: self))
		let dataURL = try XCTUnwrap(bundle.url(forResource: "explicit", withExtension: "json"))
		let data = try Data(contentsOf: dataURL)
		let rss: AlbumRSS = try decoder.decode(AlbumRSS.self, from: data)
		let feed = rss.feed
		XCTAssertNotNil(feed.title)
		let albums = feed.albums
		XCTAssertEqual(albums.count, 1)
		let album = albums[0]
		XCTAssertNotNil(album.artist)
		XCTAssertNotNil(album.artworkURL)
		XCTAssertNotNil(album.copyright)
		XCTAssertNotNil(album.genre)
		let genres = album.genres
		XCTAssertEqual(genres.count, 2)
		XCTAssertNotNil(genres[0].name)
		XCTAssertNotNil(genres[1].name)
		XCTAssertNotNil(album.location)
		XCTAssertNotNil(album.name)
		XCTAssertNotNil(album.releaseDate)
	}
}
