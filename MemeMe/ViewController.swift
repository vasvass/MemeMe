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
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
	let imagePicker = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
     
	override func viewDidLoad() {
		super.viewDidLoad()
		imagePicker.delegate = self
		constructTextField(textField: topTextField, withText: "TOP TEXT")
		constructTextField(textField: bottomTextField, withText: "BOTTOM TEXT")
  	}
	
    //MARK: - Adjusting Keyboard
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
           
           view.frame.origin.y = 0
       }
       
       func getKeyboardHeight(_ notification:Notification) -> CGFloat {
           
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
    
    // MARK: User selects image from camera
	
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
         
        if (UIImagePickerController.isSourceTypeAvailable(.camera) ) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            cameraButton.isEnabled = false
        }
    }
    
    // MARK: User selects image from album
	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
		if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFill
            imagePickerView.image = imagePicked
	    }
	 dismiss(animated: true, completion: nil)
	}
	
	  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
		dismiss(animated: true, completion: nil)
	 }
	
    // MARK: Textfields construction
    
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
    
    // MARK: Editinbg TextFields
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           if (topTextField == textField && topTextField.text == "TOP TEXT") {
               topTextField.text = ""
           }
           if (bottomTextField == textField && bottomTextField.text == "BOTTOM TEXT") {
               bottomTextField.text = ""
           }
       }
       
       func textFieldDidEndEditing(_ textField: UITextField) {
             if (topTextField.text != "TOP TEXT") && (bottomTextField.text != "BOTTOM TEXT" ) {
                 topTextField.isEnabled = true
                 bottomTextField.isEnabled = true
             }
         }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { 
         textField.resignFirstResponder()
     }
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
     // MARK: Creatio of a Meme
     
    func save() {
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {

        hideTopAndBottomToolbars(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        hideTopAndBottomToolbars(false)

        return memedImage
    }
    
    // MARK: Saving and sharing the created Meme
    
    @IBAction func shareButton(_ sender: Any) {
              
               let vccontroller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
               
               present(vccontroller, animated: true, completion: nil)
               
               vccontroller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, finished: Bool, returnedItems: [Any]?, error: Error?) -> Void in
                   if finished == true {
                       self.save()
                       
     
                       self.presentingViewController?.dismiss(animated: true, completion: nil)
                       
                   }
                   
               }
    }
    
    // MARK: Hiding the top and bottom toolbars
    
    func hideTopAndBottomToolbars(_ hide: Bool) {
        bottomToolbar.isHidden=hide
        topToolbar.isHidden=hide
    }
    
    // MARK: When cancel button is pressed values return to default
    
    func cancel(){
        topTextField.text="TOP TEXT"
        bottomTextField.text="BOTTOM TEXT"
        imagePickerView!.image=nil
        shareButton.isEnabled=true
        topTextField.isEnabled = true
        bottomTextField.isEnabled = true
     }

    @IBAction func cancelEditing(_ sender: Any) {
        cancel()
    }
}

