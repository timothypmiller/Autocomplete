//
//  AutocompleteManager.swift
//  Autocomplete
//
//  Created by Timothy P Miller on 3/2/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit

public class AutocompleteManager: NSObject, NSURLConnectionDataDelegate {
    private var dataList: Array<String> = []
    var recentsList: Array<String>
    var autocompleteList: Array<String> = []
    var recentsListSorted: Array<String> {
        // Return sorted copy
        return recentsList.sorted { $0 < $1 }
    }
    
    private var fileData : NSMutableData!

    override init () {
        recentsList = Array<String>()
    }
    
    /// Returns an array of strings that starts with the provided text
    public final func updateListMatchPrefix(autocompleteText: String) -> Array<String> {
        autocompleteList = dataList.filter { $0.lowercaseString.hasPrefix(autocompleteText.lowercaseString) }
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }
    
    /// Returns an array of strings that ends with the provided text
    public final func updateListMatchSuffix(autocompleteText: String) -> Array<String> {
        autocompleteList = dataList.filter { $0.lowercaseString.hasSuffix(autocompleteText.lowercaseString) }
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }

    /// Returns an array of strings that contains the provided text
    public final func updateListMatchAny(autocompleteText: String) -> Array<String> {
        autocompleteList = Array<String>()
        for text in dataList {
            if let match = text.lowercaseString.rangeOfString(autocompleteText.lowercaseString, options: .RegularExpressionSearch) {
                autocompleteList.append(text)
            }
        }
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }

    /// Returns an array of strings that matches the boolean filter
    public final func updateList(filter: (String) -> Bool) -> Array<String> {
        autocompleteList = dataList.filter(filter)
        autocompleteList.sort { $0 < $1 }
        
        return autocompleteList
    }

    /// Adds the string to the recents list if it doesn't exist in the list
    public func addToRecents(string: String) {
        if !contains(recentsList, string) {
            recentsList.append(string)
        }
    }

    /// Removes all of the strings from the recents list
    public func clearRecents() {
        recentsList.removeAll(keepCapacity: false)
    }

    /// Removes the string from the recents list at index
    public func removeRecent(index: Int) {
        recentsList.removeAtIndex(index)
    }
    
    /// Reads the text from the provided file
    public func loadDataFrom(#name: String, type: String) {
        var data = extractDataFromFile(name: name, type: type)
        dataList = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
    
    private func extractDataFromFile(#name: String, type: String) -> String {
        let path = NSBundle.mainBundle().pathForResource(name, ofType: type)
        let content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        
        return content
    }
    
    /// Reads the text from the provided URL
    public func loadDataFromURL(#name: String) {
        if let url = NSURL(string:name) {
            var urlRequest = NSURLRequest(URL: url)
            let connection = NSURLConnection(request: urlRequest, delegate: self, startImmediately: true)
        }
    }
    
    private func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        println("Did receive response")
        self.fileData = NSMutableData()
    }
    
    private func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.fileData.appendData(data)
    }
    
    private func connectionDidFinishLoading(connection: NSURLConnection) {
        println("Did finish loading")
        var data = NSString(data: fileData, encoding: NSUTF8StringEncoding) as! String
        dataList = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
    
    private func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("Did fail with error \(error.description)")
    }
}
