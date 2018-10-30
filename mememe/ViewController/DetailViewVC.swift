//
//  DetailViewVC.swift
//  mememe
//
//  Created by Peter Pohlmann on 30.10.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class DetailViewVC: UIViewController {

    var memeImageDelegate = UIImage()
    @IBOutlet weak var memeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    func setup(){
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        memeImage.image = memeImageDelegate
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
