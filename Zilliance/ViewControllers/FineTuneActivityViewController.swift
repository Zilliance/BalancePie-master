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

final class FineTuneItemCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //rounded image
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
    }
    
}

final class FineTuneActivityViewController: UIViewController {
    
    @IBOutlet weak var vcContainerView: UIView!
    @IBOutlet weak var scheduleButton: UIButton!
    
    fileprivate var currentViewController: UIViewController?
    
    var items: [FineTuneItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scheduleButton.layer.cornerRadius = App.Appearance.zillianceCornerRadius
        self.scheduleButton.layer.borderWidth = App.Appearance.zillianceBorderWidth
        self.scheduleButton.layer.borderColor = UIColor.lightGray.cgColor
        
        showViewController(controller: items[0].viewController)
        
        navigationController?.isNavigationBarHidden = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func scheduleButtonTapped(_ sender: Any) {
        
        guard let calendarViewController = UIStoryboard.init(name: "Calendar", bundle: nil).instantiateInitialViewController() else {
            assertionFailure()
            return
        }
        calendarViewController.modalPresentationStyle = .overCurrentContext
        self.present(calendarViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    fileprivate func showViewController(controller: UIViewController)
    {
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


