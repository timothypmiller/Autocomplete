//
//  PresidentsViewController.swift
//  Autocomplete
//
//  Created by Timothy P Miller on 2/18/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit

class PresidentsViewController: UITableViewController, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet var clearButtonItem: UIBarButtonItem?
    
    let autocompleteManager: AutocompleteManager
    var searchString: String?
    var list: Array<String>?
    var listTitle: String
    
    required init(coder aDecoder: NSCoder) {
        autocompleteManager = AutocompleteManager()

        // From file
        autocompleteManager.loadDataFrom(name: "us_presidents", type: "txt")

        // From URL
//        autocompleteManager.loadDataFromURL(name: "<Can alternatively read file from a URL>")

        list = autocompleteManager.recentsListSorted
        listTitle = "Recents"
        searchString = ""

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "President Finder"
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
        var section = indexPath.section
        var row = indexPath.row
        
        if section == 0 && row == 0 {
            let reuseIdentifier = "SearchCell"
            var cell: SearchTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SearchTableViewCell
            cell.searchTextField.delegate = self

            return cell
        } else if section == 1 {
            let reuseIdentifier = "NameCell"
            var cell: NameTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NameTableViewCell
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
                println("Number of recents: \(autocompleteManager.recentsList.count)")
                self.performSegueWithIdentifier("PresidentsWebSearch", sender: self)
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
        if autocompleteField.text.isEmpty {
            list = autocompleteManager.recentsListSorted
            if !list!.isEmpty {
                clearButtonItem?.enabled = true
                clearButtonItem?.title = "Clear"
            }
        } else {
            listTitle = "Presidents"
            clearButtonItem?.enabled = false
            // There is no hidden property for this type of button
            clearButtonItem?.title = ""
            
            // Use the built in filtering to match any contained text
            list = autocompleteManager.updateListMatchAny(autocompleteField.text)
        }
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let newSearchString: String = list?.first {
            searchString = newSearchString
            autocompleteManager.addToRecents(searchString!)
            
            self.performSegueWithIdentifier("PresidentsWebSearch", sender: self)
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("Searching for: \(searchString)")
        var webViewController = segue.destinationViewController as! WebViewController
        
        let searchComponents = searchString!.componentsSeparatedByString(" ")
        
        var fullName: String = String()
        for name in searchComponents {
            fullName += "_"
            fullName += name
        }
        
        fullName = fullName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        println("\(fullName)")
        
        // Format for Wikipedia and encode
        let urlString = "http://en.wikipedia.org/wiki/"
        var urlPath = urlString + fullName
        urlPath = urlPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        webViewController.urlPath = urlPath
    }
    
    @IBAction func clearRecents(sender: AnyObject) {
        println("Clear recents")
        autocompleteManager.clearRecents()
        list = autocompleteManager.recentsListSorted
        clearButtonItem!.enabled = false
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

