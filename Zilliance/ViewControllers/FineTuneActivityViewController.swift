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
    let viewController: UIViewController
    let type : FineTuneType
}

enum FineTuneType {
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
    static var pleasure: FineTuneItem = FineTuneItem(title: "Pleasure", image: UIImage(named: "fine-tune-pleasure")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "pleasure"), type : .pleasure)
    
    static let prioritize = FineTuneItem(title: "Prioritize", image: UIImage(named: "fine-tune-prioritize")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "prioritize"), type : .prioritize)
    
    static var gratitude: FineTuneItem = FineTuneItem(title: "Gratitude", image: UIImage(named: "fine-tune-gratitude")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "gratitude"), type : .gratitude)
    
    static let giving = FineTuneItem(title: "Giving", image: UIImage(named: "fine-tune-giving")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "giving"), type : .giving)
    
    static let values = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "values"), type : .values)
    
    static let replace = FineTuneItem(title: "Replace", image: UIImage(named: "fine-tune-replace")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "replace"), type : .replace)
    
    static let reduce = FineTuneItem(title: "Reduce", image: UIImage(named: "fine-tune-reduce")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "reduce"), type : .reduce)
    
    static let shift = FineTuneItem(title: "Shift", image: UIImage(named: "fine-tune-shift")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "shift"), type : .shift)
    
    static let need = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "need"), type : .need)
    
    static let valuesNeutral = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "valuesneutral"), type : .values)
    
    static let reduceMixed = FineTuneItem(title: "Reduce", image: UIImage(named: "fine-tune-reduce")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "reducemixed"), type : .reduce)
    
    static var gratitudeMixed: FineTuneItem = FineTuneItem(title: "Gratitude", image: UIImage(named: "fine-tune-gratitude")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "gratitudemixed"), type : .gratitude)
    
    static let shiftMixed = FineTuneItem(title: "Shift", image: UIImage(named: "fine-tune-shift")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "shiftmixed"), type : .shift)
    
    static let valuesMixed = FineTuneItem(title: "Values", image: UIImage(named: "fine-tune-values")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "valuesmixed"), type : .values)
    
    static let needMixed = FineTuneItem(title: "Need", image: UIImage(named: "fine-tune-need")!.tinted(color: .darkBlueBackground), viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "needmixed"), type : .need)
    
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
            return [.pleasure, .prioritize, .gratitude, .giving, .values]
        case .lousy:
            return [.shift, .valuesNeutral, .replace, .need, .reduce]
        case .neutral:
            return [.replace, .reduce, .shift, .valuesNeutral, . need]
        case .mixed:
            return [.reduceMixed, .gratitudeMixed, .shiftMixed, .valuesMixed, .needMixed]
        default:
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
        let scheduler = UIStoryboard(name: "Calendar", bundle: nil).instantiateInitialViewController() as! AddToCalendarViewController
        scheduler.textViewContent = TextViewContent(userActivity: self.zUserActivity!, type: self.items[self.currentIndex].type)
        self.navigationController!.pushViewController(scheduler, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    fileprivate func showViewController(controller: UIViewController) {
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
        return CGSize(width: collectionView.bounds.size.width / CGFloat(self.items.count), height: 84)
    }
    
}



