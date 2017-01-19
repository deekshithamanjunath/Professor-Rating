//
//  InformationViewController.swift
//  assignment5
//
//  Created by Deekshitha Manjunath on 11/12/16.
//  Copyright © 2016 Deekshitha Manjunath. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource
{
    
    @IBOutlet var firstName: UILabel!
    @IBOutlet var lastName: UILabel!
    @IBOutlet var office: UILabel!
    @IBOutlet var phone: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var averageRating: UILabel!
    @IBOutlet var totalRating: UILabel!
    @IBOutlet var rating: UITextField!
    @IBOutlet var comment: UITextField!
    
    @IBOutlet var commentView: UITableView!
    
    var dictionaryJsonData:Dictionary<String, AnyObject> = [:]
    var value = 0
    let idVal = 0
    var commentArr:Array<String> = []
    
    @IBAction func Submit()
    
    {
        if comment != nil
        {
            let commentUpdate = "http://bismarck.sdsu.edu/rateme/comment/"+String(self.value+1)
            print(commentUpdate)
            var call = URLRequest(url: URL(string: commentUpdate)!)
            call.httpMethod = "POST"
            let updateString = comment.text
            call.httpBody = updateString?.data(using: .utf8)
            let job = URLSession.shared.dataTask(with: call)
            {
                data, response, error in
                guard let data = data, error == nil else
                {
                    print("error=\(error)")
                    return
                }
                
                if let httpState = response as? HTTPURLResponse, httpState.statusCode != 200
                {
                    print("statusCode should be 200, but is \(httpState.statusCode)")
                    print("response = \(response)")
                }
                
                let outputString = String(data: data, encoding: .utf8)
                print("outputString = \(outputString)")
            }
            job.resume()
        }

        if rating != nil && rating.text?.characters.count != 0
        {
            if Int(rating.text!)! >= 1 && Int(rating.text!)! <= 5
            {
                print(rating.text!)
                let ratingUpdate = "http://bismarck.sdsu.edu/rateme/rating/"+String(self.value+1)+"/"+rating.text!
                var call = URLRequest(url: URL(string: ratingUpdate)!)
                call.httpMethod = "POST"
                let job = URLSession.shared.dataTask(with: call)
                {
                    data, response, error in
                    guard let data = data, error == nil else
                    {
                        print("error=\(error)")
                        return
                    }
              
                    if let httpState = response as? HTTPURLResponse, httpState.statusCode != 200
                    {
                        print("statusCode should be 200, but is \(httpState.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let outputString = String(data: data, encoding: .utf8)
                    print("outputString = \(outputString)")
                }
                job.resume()
            }
        }
        
        
        comment.text = ""
        rating.text = ""
        dismissKeyboard()
    }

    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let idFinal = String(value + 1)
        print(idFinal)
        
        commentView.dataSource = self

        let urlSequence1 = "http://bismarck.sdsu.edu/rateme/comments/"+idFinal
        if let urlupdate1 = URL(string: urlSequence1) {
            let session2 = URLSession.shared
            let job2 = session2.dataTask(with: urlupdate1, completionHandler: retrieveData1)
            job2.resume()
        }
        else
        {
            print("Error")
        }
        
        let urlSequence = "http://bismarck.sdsu.edu/rateme/instructor/"+idFinal
        if let urlupdate = URL(string: urlSequence)
        {
            let session = URLSession.shared
            let job = session.dataTask(with: urlupdate, completionHandler: retriveData)
            job.resume()
        }
        else
        {
            print("Error")
        }

        let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InformationViewController.dismissKeyboard))
        view.addGestureRecognizer(gesture)
        
    }
    
    func retriveData(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        guard error == nil else
        {
            print("error: \(error!.localizedDescription)")
            return
        }
        if data != nil
        {
            if let webContent = String(data: data!, encoding: String.Encoding.utf8)
            {
                let jsonWebData:Data? = webContent.data(using: String.Encoding.utf8)
                do
                {
                    let result = try JSONSerialization.jsonObject(with: jsonWebData!)
                    dictionaryJsonData = (result as! NSDictionary) as! Dictionary<String, Any> as Dictionary<String, AnyObject>
                    DispatchQueue.main.async
                        {
                            self.firstName.text = self.dictionaryJsonData["firstName"] as? String
                            self.lastName.text = self.dictionaryJsonData["lastName"] as? String
                            self.office.text = self.dictionaryJsonData["office"] as? String
                            self.phone.text = self.dictionaryJsonData["phone"] as? String
                            self.email.text = self.dictionaryJsonData["email"] as? String
                            if let rating = self.dictionaryJsonData["rating"] as? Dictionary<String, AnyObject>
                            {
                                self.averageRating.text = "\(rating["average"]!)"
                                self.totalRating.text = "\(rating["totalRatings"]!)"
                            }
                    
                        }
                }
                    
                catch
                {
                }
            }
            else
            {
                print("Unsuccessful data to text conversion")
            }
        }
    }
    
    
    func retrieveData1 (data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        if error != nil
        {
            print("Error: \(error!.localizedDescription)")
            return
        }
        if data != nil
        {
            if let json1 = String(data: data!, encoding: String.Encoding.utf8)
            {
                let jsonData1:Data? = json1.data(using: String.Encoding.utf8)
                do
                {
                    let jsonResult1 = try JSONSerialization.jsonObject(with: jsonData1!)
                    for each in jsonResult1 as! [Dictionary<String, AnyObject>]
                    {
                        let comments = each["text"] as! String
                        commentArr.append(comments)
                    }
                    commentView.reloadData()
                }
                catch
                {
                    print("Error is fetching JSON data")
                }
            }
            else
            {
                print("Error in convertion JSON data to text")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commentArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let commentCell = UITableViewCell()
        commentCell.textLabel?.text = commentArr[indexPath.row]
        return commentCell
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        moveTextField(textField: rating, moveDistance: -60, up: true)
        moveTextField(textField: comment, moveDistance: -200, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        moveTextField(textField: rating, moveDistance: -60, up: false)
        moveTextField(textField: comment, moveDistance: -200, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, up:Bool)
    {
        let limit = 0.5
        let distance:CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(limit)
        self.view.frame = self.view.frame.offsetBy(dx: 0 , dy: distance)
        UIView.commitAnimations()
    }

}
