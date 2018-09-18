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
    //we want to keep the old text when the user deletes all text and pressed return
    var oldText = ""
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("text delegate")
        oldText = textField.text!
        
        if (textField.text! == "TOP" || textField.text! == "BOTTOM") {
                textField.text = ""
            }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //make the text uppercase not matter what, had some problems with the shift-key on the keyboard
        textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end editing")
        if textField.text?.count == 0{
            textField.text = oldText
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("should retrun")
        textField.endEditing(true)
        return false
    }
}
