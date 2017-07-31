//
//  FineTuneActivityViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 06-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

// MARK: -

final class FineTuneItemCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //rounded image
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        
        if UIDevice.isSmallerThaniPhone6 {
            label.font = UIFont.muliRegular(size: 12)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            //self.contentView.backgroundColor = isSelected ? UIColor.lightBlueBackground : UIColor.clear
            self.imageView.image = self.imageView.image?.tinted(color: isSelected ? .lightBlueBackground : .darkBlueBackground)
            self.label.textColor = isSelected ? .lightBlueBackground : .darkBlueBackground
        }
    }
    
    var image: UIImage? {
        didSet {
            if let image = image {
                self.imageView.image = image.tinted(color: isSelected ? .lightBlueBackground : .darkBlueBackground)
            } else {
                self.imageView.image = nil
            }
        }
    }
    
}

// MARK: -

final class FineTuneActivityViewController: UIViewController {
    
    @IBOutlet weak var vcContainerView: UIView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var currentViewController: UIViewController?
    fileprivate var items: [FineTuneItem]!
    fileprivate var currentIndex = 0
    
    fileprivate var takeActionHint: OnboardingPopover?
    
    private func fineTuneItems(for feeling: Feeling) -> [FineTuneItem] {
        switch feeling {
        case .great:
            return [
                .greatPleasure,
                .greatPrioritize,
                .greatGratitude,
                .greatGiving,
                .greatValues
            ]
        case .lousy:
            return [
                .lousyShift,
                .lousyValues,
                .lousyReplace,
                .lousyNeed,
                .lousyReduce
            ]
        case .good:
            return [
                .goodNeed,
                .goodGratitude,
                .goodValues,
                .goodPleasure,
                .goodPrioritize,
            ]
        case .mixed:
            return [
                .mixedReplace,
                .mixedReduce,
                .mixedShift,
                .mixedValues,
                .mixedNeed
            ]
        case .none:
            return []
        }
    }
    
    var zUserActivity: UserActivity? {
        didSet {
            self.title = zUserActivity?.activity?.name ?? ""
            self.items = self.fineTuneItems(for: (zUserActivity?.feeling)!)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scheduleButton.layer.cornerRadius = App.Appearance.buttonCornerRadius
        self.scheduleButton.layer.borderWidth = App.Appearance.borderWidth
        self.scheduleButton.layer.borderColor = UIColor.lightGray.cgColor
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        self.showViewController(controller: items[0].viewController)
        
        // pre select first position
        self.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showTakeActionHint()
    }
    
    // MARK: - User Actions
    

    @IBAction func scheduleButtonTapped(_ sender: Any) {
//        let scheduler = UIStoryboard(name: "Calendar", bundle: nil).instantiateInitialViewController() as! AddToCalendarViewController
//        scheduler.textViewContent = TextViewContent(userActivity: self.zUserActivity!, type: self.items[self.currentIndex].type)
        
        guard let scheduler = UIStoryboard(name: "Schedule", bundle: nil).instantiateInitialViewController() as? ScheduleViewController else {
            assertionFailure()
            return
        }

        scheduler.textViewContent = TextViewContent(userActivity: self.zUserActivity!, type: self.items[self.currentIndex].type)
        self.navigationController!.pushViewController(scheduler, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    fileprivate func showViewController(controller: FineTuneItemViewController) {
        if (currentViewController != nil)
        {
            currentViewController?.willMove(toParentViewController: nil)
            currentViewController?.view.removeFromSuperview()
            currentViewController?.didMove(toParentViewController: nil)
        }
        
        controller.willMove(toParentViewController: self)
        self.vcContainerView.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.vcContainerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.vcContainerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.vcContainerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.vcContainerView.bottomAnchor)
            ])
        
        controller.didMove(toParentViewController: self)
        
        currentViewController = controller
        
        // Ensure the view controller has access to the user activity
        controller.zUserActivity = self.zUserActivity
    }

    // MARK: - Hints
    
    fileprivate func showTakeActionHint() {
        guard !UserDefaults.standard.bool(forKey: "TakeActionHintShown") else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let ss = self, ss.view.window != nil else {
                return
            }
            guard ss.takeActionHint == nil else {
                return
            }
            
            var location = ss.scheduleButton.center
            location.y -= 40
            
            ss.takeActionHint = OnboardingPopover()
            
            ss.takeActionHint?.title = "Tap \"Take action\" to improve your life, one step at a time. Schedule reminders and/or notifications that will help you solidify habits over time."
            ss.takeActionHint?.hasShadow = true
            ss.takeActionHint?.shadowColor = UIColor(white: 0, alpha: 0.4)
            ss.takeActionHint?.arrowLocation = .centeredOnTarget
            ss.takeActionHint?.present(in: ss.view, at: location, from: .above)
            ss.takeActionHint?.delegate = self
            
            UserDefaults.standard.set(true, forKey: "TakeActionHintShown")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.dismissTakeActionHint()
            }
        }
    }
    
    fileprivate func dismissTakeActionHint() {
        self.takeActionHint?.dismiss()
        self.takeActionHint = nil
    }
}

// MARK: - Onboarding Popover Delegate

extension FineTuneActivityViewController: OnboardingPopoverDelegate {
    func didTap(popover: OnboardingPopover) {
        if popover == self.takeActionHint {
            self.dismissTakeActionHint()
        }
    }
}

extension FineTuneActivityViewController: UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fineTuneItemCell", for: indexPath) as! FineTuneItemCell
        let item = self.items[indexPath.row]
        
        cell.label.text = item.title
        cell.image = item.image
        
        return cell
    }
}


extension FineTuneActivityViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    
        //change view controller.
        let newViewController = self.items[indexPath.row].viewController
        
        if (newViewController != currentViewController)
        {
            self.showViewController(controller: newViewController)
        }
        
        self.currentIndex = indexPath.row
    }
    
}

extension FineTuneActivityViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemRatio = UIDevice.isSmallerThaniPhone6 ? self.items.count + 1 : self.items.count
        return CGSize(width: collectionView.bounds.size.width / CGFloat(itemRatio) , height: 84)
    }
    
}



