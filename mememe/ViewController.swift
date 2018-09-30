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
    @IBOutlet weak var topTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var topTextConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var bottomTextConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var bottomTextConstraintRight: NSLayoutConstraint!
    
    // MARK: Variables & Struct
    var textInputDelegate = TextInputDelegate()
    var memImageMovedUp = false
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    let defaultConstraint = CGFloat(20)
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
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
        shareButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         unsubscribeNotification()
    }
    
    // MARK: Functions
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        //let orientation = UIDevice.current.orientation
        print("orientation new")
        print(memImage.frame.size)
        setTextToAspectFitImage()
    }
    
    func subscribeToNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
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
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func getMemImage() -> UIImage{
        var newMemeImage: UIImage
        
        toolbarBottom.isHidden = true //hide unwanted components on screen
        topNavBar.isHidden = true
        
        // set context to actualimage size only
        if let image = memImage.image{
            
            let actualImageSize = frame(for: image, inImageViewAspectFit: memImage)
            let frameSize = CGSize(width: actualImageSize.width, height: actualImageSize.height)
            
            print("actual size: \(actualImageSize)")
            print("minX \(actualImageSize.minX)")
            print("maxX \(actualImageSize.maxX)")
            print("minY \(actualImageSize.minY)")
            print("maxY \(actualImageSize.maxY)")
            
            // Render view to an image
            UIGraphicsBeginImageContext(frameSize)
            self.snapshotView.drawHierarchy(in: CGRect(x: -actualImageSize.minX, y: -actualImageSize.minY, width: self.snapshotView.frame.width, height: self.snapshotView.frame.height), afterScreenUpdates: true)
            newMemeImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

        } else{
            newMemeImage = UIImage()
        }
        
        toolbarBottom.isHidden = false
        topNavBar.isHidden = false
        print("new image size w/h: \(newMemeImage.size.width) \(newMemeImage.size.height)")
        return newMemeImage
    }
    
    func saveMeme(newMemeImage: UIImage){
        let mem = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: self.memImage.image!, memImage: newMemeImage)
        print(mem)
    }
    
    func resetMeme(){
        topText.text = defaultTopText
        bottomText.text = defaultBottomText
        memImage.image = nil
        setTextToAspectFitImage()
        shareButton.isEnabled = false
    }
    
    //get the actual image position inside an imageview when aspectfit is set
    func frame(for image: UIImage, inImageViewAspectFit imageView: UIImageView) -> CGRect {
        let imageRatio = (image.size.width / image.size.height)
        let viewRatio = imageView.frame.size.width / imageView.frame.size.height
        if imageRatio < viewRatio {
            let scale = imageView.frame.size.height / image.size.height
            let width = scale * image.size.width
            let topLeftX = (imageView.frame.size.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageView.frame.size.height)
        } else {
            let scale = imageView.frame.size.width / image.size.width
            let height = scale * image.size.height
            let topLeftY = (imageView.frame.size.height - height) * 0.5
            return CGRect(x: 0.0, y: topLeftY, width: imageView.frame.size.width, height: height)
        }
    }
    
    func setTextToAspectFitImage(){
        if let image = memImage.image{
            let actualImageSize = self.frame(for: image, inImageViewAspectFit: memImage)
            var yOffset = actualImageSize.minY < 50 ? CGFloat(10) : CGFloat(50)
            yOffset = 5
            let textLeftRightConstraint = actualImageSize.minX > 10 ? CGFloat(actualImageSize.minX) : CGFloat(20)
            
            // set text y-position based
            topTextConstraint.constant = actualImageSize.minY - yOffset
            bottomTextConstraint.constant = (memImage.frame.size.height - (actualImageSize.height + actualImageSize.minY) - yOffset)
            
            // set text width max to image width
            topTextConstraintLeft.constant = textLeftRightConstraint
            topTextConstraintRight.constant = textLeftRightConstraint
            bottomTextConstraintLeft.constant = textLeftRightConstraint
            bottomTextConstraintRight.constant = textLeftRightConstraint
            
        } else{
            print("no image")
            topTextConstraint.constant = defaultConstraint
            bottomTextConstraint.constant = defaultConstraint
            topTextConstraintLeft.constant = defaultConstraint
            topTextConstraintRight.constant = defaultConstraint
            bottomTextConstraintLeft.constant = defaultConstraint
            bottomTextConstraintRight.constant = defaultConstraint
        }
    }
}

// MARK: Extension
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memImage.image = image
            self.memImage.contentMode = .scaleAspectFit
            self.memImage.clipsToBounds = false
            setTextToAspectFitImage()
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
}
