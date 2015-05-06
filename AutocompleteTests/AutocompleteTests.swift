//
//  AutocompleteTests.swift
//  AutocompleteTests
//
//  Created by Timothy P Miller on 2/18/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit
import XCTest

class AutocompleteProjectTests: XCTestCase {
    var autocompleteManager = AutocompleteManager()
    var alphabetStringArray: Array<String>!
    var negativeStringArray: Array<String>!
    var positiveStringArray: Array<String>!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        autocompleteManager.loadDataFrom(name: "world_cities", type: "txt")
        alphabetStringArray = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        negativeStringArray = ["aaa","bbb","ccc","ddd","eee","fff","ggg","hhh","iii","jjj","kkk","lll","mmm","nnn","ooo","ppp","qqq","rrr","sss","ttt","uuu","vvv","www","xxx","yyy","zzz"]
        positiveStringArray = ["ama","bar","col","dal","eas","for","gua","ham","iba","jam","kan","lon","mac","nor","oka","pal","qui","ran","sev","tak","ula","val","win","xia","yan","zag"]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceArray() {
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for string in self.alphabetStringArray {
                var list: Array<String> = self.autocompleteManager.updateListMatchPrefix(string)
            }
        }
    }
    
    func testPerformanceNegativeStringArray() {
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for string in self.negativeStringArray {
                var list: Array<String> = self.autocompleteManager.updateListMatchPrefix(string)
            }
        }
    }

    func testPerformancePositiveStringArray() {
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for string in self.positiveStringArray {
                var list: Array<String> = self.autocompleteManager.updateListMatchPrefix(string)
            }
        }
    }

    func testPerformanceArrayWithClosure() {
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            for string in self.alphabetStringArray {
                var list: Array<String> = self.autocompleteManager.updateList({ $0.lowercaseString.hasPrefix(string.lowercaseString) })
            }
        }
    }
}
