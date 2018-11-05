//
//  DetailViewVC.swift
//  mememe
//
//  Created by Peter Pohlmann on 30.10.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class DetailViewVC: UIViewController {
    
    var meme: Meme!
    @IBOutlet weak var memeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func setup(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme)), animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        memeImage.image = meme.memImage
    }

    @objc func editMeme(){
        let editVC = self.storyboard!.instantiateViewController(withIdentifier: "CreateMemeVC") as! CreateMemeVC
        editVC.savedMeme = meme
        editVC.unwindIdentifier = "DetailViewVC"
        self.navigationController?.pushViewController(editVC, animated: true)
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
