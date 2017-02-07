//
//  UserProfileViewController.swift
//  LunchVote
//
//  Created by Yi JIANG on 5/2/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import SnapKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileImageView.snp.makeConstraints{ (make) in
            make.top.equalTo(self.view).offset(140)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        
        
        firstNameLabel.textAlignment = .center
        firstNameLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(userProfileImageView.snp.bottom).offset(40)
            make.centerX.equalTo(self.view.snp.centerX)
        }
        
        let loginButton = FBSDKLoginButton.init()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        if (FBSDKAccessToken.current() != nil) {
            print("It is loged in!!! <------<<< ")
            getFBUserData()
        } else {
            resetUserData()
        }
        loginButton.delegate = self
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(firstNameLabel.snp.bottom).offset(40)
            make.centerX.equalTo(self.view.snp.centerX)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//    @IBAction func loginFacebookButtonTouchUpInside(_ sender: UIButton) {
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        if let _ = FBSDKAccessToken.current() {
//            fbLoginManager.logOut()
//            
//        } else {
//            fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
//                if (error == nil){
//                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                    if(fbloginresult.grantedPermissions.contains("email"))
//                    {
//                        self.getFBUserData()
//                    }
//                }
//            }
//        }
//    }
  
    
    func getFBUserData(){
        if FBSDKAccessToken.current() != nil{
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result ?? "Result is nil")
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    let userFirstNameString = data["first_name"] as? String
                    if let _ = userFirstNameString {
                        self.firstNameLabel.text = userFirstNameString
                        LVCacheManager.sharedInstance.multipeerConnect.LocalPeerId = data["first_name"] as? String
                    }
                    let userProfileImagePath = (data["picture"]!["data"]!! as! [String : AnyObject])["url"] as? String
//                    let userProfileImagePath = data["picture.data.url"] as? String
                    DispatchQueue.global().async {
                        let imageData = try? Data(contentsOf: Foundation.URL(string:userProfileImagePath!)!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async {
                            self.userProfileImageView.image = UIImage(data: imageData!)
                        }
                    }
                }
            })
        }
    }
    
    func resetUserData() {
        userProfileImageView.image = UIImage(named: "emptyUserProfile")
        firstNameLabel.text = "Name"
    }

}

extension UserProfileViewController:FBSDKLoginButtonDelegate {
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        getFBUserData()
        
    }
    
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        resetUserData()
    }
    
    
    /**
     Sent to the delegate when the button is about to login.
     - Parameter loginButton: the sender
     - Returns: YES if the login should be allowed to proceed, NO otherwise
     */
    public func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}
