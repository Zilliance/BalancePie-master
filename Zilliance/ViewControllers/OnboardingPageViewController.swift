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
        return UIStoryboard(name: "FavoriteActivity", bundle: nil).instantiateInitialViewController()
    }()!
    
    fileprivate var shouldHideDots = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // show pageview contoller full screen (remove dots gap)
        var scrollView: UIScrollView? = nil
        self.view.subviews.forEach { (view) in
            if let subview = view as? UIScrollView {
                scrollView = subview
            }
        }
        
        scrollView?.frame = self.view.bounds
        self.view.bringSubview(toFront: self.pageControl!)
    }
    
    private func setupView() {
        self.dataSource = self
        self.delegate = self
        if let firstViewController = self.introViewControllers.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    private func viewController(for scene: OnboardingScene) -> UIViewController {
        
        return UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier:scene.rawValue)
    
    }
    

}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if self.shouldHideDots == true, completed == true {
            // hide dots and remove swipe in last page
            
            UIView.animate(withDuration: 0.3, animations: { 
                self.pageControl?.alpha = 0
            }, completion: { (_) in
                self.pageControl?.isHidden = true
            })
            
            self.removeSwipeGesture()
        }
    
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        self.shouldHideDots = pendingViewControllers.first is FavoriteActivityViewController
        
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

extension UIPageViewController {
    var pageControl: UIPageControl? {
        for view in self.view.subviews {
            if view is UIPageControl {
                return view as? UIPageControl
            }
        }
        return nil
    }
    
    func removeSwipeGesture() {
        self.view.subviews.forEach { (view) in
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }
}
