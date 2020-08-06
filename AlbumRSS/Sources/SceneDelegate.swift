//
//  SceneDelegate.swift
//  AlbumRSS
//
//  Created by Iurii Skoliar on 8/6/20.
//  Copyright © 2020 Iurii Skoliar. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else {
			return
		}

		let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
		self.window = window
		let listViewController = AlbumTableViewController()
		window.rootViewController = UINavigationController(rootViewController: listViewController)
		window.windowScene = windowScene
		window.makeKeyAndVisible()
	}
}
