//
//  CitiesViewController.swift
//  Autocomplete
//
//  Created by Timothy P Miller on 2/18/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit

class CitiesViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var clearButtonItem: UIBarButtonItem?
    
    let autocompleteManager: AutocompleteManager
    var searchString: String?
    var list: Array<String>?
    var listTitle: String
    
    required init(coder aDecoder: NSCoder) {
        autocompleteManager = AutocompleteManager()
        
        // From file
        autocompleteManager.loadDataFrom(name: "world_cities", type: "txt")

        // From URL
//        autocompleteManager.loadDataFromURL(name: "<Can alternatively read file from a URL>")

        list = autocompleteManager.recentsListSorted
        listTitle = "Recents"
        searchString = ""

        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "City Finder"
        clearButtonItem?.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return listTitle
        }
        return ""
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if let rows = list?.count {
                return rows
            }
        }
        return 0
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 && row == 0 {
            let reuseIdentifier = "SearchCell"
            let cell: SearchTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
            cell.searchTextField.delegate = self

            return cell
        } else if section == 1 {
            let reuseIdentifier = "NameCell"
            let cell: NameTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NameTableViewCell
            if let name = list?[indexPath.row] {
                cell.nameLabel.text = name
            }

            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if let newSearchString = list?[indexPath.row] {
                searchString = newSearchString
                autocompleteManager.addToRecents(searchString!)
                print("Number of recents: \(autocompleteManager.recentsList.count)")
                self.performSegueWithIdentifier("CitiesWebSearch", sender: self)
            }
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            if autocompleteManager.recentsList == list! {
                return true
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if editingStyle == UITableViewCellEditingStyle.Delete {
                if autocompleteManager.recentsList == list! {
                    autocompleteManager.removeRecent(indexPath.row)
                    list = autocompleteManager.recentsListSorted
                    self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
                    if list!.isEmpty {
                        clearButtonItem?.enabled = false
                        clearButtonItem?.title = "Clear"
                    }
                }
            }
        }
    }
    
    @IBAction func editingDidChange(sender: UITextField) {
        listTitle = "Recents"
        let autocompleteField: UITextField = sender
        if autocompleteField.text!.isEmpty {
            list = autocompleteManager.recentsListSorted
            if !list!.isEmpty {
                clearButtonItem?.enabled = true
                clearButtonItem?.title = "Clear"
            }
        } else {
            listTitle = "Cities"
            clearButtonItem?.enabled = false
            // There is no hidden property for this type of button
            clearButtonItem?.title = ""
            
            // Use the built in filtering to match starting text
            list = autocompleteManager.updateListMatchPrefix(autocompleteField.text!)
            
            // May also pass your own filter as a closure
//            list = autocompleteManager.updateList({ $0.lowercaseString.hasPrefix(autocompleteField.text.lowercaseString) })
        }
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let newSearchString: String = list?.first {
            searchString = newSearchString
            autocompleteManager.addToRecents(searchString!)
            
            self.performSegueWithIdentifier("CitiesWebSearch", sender: self)
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Searching for: \(searchString)")
        let webViewController = segue.destinationViewController as! WebViewController
        
        let searchComponents = searchString!.componentsSeparatedByString(",")
        
        let city = searchComponents[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let country = searchComponents[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // Format for Wikipedia and encode
        let urlString = "https://en.wikipedia.org/wiki/"
        var urlPath = urlString + city + ",_" + country        
        urlPath = urlPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        webViewController.urlPath = urlPath
    }
    
    @IBAction func clearRecents(sender: AnyObject) {
        print("Clear recents")
        autocompleteManager.clearRecents()
        list = autocompleteManager.recentsListSorted
        clearButtonItem!.enabled = false
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

