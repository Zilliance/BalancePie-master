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
}

extension FineTuneItem {
    static var pleasure: FineTuneItem = FineTuneItem(title: "Pleasure", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "pleasure"))
    
    static let prioritize = FineTuneItem(title: "Prioritize", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "prioritize"))
    
    static var gratitude: FineTuneItem = FineTuneItem(title: "Gratitude", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "gratitude"))
    
    static let giving = FineTuneItem(title: "Giving", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "giving"))
    
    static let values = FineTuneItem(title: "Values", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "values"))
    
    static let replace = FineTuneItem(title: "Replace", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "replace"))
    
    static let reduce = FineTuneItem(title: "Reduce", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "reduce"))
    
    static let shift = FineTuneItem(title: "Shift", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "shift"))
    
    static let need = FineTuneItem(title: "Need", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "need"))
    
    static let valuesNeutral = FineTuneItem(title: "Values", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "valuesneutral"))
    
    static let reduceMixed = FineTuneItem(title: "Reduce", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "reducemixed"))
    
    static var gratitudeMixed: FineTuneItem = FineTuneItem(title: "Gratitude", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "gratitudemixed"))
    
    static let shiftMixed = FineTuneItem(title: "Shift", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "shiftmixed"))
    
    static let valuesMixed = FineTuneItem(title: "Values", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "valuesmixed"))
    
    static let needMixed = FineTuneItem(title: "Need", image: UIImage(named: "btnPlus")!, viewController: UIStoryboard(name: "FineTuneItems", bundle: nil).instantiateViewController(withIdentifier: "needmixed"))
    
    
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
    
}

// MARK: -

final class FineTuneActivityViewController: UIViewController {
    
    @IBOutlet weak var vcContainerView: UIView!
    @IBOutlet weak var scheduleButton: UIButton!
    
    fileprivate var currentViewController: UIViewController?
    
    fileprivate var items: [FineTuneItem]!
    
    private func fineTuneItems(for feeling: Feeling) -> [FineTuneItem] {
        switch feeling {
        case .great:
            return [.pleasure, .prioritize, .gratitude, .giving, .values]
        case .lousy:
            return [.replace, .reduce, .shift, .valuesNeutral, .need]
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
        
        // Add a cancel button when we are the root view controller in the navigation stack
        
        if self.navigationController?.viewControllers.first == self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(cancelTapped(_:)))
        }
        
        self.showViewController(controller: items[0].viewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - User Actions

    @IBAction func scheduleButtonTapped(_ sender: Any) {
        let scheduler = UIStoryboard(name: "Calendar", bundle: nil).instantiateInitialViewController()!
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
        cell.imageView.image = item.image
        
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
    }
}

extension FineTuneActivityViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width / CGFloat(self.items.count), height: 100)
    }
    
}



