//
//  ViewController.swift
//  PhotoGallery
//
//  Created by Admin on 17/06/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    

    var myCollectionView: UICollectionView!
    private var reddits: [SubRedditData] = []
    private var urls: [String] = []
    private var imageViewsArray : [UIImageView] = []



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.myCollectionView.reloadData()
        


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Photos"
        let searchController = UISearchController(searchResultsController: nil) // Search Controller

        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self;
        searchController.searchResultsUpdater = self;
        searchController.searchBar.delegate = self;
        searchController.becomeFirstResponder()
        self.navigationItem.searchController = searchController;



        
        let layout = UICollectionViewFlowLayout()
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(myCollectionView)
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        grabPhotos()


    }
    
    
    override var prefersStatusBarHidden: Bool { return true }

    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageViewsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        let image = imageViewsArray[indexPath.item].image
        if (image == nil) {
            let placeholder = #imageLiteral(resourceName: "placeholder.png")
            cell.img.image = placeholder
            return cell
        }
        cell.img.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Image" + String(indexPath.row + 1))
        let vc=ImageDetail()
        vc.imgArray = self.imageViewsArray
        vc.passedContentOffset = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
   
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //MARK: grab photos
    func grabPhotos(){
        imageViewsArray = []
        NetworkingService.shared.getReddits { [weak self] (response) in
                 
                 self?.reddits = response.data.children
                 DispatchQueue.main.async {
                     //print (self!.reddits)
                        for (index, red) in self!.reddits.enumerated() {
                            let imageURL = "\(red.data.url)"
                            self!.urls.append(imageURL)
                            let downloadImage = UIImageView()
                            downloadImage.loadImageUsingCache(withUrl: self!.urls[index])
                            self!.imageViewsArray.append(downloadImage)
                        }
                    //self?.myCollectionView.reloadData()
                 }
             DispatchQueue.main.async {

            self?.myCollectionView.reloadData()
            }

        }
    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func updateSearchResults(for searchController: UISearchController) {
        guard let text = self.navigationItem.searchController?.searchBar.text else { return }
        print("Change Search Test")
        
    }
    


    class PhotoItemCell: UICollectionViewCell {
        
        var img = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            img.contentMode = .scaleAspectFill
            img.clipsToBounds=true
            self.addSubview(img)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            img.frame = self.bounds
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    struct DeviceInfo {
        struct Orientation {
            // indicate current device is in the LandScape orientation
            static var isLandscape: Bool {
                get {
                    return UIDevice.current.orientation.isValidInterfaceOrientation
                        ? UIDevice.current.orientation.isLandscape
                        : UIApplication.shared.statusBarOrientation.isLandscape
                }
            }
            // indicate current device is in the Portrait orientation
            static var isPortrait: Bool {
                get {
                    return UIDevice.current.orientation.isValidInterfaceOrientation
                        ? UIDevice.current.orientation.isPortrait
                        : UIApplication.shared.statusBarOrientation.isPortrait
                }
            }
        }
    }
}
