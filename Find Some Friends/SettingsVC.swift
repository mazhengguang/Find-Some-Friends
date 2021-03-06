//
//  SettingsVC.swift
//  Find Some Friends
//
//  Created by John Leonardo on 12/5/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Foundation

class SettingsVC: UIViewController {
    
    var userID: String!
    
    var maleFemale: Int!
    
    let defaults = UserDefaults.standard
    
    let ref = FIRDatabase.database().reference()

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var snapchatField: UITextField!
    @IBOutlet weak var kikField: UITextField!
    @IBOutlet weak var wechatField: UITextField!
    @IBOutlet weak var twitterField: UITextField!
    @IBOutlet weak var instagramField: UITextField!
    @IBOutlet weak var lineField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.backgroundColor = UIColor(patternImage: UIImage(named: "bg.png")!)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsVC.dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
        ref.child("priority").observeSingleEvent(of: .value, with: { (snapshot) in
            // Check if current user is male or female to save time digging thru db
            if snapshot.childSnapshot(forPath: "male").hasChild(self.userID) {
                self.maleFemale = 0
                self.updateFields(mf: 0)
                
            } else if snapshot.childSnapshot(forPath: "female").hasChild(self.userID) {
                self.maleFemale = 1
                self.updateFields(mf: 1)
            }
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func updateFields(mf: Int) {
        switch mf {
        case 0:
            ref.child("users").child("male").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let socials = snapshot.childSnapshot(forPath: "socials").value as! NSDictionary
                self.wechatField.text = socials.value(forKey: "wechat") as! String?
                self.twitterField.text = socials.value(forKey: "twitter") as! String?
                self.snapchatField.text = socials.value(forKey: "snapchat") as! String?
                self.lineField.text = socials.value(forKey: "line") as! String?
                self.instagramField.text = socials.value(forKey: "instagram") as! String?
                self.kikField.text = socials.value(forKey: "kik") as! String?
                self.nameField.text = snapshot.childSnapshot(forPath: "name").value as! String
                }) { (error) in
                print(error.localizedDescription)
            }
        case 1:
            ref.child("users").child("female").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                let socials = snapshot.childSnapshot(forPath: "socials").value as! NSDictionary
                self.wechatField.text = socials.value(forKey: "wechat") as! String?
                self.twitterField.text = socials.value(forKey: "twitter") as! String?
                self.snapchatField.text = socials.value(forKey: "snapchat") as! String?
                self.lineField.text = socials.value(forKey: "line") as! String?
                self.instagramField.text = socials.value(forKey: "instagram") as! String?
                self.kikField.text = socials.value(forKey: "kik") as! String?
                self.nameField.text = snapshot.childSnapshot(forPath: "name").value as! String
                }) { (error) in
                print(error.localizedDescription)
            }
        default: break
            
        }
    }
    
    
    @IBAction func saveBtn(_ sender: AnyObject) {
        let data = ["snapchat": snapchatField.text! as String, "kik": kikField.text! as String, "wechat": wechatField.text! as String, "line": lineField.text! as String, "twitter": twitterField.text! as String, "instagram": instagramField.text! as String]
        switch maleFemale {
        case 0:
            updateFirebase(gender: "male", data: data)
        case 1:
            updateFirebase(gender: "female", data: data)
        default:
            break
        }
        performSegue(withIdentifier: "unwindToMain", sender: nil)
    }
    
    func updateFirebase(gender: String, data: [String:String]) {
        ref.child("users").child(gender).child(userID).child("socials").updateChildValues(data)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func promoBtn(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Promo Code", message: "", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            if let code = firstTextField.text {
                self.ref.child("promoCodes").child(code).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let credits = snapshot.value {
                        if credits is NSNull {
                            self.showAlert(msg: "Code is either invalid or expired", title: "Oops")
                        } else {
                            let redeemed = self.defaults.bool(forKey: code)
                            if redeemed {
                                self.showAlert(msg: "Already redeemed code '\(code)'", title: "Oops")
                            } else {
                                switch self.maleFemale {
                                case 0:
                                    
                                self.ref.child("users").child("male").child(self.userID).child("credits").observeSingleEvent(of: .value, with: { (snap) in
                                    let currentCredits = snap.value! as! Int
                                    let promoCredits = credits as! Int
                                    let newCredits = currentCredits + promoCredits
                                    self.ref.child("users").child("male").child(self.userID).child("credits").setValue(newCredits)
                                    self.defaults.set(true, forKey: code)
                                    self.showAlert(msg: "\(promoCredits) credits have been added to your account. You now have \(newCredits) credits!", title: "Yay! :D")
                                })
                                case 1:
                                    
                                self.ref.child("users").child("female").child(self.userID).child("credits").observeSingleEvent(of: .value, with: { (snap) in
                                        let currentCredits = snap.value! as! Int
                                        let promoCredits = credits as! Int
                                        let newCredits = currentCredits + promoCredits
                                        self.ref.child("users").child("female").child(self.userID).child("credits").setValue(newCredits)
                                        self.defaults.set(true, forKey: code)
                                        self.showAlert(msg: "\(promoCredits) credits have been added to your account. You now have \(newCredits) credits!", title: "Yay! :D")
                                    })
                                default: break
                                }
                            }
                        }
                    }
                })
            }
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Promo Code"
        }
        
        alertController.addAction(doneAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        }
    
    func showAlert(msg: String, title: String) {
        let aC = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        aC.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
        present(aC, animated: true, completion: nil)
    }
    

}
