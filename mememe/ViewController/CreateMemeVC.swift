//
//  ViewController.swift
//  mememe
//
//  Created by Peter Pohlmann on 15.09.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit

class CreateMemeVC: UIViewController {
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
    @IBOutlet weak var topNavBarHeightConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    var textInputDelegate = TextInputDelegate()
    var memImageMovedUp = false
    var textTop = "TOP"
    var textBottom = "BOTTOM"
    let defaultConstraint = CGFloat(20)
    var orientation = UIDevice.current.orientation
    var lastOrientation = UIDevice.current.orientation
    var savedMeme: Meme?
    var unwindIdentifier = ""
    var unwindScrollToTop = false

    // MARK: IBActions
    @IBAction func launchLibrary(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    @IBAction func launchCamera(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    @IBAction func pressedCancel(_ sender: Any) {
        unwindToController(identifier: unwindIdentifier, scrollToTop: unwindScrollToTop)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        let memImage = getMemImage()
        let activityController = UIActivityViewController(activityItems: [memImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
               self.saveMeme(newMemeImage: memImage)
            }
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar on the this view controller
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         unsubscribeNotification()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Functions
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        orientation = UIDevice.current.orientation
        setTextToAspectFitImage()
    }
    
    func unwindToController(identifier: String, scrollToTop: Bool = false){
        let navigationCount = self.navigationController!.viewControllers.count
        
        switch identifier {
            case "DetailViewVC": //back to detail view, meme not saved
                print("unwind to detail")
                if let tableViewVC = self.navigationController!.viewControllers[navigationCount-2] as? DetailViewVC {
                    self.navigationController?.popToViewController(tableViewVC, animated: true)
                }
            case "SentMemesTableVC": //meme saved, back to tableview, tableview should scroll 2 to then
                if let tableViewVC = self.navigationController!.viewControllers[0] as? SentMemesTableVC {
                    tableViewVC.scrollToTop = scrollToTop
                    self.navigationController?.popToViewController(tableViewVC, animated: true)
                }
            case "SentMemesCollectionVC": //unwind to collection view
                if let collectionViewVC = self.navigationController!.viewControllers[0] as? SentMemesCollectionVC {
                    self.navigationController?.popToViewController(collectionViewVC, animated: true)
                }
            default:
                self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func setup(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        launchCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToNotification()
        
        //if pressed edit from detail view
        if let savedMeme = savedMeme{
            textTop = savedMeme.topText
            textBottom  = savedMeme.bottomText
            memImage.image = savedMeme.originalImage
            shareButton.isEnabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                self.setTextToAspectFitImage() //unfort. some kind of delay is needed until the image is available for aspect ratio
            }
        }
        
        setupTextField(tf: topText, text: textTop)
        setupTextField(tf: bottomText, text: textBottom)
    }
    
    func setupTextField(tf: UITextField, text: String) {
        tf.defaultTextAttributes = [
            NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.strokeWidth.rawValue: -4,
        ]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = textInputDelegate
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
            print("KEYBOARD APPEAR")
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
        
        hideToolbars(true)
        
        // "automatic cropping" of the meme image to get rid of unwanted image borders in landscape or portrait mode:
        // the actual meme-image is displayed inside an uimageview, which is set to aspectFit.
        // so the dimensions of the imageview represents NOT always the real image dimension.
        // the frame() function calculates the image dimension based on the image ratio inside the uiview as cgrect.
        // now we can set the graphics context to the image; so only the image itself (and  it's text) is captured
        // and NOT the full imageview with its potential borders in landscapr or portrait mode
        if let image = memImage.image{
            let actualImageSize = frame(for: image, inImageViewAspectFit: memImage)
            let frameSize = CGSize(width: actualImageSize.width, height: actualImageSize.height)
            
            UIGraphicsBeginImageContext(frameSize)
            self.snapshotView.drawHierarchy(in: CGRect(x: -actualImageSize.minX, y: -actualImageSize.minY, width: self.snapshotView.frame.width, height: self.snapshotView.frame.height), afterScreenUpdates: true)
            newMemeImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

        } else{
            newMemeImage = UIImage()
        }
        
        hideToolbars(false)
        
        return newMemeImage
    }
    
    func saveMeme(newMemeImage: UIImage){
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: self.memImage.image!, memImage: newMemeImage)
       
        // Add meme to memes in App Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
       
        //unwind information, meme saved, go always back to root controller and scroll to the newest saved meme
        //unwindIdentifier = "SentMemesTableVC"
        unwindScrollToTop = true
    }
    
    //get the actual image position inside an imageview when aspectfit is set (from stackoverflow)
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
        // adjust topnavbar height for landscape/portrait mode
        if(orientation.isLandscape == false){
            topNavBarHeightConstraint.constant = 44
        }
        if (orientation.isLandscape == true || lastOrientation.isLandscape && orientation.isFlat && true ) {
            topNavBarHeightConstraint.constant = 32
        }
        
        //save to track if device goes from landscape to flat
        lastOrientation = UIDevice.current.orientation
        
        if let image = memImage.image{
            let actualImageSize = self.frame(for: image, inImageViewAspectFit: memImage)
            let textLeftRightConstraint = actualImageSize.minX > 10 ? CGFloat(actualImageSize.minX) : CGFloat(20)
            
            // set text constraints for positioning
            topTextConstraint.constant = actualImageSize.minY - 5
            bottomTextConstraint.constant = (memImage.frame.size.height - (actualImageSize.height + actualImageSize.minY) - 6)
            topTextConstraintLeft.constant = textLeftRightConstraint
            topTextConstraintRight.constant = textLeftRightConstraint
            bottomTextConstraintLeft.constant = textLeftRightConstraint
            bottomTextConstraintRight.constant = textLeftRightConstraint
        } else{
            topTextConstraint.constant = defaultConstraint
            bottomTextConstraint.constant = defaultConstraint
            topTextConstraintLeft.constant = defaultConstraint
            topTextConstraintRight.constant = defaultConstraint
            bottomTextConstraintLeft.constant = defaultConstraint
            bottomTextConstraintRight.constant = defaultConstraint
        }
    }
    
    func hideToolbars(_ hide:Bool){
        toolbarBottom.isHidden = hide
        topNavBar.isHidden = hide
    }
    
}

// MARK: Extension
extension CreateMemeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memImage.image = image
            self.memImage.contentMode = .scaleAspectFit
            self.memImage.clipsToBounds = false
            setTextToAspectFitImage()
            self.shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
}
