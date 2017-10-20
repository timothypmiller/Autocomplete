//
//  PresidentsViewController.swift
//  Autocomplete
//
//  Created by Timothy P Miller on 2/18/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit

class PresidentsViewController: UITableViewController, UITextFieldDelegate {
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

        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "President Finder"
        clearButtonItem?.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView?) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return listTitle
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if let rows = list?.count {
                return rows
            }
        }
        return 0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 && row == 0 {
            let reuseIdentifier = "SearchCell"
            let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchTableViewCell
            cell.searchTextField.delegate = self

            return cell
        } else if section == 1 {
            let reuseIdentifier = "NameCell"
            let cell: NameTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NameTableViewCell
            if let name = list?[indexPath.row] {
                cell.nameLabel.text = name
            }

            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let newSearchString = list?[indexPath.row] {
                searchString = newSearchString
                autocompleteManager.addToRecents(searchString!)
                print("Number of recents: \(autocompleteManager.recentsList.count)")
                self.performSegue(withIdentifier: "PresidentsWebSearch", sender: self)
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            if autocompleteManager.recentsList == list! {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if editingStyle == UITableViewCellEditingStyle.delete {
                if autocompleteManager.recentsList == list! {
                    autocompleteManager.removeRecent(indexPath.row)
                    list = autocompleteManager.recentsListSorted
                    self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
                    if list!.isEmpty {
                        clearButtonItem?.isEnabled = false
                        clearButtonItem?.title = "Clear"
                    }
                }
            }
        }
    }
    
    @IBAction func editingDidChange(_ sender: UITextField) {
        listTitle = "Recents"
        let autocompleteField: UITextField = sender
        if autocompleteField.text!.isEmpty {
            list = autocompleteManager.recentsListSorted
            if !list!.isEmpty {
                clearButtonItem?.isEnabled = true
                clearButtonItem?.title = "Clear"
            }
        } else {
            listTitle = "Presidents"
            clearButtonItem?.isEnabled = false
            // There is no hidden property for this type of button
            clearButtonItem?.title = ""
            
            // Use the built in filtering to match any contained text
            list = autocompleteManager.updateListMatchAny(autocompleteField.text!)

            // Use a closure to pass a filter that must match the prefix or the suffix
//            list = autocompleteManager.updateList({ $0.lowercaseString.hasPrefix(autocompleteField.text.lowercaseString) || $0.lowercaseString.hasSuffix(autocompleteField.text.lowercaseString)})

        }
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let newSearchString: String = list?.first {
            searchString = newSearchString
            autocompleteManager.addToRecents(searchString!)
            
            self.performSegue(withIdentifier: "PresidentsWebSearch", sender: self)
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Searching for: \(searchString)")
        let webViewController = segue.destination as! WebViewController
        
        let searchComponents = searchString!.components(separatedBy: " ")
        
        var fullName: String = String()
        for name in searchComponents {
            fullName += "_"
            fullName += name
        }
        
        fullName = fullName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("\(fullName)")
        
        // Format for Wikipedia and encode
        let urlString = "https://en.wikipedia.org/wiki/"
        var urlPath = urlString + fullName
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        webViewController.urlPath = urlPath
    }
    
    @IBAction func clearRecents(_ sender: AnyObject) {
        print("Clear recents")
        autocompleteManager.clearRecents()
        list = autocompleteManager.recentsListSorted
        clearButtonItem!.isEnabled = false
        self.tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.fade)
    }
}

