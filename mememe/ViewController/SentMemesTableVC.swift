//
//  SentMemesVC.swift
//  mememe
//
//  Created by Peter Pohlmann on 24.10.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit


class SentMemeTableViewCell: UITableViewCell{
    @IBOutlet weak var cellLabelTop: UILabel!
    @IBOutlet weak var cellLabelBottom: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
}

class SentMemesTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var memes: [Meme]! {
        print("GET MEME VAR")
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        //appDelegate.memes.reverse()
        return appDelegate.memes
    }
    
    var allMemes = [Meme]()
    var scrollToTop = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createMeme(_ sender: Any) {
        let createMemeVC = storyboard!.instantiateViewController(withIdentifier: "CreateMemeVC") as! CreateMemeVC
        createMemeVC.unwindIdentifier = "SentMemesTableVC"
        self.navigationController?.pushViewController(createMemeVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("DID LOAD")
        testMemes()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        print("WILL APPEAR")
        setup()
    }

    func setup(){
        allMemes = memes
        allMemes.reverse()
        self.tableView.reloadData()
        scrollToFirstRow()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.tableView.backgroundColor = UIColor.darkGray
    }
    
    func scrollToFirstRow() {
        if scrollToTop {
            print("scrolltotop")
            self.tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            scrollToTop = false 
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell") as! SentMemeTableViewCell
        if let meme = allMemes[(indexPath as IndexPath).row] as Meme? {
            cell.cellLabelTop.text  = meme.topText
            cell.cellLabelBottom.text = meme.bottomText
            cell.cellImage.image = meme.memImage
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            allMemes.remove(at: (indexPath as IndexPath).row)
            
            //save allMemes to appDelegate
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes = allMemes
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let meme = allMemes[(indexPath as IndexPath).row] as Meme? {
            let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailView") as! DetailViewVC
            detailVC.meme = meme
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.black
    }
    
    func testMemes(){
        
        let testMemes: [Meme] = [
            Meme(topText: "s asdf asf asfd asdf dfg dgf dfg dfgd ddg sdgas", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "1.jpg")!, memImage:  UIImage(named: "1.jpg")!),
            Meme(topText: "s asdf asf asfd df dfg dfg dfg asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "2.jpg")!, memImage:  UIImage(named: "2.jpg")!),
           // Meme(topText: "s asdf asf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "3.jpg")!, memImage:  UIImage(named: "3.jpg")!),
           // Meme(topText: "s asdf as eryerf asfd asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "4.jpg")!, memImage:  UIImage(named: "4.jpg")!),
           //Meme(topText: "s asdf asweyerf asfd adfgd dfg dfsdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "5.jpg")!, memImage:  UIImage(named: "5.jpg")!),
           // Meme(topText: "s asdf asf asfdfg d df dfg d asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "6.jpg")!, memImage:  UIImage(named: "6.jpg")!),
           // Meme(topText: "s asdf asf asfd asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "7.jpg")!, memImage:  UIImage(named: "7.jpg")!),
           // Meme(topText: "s asdf asf asdfg d dfd asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "8.jpg")!, memImage:  UIImage(named: "8.jpg")!),
           // Meme(topText: "s asdf asf asfd adfg dg dfsdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "9.jpg")!, memImage:  UIImage(named: "9.jpg")!),
           // Meme(topText: "s asdf asfsd sdfgs d asfd asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "10.jpg")!, memImage:  UIImage(named: "10.jpg")!),
           // Meme(topText: "s asdf asf asfd asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "11.jpg")!, memImage:  UIImage(named: "11.jpg")!),
           // Meme(topText: "s asdf asf asfd asdf as", bottomText: "asdf asdf asdf asf", originalImage: UIImage(named: "12.jpg")!, memImage:  UIImage(named: "12.jpg")!)
        ]
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes = testMemes
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
