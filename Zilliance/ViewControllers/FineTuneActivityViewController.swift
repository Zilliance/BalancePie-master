//
//  FineTuneActivityViewController.swift
//  Zilliance
//
//  Created by Ignacio Zunino on 06-04-17.
//  Copyright © 2017 Pillars4Life. All rights reserved.
//

import UIKit

struct FineTuneItem {
    let title: String
    let image: UIImage
    let viewController: FineTuneItemViewController
    let type : FineTuneType
}

enum FineTuneType: String {
    case pleasure
    case prioritize
    case gratitude
    case giving
    case values
    case replace
    case reduce
    case shift
    case need
}

extension FineTuneItem {
    
    // Great
    
    static var greatPleasure: FineTuneItem = {
        let item = FineTuneItem(title: "Pleasure", image: UIImage(named: "fine-tune-pleasure")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-pleasure") as! FineTuneItemViewController, type : .pleasure)
        item.viewController.item = item
        return item
    }()
    
    static let greatPrioritize: FineTuneItem = {
        let item = FineTuneItem(title: "Prioritize", image: UIImage(named: "fine-tune-prioritize")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-prioritize") as! FineTuneItemViewController, type : .prioritize)
        item.viewController.item = item
        return item
    }()
    
    static var greatGratitude: FineTuneItem = {
        let item = FineTuneItem(title: "Gratitude", image: UIImage(named: "fine-tune-gratitude")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-gratitude") as! FineTuneItemViewController, type : .gratitude)
        item.viewController.item = item
        return item
    }()
    
    static let greatGiving: FineTuneItem = {
        let item = FineTuneItem(title: "Giving", image: UIImage(named: "fine-tune-giving")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-giving") as! FineTuneItemViewController, type : .giving)
        item.viewController.item = item
        return item
    }()
    
    static let greatValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "great-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
    
    // Good
    
    static let goodGratitude: FineTuneItem = {
        let item = FineTuneItem(title: "Gratitude", image: UIImage(named: "fine-tune-gratitude")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-gratitude") as! FineTuneItemViewController, type : .gratitude)
        item.viewController.item = item
        return item
    }()
    
    static let goodPleasure: FineTuneItem = {
        let item = FineTuneItem(title: "Pleasure", image: UIImage(named: "fine-tune-pleasure")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-pleasure") as! FineTuneItemViewController, type : .pleasure)
        item.viewController.item = item
        return item
    }()
    
    static let goodPrioritize: FineTuneItem = {
        let item = FineTuneItem(title: "Prioritize", image: UIImage(named: "fine-tune-prioritize")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-prioritize") as! FineTuneItemViewController, type : .prioritize)
        item.viewController.item = item
        return item
    }()
    
    static let goodNeed: FineTuneItem = {
        let item = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-need") as! FineTuneItemViewController, type : .need)
        item.viewController.item = item
        return item
    }()
    
    static let goodValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "good-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
    
    // Mixed
    
    static var mixedReplace: FineTuneItem = {
        let item = FineTuneItem(title: "Replace", image: UIImage(named: "fine-tune-replace")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-replace") as! FineTuneItemViewController, type : .replace)
        item.viewController.item = item
        return item
    }()
    
    static let mixedReduce: FineTuneItem = {
        let item = FineTuneItem(title: "Reduce", image: UIImage(named: "fine-tune-reduce")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-reduce") as! FineTuneItemViewController, type : .reduce)
        item.viewController.item = item
        return item
    }()
    
    static let mixedShift: FineTuneItem = {
        let item = FineTuneItem(title: "Shift", image: UIImage(named: "fine-tune-shift")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-shift") as! FineTuneItemViewController, type : .shift)
        item.viewController.item = item
        return item
    }()
    
    static let mixedValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
    
    static let mixedNeed: FineTuneItem = {
        let item = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "mixed-need") as! FineTuneItemViewController, type : .need)
        item.viewController.item = item
        return item
    }()
    
    // Lousy
    
    static let lousyReplace: FineTuneItem = {
        let item = FineTuneItem(title: "Replace", image: UIImage(named: "fine-tune-replace")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-replace") as! FineTuneItemViewController, type : .replace)
        item.viewController.item = item
        return item
    }()
    
    static let lousyReduce: FineTuneItem = {
        let item = FineTuneItem(title: "Reduce", image: UIImage(named: "fine-tune-reduce")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-reduce") as! FineTuneItemViewController, type : .reduce)
        item.viewController.item = item
        return item
    }()
    
    static let lousyShift: FineTuneItem = {
        let item = FineTuneItem(title: "Shift", image: UIImage(named: "fine-tune-shift")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-shift") as! FineTuneItemViewController, type : .shift)
        item.viewController.item = item
        return item
    }()
    
    static let lousyNeed: FineTuneItem = {
        let item = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-need") as! FineTuneItemViewController, type : .need)
        item.viewController.item = item
        return item
    }()
    
    static let lousyValues: FineTuneItem = {
        let item = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "lousy-values") as! FineTuneItemViewController, type : .values)
        item.viewController.item = item
        return item
    }()
}

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



