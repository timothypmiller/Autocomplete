//
//  AutocompleteManager.swift
//  Autocomplete
//
//  Created by Timothy P Miller on 3/2/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit

open class AutocompleteManager: NSObject, NSURLConnectionDataDelegate {
    fileprivate var dataList: Array<String> = []
    var recentsList: Array<String>
    var autocompleteList: Array<String> = []
    var recentsListSorted: Array<String> {
        // Return sorted copy
        return recentsList.sorted { $0 < $1 }
    }
    
    fileprivate var fileData : NSMutableData!

    override init () {
        recentsList = Array<String>()
    }
    
    /// Returns an array of strings that starts with the provided text
    public final func updateListMatchPrefix(_ autocompleteText: String) -> Array<String> {
        autocompleteList = dataList.filter { $0.lowercased().hasPrefix(autocompleteText.lowercased()) }
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }
    
    /// Returns an array of strings that ends with the provided text
    public final func updateListMatchSuffix(_ autocompleteText: String) -> Array<String> {
        autocompleteList = dataList.filter { $0.lowercased().hasSuffix(autocompleteText.lowercased()) }
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }

    /// Returns an array of strings that contains the provided text
    public final func updateListMatchAny(_ autocompleteText: String) -> Array<String> {
        autocompleteList = Array<String>()
        for text in dataList {
            if let _ = text.lowercased().range(of: autocompleteText.lowercased(), options: .regularExpression) {
                autocompleteList.append(text)
            }
        }
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }

    /// Returns an array of strings that matches the boolean filter
    public final func updateList(_ filter: (String) -> Bool) -> Array<String> {
        autocompleteList = dataList.filter(filter)
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }

    /// Adds the string to the recents list if it doesn't exist in the list
    open func addToRecents(_ string: String) {
        if !recentsList.contains(string) {
            recentsList.append(string)
        }
    }

    /// Removes all of the strings from the recents list
    open func clearRecents() {
        recentsList.removeAll(keepingCapacity: false)
    }

    /// Removes the string from the recents list at index
    open func removeRecent(_ index: Int) {
        recentsList.remove(at: index)
    }
    
    /// Reads the text from the provided file
    open func loadDataFrom(name: String, type: String) {
        let data = extractDataFromFile(name: name, type: type)
        dataList = data.components(separatedBy: CharacterSet.newlines)
    }
    
    fileprivate func extractDataFromFile(name: String, type: String) -> String {
        let path = Bundle.main.path(forResource: name, ofType: type)
        let content = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        return content
    }
    
    /// Reads the text from the provided URL
    open func loadDataFromURL(name: String) {
        if let url = URL(string:name) {
            let urlRequest = URLRequest(url: url)
            _ = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        }
    }
    
    @objc open func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        print("Did receive response")
        self.fileData = NSMutableData()
    }
    
    @objc open func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.fileData.append(data)
    }
    
    @objc open func connectionDidFinishLoading(_ connection: NSURLConnection) {
        print("Did finish loading")
        let data = NSString(data: fileData as Data, encoding: String.Encoding.utf8.rawValue) as! String
        dataList = data.components(separatedBy: CharacterSet.newlines)
    }
    
    @objc open func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print("Did fail with error \(error.localizedDescription)")
    }
}
