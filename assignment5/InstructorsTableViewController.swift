//
//  InstructorsTableViewController.swift
//  assignment5
//
//  Created by Deekshitha Manjunath on 11/12/16.
//  Copyright © 2016 Deekshitha Manjunath. All rights reserved.
//

import UIKit

class InstructorsTableViewController: UITableViewController
{
    
    
        var arrList: Array<String> = []
        var outList: Array<String> = []
    
        override func viewDidLoad()
        {
            super.viewDidLoad()
            if let url = URL(string: "http://bismarck.sdsu.edu/rateme/list")
            {
                let session = URLSession.shared
                let job = session.dataTask(with: url, completionHandler: retriveData)
                job.resume()
            }
            else
            {
                print("Error")
            }
        }
        
        
        func retriveData(data:Data?, response:URLResponse?, error:Error?) -> Void
        {
            guard error == nil else
            {
                print("error: \(error!.localizedDescription)")
                return
            }
            var index = 0;
            var fullname:String=""
            if data != nil
            {
                if let webContent = String(data: data!, encoding: String.Encoding.utf8)
                {
                    let jsonWebData:Data? = webContent.data(using: String.Encoding.utf8)
                    do
                    {
                        let result = try JSONSerialization.jsonObject(with: jsonWebData!)
                        for every in result as! [Dictionary<String, AnyObject>]
                        {
                            fullname = ""
                            let nameFirst = every["firstName"] as! String
                            let nameLast = every["lastName"] as! String
                            fullname = nameFirst + " " + nameLast
                            arrList.insert(String(fullname), at: index)
                            index=index+1;
                        }
                        self.tableView.reloadData()
                    }
                    catch
                    {
                    }
                }
                else
                {
                    print("unable to convert data to text")
                }
            }
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int
        {
            return 1
            
        }
        
        
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return arrList.count
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
        {
            let cell = UITableViewCell()
            cell.textLabel?.text = arrList[indexPath.row]
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
            performSegue(withIdentifier: "segueid", sender: indexPath.row)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            let guest = segue.destination as! InformationViewController
            guest.value = sender as! Int
        }
    }


    
