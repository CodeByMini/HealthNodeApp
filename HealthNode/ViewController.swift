//
//  ViewController.swift
//  HealthNode
//
//  Created by Daniel Johansson on 2021-12-02.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var hostInput: UITextField!
    @IBOutlet weak var apikeyInput: UITextField!
    @IBOutlet weak var nightscoutInput: UITextField!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //buttonView.backgroundColor = .clear
        buttonView.layer.cornerRadius = 5
        buttonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        buttonView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        buttonView.layer.shadowOpacity = 1.0
        buttonView.layer.shadowRadius = 0.0
        buttonView.layer.masksToBounds = false
        
        textField.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

       //tap.cancelsTouchesInView = false

       view.addGestureRecognizer(tap)

        HealthPermission()
    }


   
    @IBAction func Upload(_ sender: UIButton) {
        print("pressed")
        
        HealthUpload(statusLabel: statusLabel,
                     textField: textField,
                     hostInput:hostInput,
                     apikeyInput: apikeyInput,
                     nightscoutInput:nightscoutInput)
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}


