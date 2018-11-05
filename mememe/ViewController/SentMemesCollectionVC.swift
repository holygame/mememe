//
//  SentMemesCollectionViewController.swift
//  mememe
//
//  Created by Peter Pohlmann on 04.11.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class SentMemesCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: Vars, IBOutlets, IBActions
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    var allMemes = [Meme]()
    var scrollToTop = false
    let reuseIdentifier = "Cell"
    var orientation = UIDevice.current.orientation
    var lastOrientation = UIDevice.current.orientation
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBAction func createMeme(_ sender: Any) {
        let createMemeVC = storyboard!.instantiateViewController(withIdentifier: "CreateMemeVC") as! CreateMemeVC
        createMemeVC.unwindIdentifier = "SentMemesCollectionVC"
        self.navigationController?.pushViewController(createMemeVC, animated: true)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.darkGray
        
        // Register cell classes
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeNotification()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK : Functions
    func setup(){
        subscribeToNotification()
        setFlowLayout(orientation: UIDevice.current.orientation)
        allMemes = memes
        allMemes.reverse()

        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.collectionView?.reloadData()
    }
    
    func subscribeToNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        orientation = UIDevice.current.orientation
        setFlowLayout(orientation: UIDevice.current.orientation)
    }
    
    func setFlowLayout(orientation: UIDeviceOrientation){
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let space:CGFloat = 1
        let horizontalDevider = width > 810 ? CGFloat(4.5) : CGFloat(4.0) //iphone 7.. or iphone x..
        
        if(orientation.isLandscape == true || lastOrientation.isLandscape && orientation.isFlat && true){
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.itemSize = CGSize(width: width / horizontalDevider, height: width / 5.5)
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
        }
        else{
            let dimensionWidth = (width - (2 * space)) / 3.0
            let dimensionHeight = (height - (2 * space)) / 5.0
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSize(width: dimensionWidth, height: dimensionHeight)
        }
        
         lastOrientation = UIDevice.current.orientation
    }

    // MARK: Collection View Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMemes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! SentMemeCollectionCellVC
        if let meme = allMemes[(indexPath as IndexPath).row] as Meme? {
            cell.collectionImage.image = meme.memImage
            cell.layer.borderWidth = CGFloat(0.5)
            cell.layer.borderColor = UIColor(red: 50.0/255, green: 52.0/255, blue: 54.0/255, alpha: 1.0).cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let meme = allMemes[(indexPath as IndexPath).row] as Meme? {
            let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailView") as! DetailViewVC
            detailVC.meme = meme
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
