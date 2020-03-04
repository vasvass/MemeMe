//
//  ViewController.swift
//  MemeMe 
//
//  Created by Vassileios Vassileiades on 14/2/20.
//  Copyright © 2020 Vassileios Vassileiades. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var topTextField: UITextField!
	@IBOutlet weak var bottomTextField: UITextField!
	@IBOutlet weak var topToolbar: UIToolbar!
	@IBOutlet weak var bottomToolbar: UIToolbar!
	
	
	let imagePicker = UIImagePickerController()
    
    /* Add viewWillAppear
       - Check Camera
       - Adjust Keyboard (subscribe to Keyboard)
	*/
    
    /* Add viewWillDisapear
       - Adjust Keyboard (unsuscribe from keyboard)
    */
    
	override func viewDidLoad() {
		super.viewDidLoad()
		imagePicker.delegate = self
		constructTextField(textField: topTextField, withText: "TOP TEXT")
		constructTextField(textField: bottomTextField, withText: "BOTTOM TEXT")
	}
	
    //MARK: - Adjusting Keyboard
    
    func subscribeToKeyboardNotifications() {
        
        // Keyboard adjustment based on notification call, both when called and dismissed
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeToKeyboardNotifications() {
        
        // Keyboard adjustment on dismiss
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        // Adjustment to the frame on entry to the UITextfield and specifically for the bottom UITexfield
        if bottomTextField.isEditing{
            view.frame.origin.y -= getKeyboardHeight(notification)
            
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
           
           // Adjustment of the frame back to the original state
           view.frame.origin.y = 0
           
       }
       
       func getKeyboardHeight(_ notification:Notification) -> CGFloat {
           
           // Function which returns the height of the keyboard
           let userInfo = notification.userInfo
           let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
           return keyboardSize.cgRectValue.height
           
       }
    
	// MARK: User select image from library
    
	@IBAction func pickAnImageFromAlbum(_ sender: Any) {
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		
		present(imagePicker, animated: true, completion: nil)
	}
    
    // MARK: User select image from camera
	
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
         
        if (UIImagePickerController.isSourceTypeAvailable(.camera) ) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
         print("Camera not available on the device!")
        }
    }
    
	// MARK: User select image from album
	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFill
            imagePickerView.image = imagePicked
	    }
	 dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil
	)
	}
	
    func constructTextField(textField: UITextField, withText text: String) {
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
    }

		
	let memeTextAttributes: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.strokeColor: UIColor.black,
		NSAttributedString.Key.foregroundColor: UIColor.white,
		NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSAttributedString.Key.strokeWidth: NSNumber(value: -3.0 as Float)
	]
	 
	
	
}

