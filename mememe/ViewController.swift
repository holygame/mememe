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
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolbarBottom: UIToolbar!
    @IBOutlet weak var controlImage: UIImageView!
    @IBOutlet weak var topNavBar: UINavigationBar!
    @IBOutlet weak var snapshotView: UIView!
    
    // MARK: Variables & Struct
    var textInputDelegate = TextInputDelegate()
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
        let memImage = getMemImage()
        controlImage.image = memImage
        print(memImage)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        let memImage = getMemImage()
        let activityController = UIActivityViewController(activityItems: [memImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                print("activity cancelled")
                return
            }
            // User completed activity
            self.saveMeme(newMemeImage: memImage)
            print("activity complete")
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBOutlet var controlImagePressed: [UIImageView]!
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
    @IBAction func clearControlImage(_ sender: Any) {
        controlImage.image = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscriptToKeybordNotification()
        print("will appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        print("will disappear")
    }
    
    // MARK: Functions
    func subscriptToKeybordNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
        print("subscribe")
    }
    
    func unsubscripbeKeybordNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        print("unsubscribe")
    }
    
    @objc func keyboardWillAppear(_ notification: Notification){
        print("keyboard appear")
        print(topText.isEditing)
        if bottomText.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification){
        print("keyboard will disappear")
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        print("get keyboardsize")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func getMemImage() -> UIImage{
        //hide unwanted components on screen
        toolbarBottom.isHidden = true
        topNavBar.isHidden = true
        print("y")
        print(topText.frame.origin.y)
        print(bottomText.frame.origin.y)
        topText.frame.origin.y = topText.frame.origin.y - topNavBar.frame.height
        bottomText.frame.origin.y = bottomText.frame.origin.y + toolbarBottom.frame.height
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.memImage.frame.size)
        print("franesizes")
        print(self.memImage.frame.size)
        print(self.memImage.frame.origin.y)
        
        self.snapshotView.drawHierarchy(in: CGRect(x: self.snapshotView.frame.origin.x, y: 0, width: self.snapshotView.frame.width, height: self.snapshotView.frame.height), afterScreenUpdates: true)
        
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        topText.frame.origin.y = topText.frame.origin.y + topNavBar.frame.height
        bottomText.frame.origin.y = bottomText.frame.origin.y - toolbarBottom.frame.height
        toolbarBottom.isHidden = false
        topNavBar.isHidden = false
        
        return memedImage
    }
    
    func saveMeme(newMemeImage: UIImage){
        let mem = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: self.memImage.image!, memImage: newMemeImage)
        print(mem)
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
