//
//  TextInputDelegate.swift
//  mememe
//
//  Created by Peter Pohlmann on 15.09.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import Foundation
import UIKit

class TextInputDelegate: NSObject, UITextFieldDelegate{
    //keep the old text when user deleted all text and pressed return
    var oldText = ""
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        oldText = textField.text!
        
        if (textField.text! == "TOP" || textField.text! == "BOTTOM") {
                textField.text = ""
            }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //make the text uppercase not matter what
        textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0{
            textField.text = oldText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}
