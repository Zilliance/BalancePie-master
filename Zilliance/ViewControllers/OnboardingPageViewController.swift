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
        case fourth
        case fifth
        case sixth
    }
    
    enum OnboardingPresentationMode {
        case firstTime
        case fromFaq
        case fromMenu
    }
    
    fileprivate(set) lazy var introViewControllers: [UIViewController]  = {
        
        var viewControllers: [UIViewController] = [
            self.viewController(for: .first),
            self.viewController(for: .second),
            self.viewController(for: .third),
            self.viewController(for: .fourth),
            self.viewController(for: .fifth),
            self.viewController(for: .sixth),
            ]
        
        if self.presentationType == .firstTime {
            viewControllers.append(self.favoriteViewController)
        }
        return viewControllers
        
    }()

    fileprivate lazy var favoriteViewController: UIViewController = {
        return UIStoryboard(name: "FavoriteActivity", bundle: nil).instantiateInitialViewController()
    }()!
    
    fileprivate var shouldHideDots = false
    
    var presentationType: OnboardingPresentationMode = .firstTime
    
    private let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "launch-background"))
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.shared.send(event: BalancePieAnalytics.BalancePieEvent.enterTour)
        
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
        
        if self.presentationType == .fromFaq {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeView))
        }
        else if self.presentationType == .fromMenu {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "drawer-toolbar-icon"), style: .plain, target: self, action: #selector(backTapped))
        }
        
        self.view.backgroundColor = .lightBlueBackground
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.insertSubview(self.backgroundImageView, at: 0)
        
        
        self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.backgroundImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.backgroundImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.dataSource = self
        self.delegate = self
        if let firstViewController = self.introViewControllers.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    private func viewController(for scene: OnboardingScene) -> UIViewController {
        
        return UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier:scene.rawValue)
    
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backTapped() {
        self.sideMenuController?.toggle()
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
