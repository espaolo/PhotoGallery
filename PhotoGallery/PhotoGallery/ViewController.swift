//
//  ViewController.swift
//  PhotoGallery
//
//  Created by Admin on 17/06/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var myCollectionView: UICollectionView!
    private var reddits: [SubRedditData] = []
    private var urls: [String] = []
    private var imageViewsArray : [UIImageView] = []
    private var imageTitle : [String] = []
    private var timer = Timer()
    let searchController = UISearchController(searchResultsController: nil)



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        DispatchQueue.main.async {
        self.myCollectionView.reloadData()
        }
    }
    
    
    override open var shouldAutorotate: Bool {
        return false
    }

    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        //Notification handler for new datasource
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReloadNotification(notification:)), name: Notification.Name("RELOAD"), object: nil)

        //self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Photos"
        self.view.backgroundColor = .white
        
        // Label for empty collection
        let noPhotos = UILabel()
        noPhotos.frame = CGRect(x: 100, y: 100, width: 300, height: 80)
        noPhotos.textAlignment = .center
        noPhotos.text = "No pics"
        noPhotos.textColor = .black
        noPhotos.center = self.view.center
        noPhotos.font = noPhotos.font.withSize(50)
        self.view.addSubview(noPhotos)
        self.view.bringSubviewToFront(noPhotos)
        
        // Search Controller properties
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self;
        searchController.searchResultsUpdater = self;
        searchController.searchBar.delegate = self;
        searchController.becomeFirstResponder()
        self.navigationItem.searchController = searchController;

        // CollectionView layout and properties
        let layout = UICollectionViewFlowLayout()
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        if (self.imageViewsArray.count == 0){
            myCollectionView.isHidden = true
        }
        else {
            self.view.addSubview(myCollectionView)
        }
    }
    
    override var prefersStatusBarHidden: Bool { return true }

    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageViewsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        let image = imageViewsArray[indexPath.item].image
        if (image == nil) {
            let placeholder = #imageLiteral(resourceName: "placeholder.png")
            cell.img.image = placeholder
            return cell
        }
        cell.img.image = image
        return cell
    }
    
    //MARK: Push photo detail
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Image" + String(indexPath.row + 1))
        let vc=ImageDetail()
        vc.imgArray = self.imageViewsArray
        vc.infoArray = self.imageTitle
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
    
    
    @objc func methodOfReloadNotification(notification: Notification) {
        self.searchController.searchBar.isLoading = true
        self.myCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.searchController.searchBar.isLoading = false
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
    
    //MARK: Grab Photos async
    func grabPhotos(){
        self.view.addSubview(myCollectionView)
        myCollectionView.isHidden = false
        urls = []
        imageViewsArray = []
        imageTitle = []
        NetworkingService.shared.getReddits { [weak self] (response) in
                 self?.reddits = response.data.children
                 DispatchQueue.main.async {
                     //print (self!.reddits)
                        for (index, red) in self!.reddits.enumerated() {
                            let imageURL = "\(red.data.url)"
                            let imageTitle = "\(red.data.title)"
                            self!.urls.append(imageURL)
                            if (imageURL.hasSuffix("jpg") || imageURL.hasSuffix("png")) {
                            let downloadImage = UIImageView()
                            downloadImage.loadImageUsingCache(withUrl: self!.urls[index])
                            self!.imageViewsArray.append(downloadImage)
                            self!.imageTitle.append(imageTitle)
                            }
                        }
                 }
        }
        // Search for emtpy collection to show NoPhotos label
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.searchController.searchBar.isLoading = false
        self.checkEmptyImages()
        }
    }

    func checkEmptyImages(){
        if (self.imageViewsArray.count == 0){
            self.myCollectionView.isHidden = true
            self.searchController.searchBar.isLoading = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // Remove Observer subscription
        NotificationCenter.default.removeObserver(self, name: Notification.Name("RELOAD"), object: nil)
    }


    //MARK: SearchBar delegates
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = self.navigationItem.searchController?.searchBar.text else { return }
        print("User is writing in searchBar")
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ViewController.reload), userInfo: text, repeats: false)

    }
    
    // Reload function for Search Bar new text
    @objc func reload() {
        guard let searchText = self.navigationItem.searchController?.searchBar.text else { return }
        if (searchText != NetworkingService.shared.searchKey && searchText != ""){
        NetworkingService.shared.searchKey = searchText
        grabPhotos()
        self.myCollectionView.reloadData()
        self.searchController.isActive = false
        self.searchController.searchBar.endEditing(true)
        self.searchController.searchBar.isLoading = true
        if timer.userInfo != nil {
            print("User Stopped Writing")
        }
        timer.invalidate()
        }
    }
    
    //MARK: Collection View Cell
    class PhotoCell: UICollectionViewCell {
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
            // Indicate current device is in the LandScape orientation
            static var isLandscape: Bool {
                return UIApplication.shared.windows
                    .first?
                    .windowScene?
                    .interfaceOrientation
                    .isLandscape ?? false
            }
            // Indicate current device is in the Portrait orientation
            static var isPortrait: Bool {
                return UIApplication.shared.windows
                    .first?
                    .windowScene?
                    .interfaceOrientation
                    .isPortrait ?? false
            }
        }
    }
}
