//
//  ViewController.swift
//  mememe
//
//  Created by Peter Pohlmann on 15.09.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: IBOutets
    @IBOutlet weak var memImage: UIImageView!
    @IBOutlet weak var launchCamera: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolbarBottom: UIToolbar!
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var snapshotView: UIView!
    
    // MARK: Variables & Struct
    var textInputDelegate = TextInputDelegate()
    var memImageMovedUp = false
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.strokeWidth.rawValue: -4,
        ]
    
    struct Meme{
        var topText = "Top"
        var bottomText = "Bottom"
        var originalImage = UIImage()
        var memImage = UIImage()
    }

    // MARK: IBActions
    @IBAction func launchLibrary(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func launchCamera(_ sender: Any) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.delegate  = self
        present(cameraPicker, animated: true, completion: nil)
    }
    
    @IBAction func pressedCancel(_ sender: Any) {
        resetMeme()
        //let memImage = getMemImage()
        //controlImage.image = memImage
        //print(memImage)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        let memImage = getMemImage()
        let activityController = UIActivityViewController(activityItems: [memImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled; do nothing
                return
            }
            // User completed activity, save meme
            self.saveMeme(newMemeImage: memImage)
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        launchCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = .center
        topText.delegate = textInputDelegate
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = .center
        bottomText.delegate = textInputDelegate
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscriptToKeybordNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    // MARK: Functions
    func subscriptToKeybordNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscripbeKeybordNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification){
        // move view only up when it's bottom text and not already up (used to happen in simulator on first keyboard use)
        if bottomText.isEditing && memImageMovedUp == false{
            view.frame.origin.y -= getKeyboardHeight(notification)
            memImageMovedUp = true
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification){
        view.frame.origin.y = 0
        memImageMovedUp = false
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func getMemImage() -> UIImage{
        //hide unwanted components on screen
        toolbarBottom.isHidden = true
        topNavBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.memImage.frame.size)
        self.snapshotView.drawHierarchy(in: CGRect(x: self.snapshotView.frame.origin.x, y: 0, width: self.snapshotView.frame.width, height: self.snapshotView.frame.height), afterScreenUpdates: true)
        
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolbarBottom.isHidden = false
        topNavBar.isHidden = false
        
        return memedImage
    }
    
    func saveMeme(newMemeImage: UIImage){
        let mem = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: self.memImage.image!, memImage: newMemeImage)
        print(mem)
    }
    
    func resetMeme(){
        topText.text = defaultTopText
        bottomText.text = defaultBottomText
        memImage.image = UIImage()
    }
}

// MARK: Extension
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memImage.image = image
            self.memImage.contentMode = .scaleAspectFit
            self.memImage.clipsToBounds = false
        }
        dismiss(animated: true, completion: nil)
    }
}
