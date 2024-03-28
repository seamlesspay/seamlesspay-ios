// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let _ = (scene as? UIWindowScene) else { return }

    guard let splitViewController = window?.rootViewController as? UISplitViewController,
          let navigationController =
          splitViewController.viewControllers.last as? UINavigationController else {
      return
    }

    navigationController.topViewController?.navigationItem.leftBarButtonItem =
      splitViewController.displayModeButtonItem
    navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true

    splitViewController.delegate = self
  }

  func splitViewController(
    _ splitViewController: UISplitViewController,
    collapseSecondary secondaryViewController: UIViewController,
    onto primaryViewController: UIViewController
  ) -> Bool {
    if let secondaryNavVC = secondaryViewController as? UINavigationController,
       let topVC = secondaryNavVC.topViewController as? DetailViewController,
       topVC.detailItem == nil {
      // Return true to indicate that we have handled the collapse by doing
      // nothing; the secondary controller will be discarded.
      return true
    } else {
      return false
    }
  }
}
