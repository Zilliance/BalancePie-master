//
//  OnboardingPageViewController.swift
//  Zilliance
//
//  Created by ricardo hernandez  on 4/6/17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    private enum OnboardingScene: String {
        case first
        case second
        case third
    }
    
    fileprivate(set) lazy var introViewControllers: [UIViewController]  = {
        return [
            self.viewController(for: .first),
            self.viewController(for: .second),
            self.viewController(for: .third),
            self.favoriteViewController
        ]
    }()

    fileprivate lazy var favoriteViewController: UIViewController = {
        return UIStoryboard.init(name: "FavoriteActivity", bundle: nil).instantiateInitialViewController()
    }()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    private func setupView() {
        self.dataSource = self
        if let firstViewController = self.introViewControllers.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    private func viewController(for scene: OnboardingScene) -> UIViewController {
        
        return UIStoryboard.init(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier:scene.rawValue)
    
    }
    
    
    func gotoFavoriteActivity() {
        
        guard let viewController = UIStoryboard.init(name: "FavoriteActivity", bundle: nil).instantiateInitialViewController() as? FavoriteActivityTableViewController else {
            assertionFailure()
            return
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.introViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard self.introViewControllers.count > previousIndex else {
            return nil
        }
        
        return self.introViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.introViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = self.introViewControllers.count
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return self.introViewControllers[nextIndex]
    }
    

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.introViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = self.introViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}
