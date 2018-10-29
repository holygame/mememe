//
//  SentMemesVC.swift
//  mememe
//
//  Created by Peter Pohlmann on 24.10.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class SentMemesTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createMeme(_ sender: Any) {
        let createMemeVC = storyboard!.instantiateViewController(withIdentifier: "CreateMemeVC") as! CreateMemeVC
        self.navigationController?.pushViewController(createMemeVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //store memes in user defaults
        //let userDefault = UserDefaults.standard
        //userDefault.set([Meme](), forKey: "memes")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()

        print("memes from table")
        print(memes)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell")!
        if let meme = memes[(indexPath as IndexPath).row] as Meme? {
             cell.textLabel?.text  = meme.topText
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
