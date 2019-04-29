//
//  Budget.swift
//  Budget
//
//  Created by linoj ravindran on 29/04/2017.
//  Copyright © 2017 linoj ravindran. All rights reserved.
//

import Foundation
import UIKit

class Budget {
    var beløbtilrådighed = 0, samledeudgifter = 0, samledeindtægter = 0, samletomkostninger = 0, pengeTilbage = 0
    var budgetnavn = "", keyID = ""
    init(budgetnavn: String, beløbtilrådighed: Int, samledeudgifter: Int, samledeindtægter: Int, samletomkostninger: Int,
         pengeTilbage: Int, keyID: String) {
        self.budgetnavn = budgetnavn
        self.beløbtilrådighed = beløbtilrådighed
        self.samledeudgifter = samledeudgifter
        self.samledeindtægter = samledeindtægter
        self.samletomkostninger = samletomkostninger
        self.pengeTilbage = pengeTilbage
        self.keyID = keyID
    }
    public func getName() -> String {
        return budgetnavn
    }
    public func setName(name: String){
        budgetnavn = name
    }
    public func getbeløbtilrådighed() -> Int {
        return beløbtilrådighed
    }
    public func setbeløbtilrådighed(b: Int){
        beløbtilrådighed = b
    }
    public func getsamledeudgifter() -> Int {
        return samledeudgifter
    }
    public func setsamledeudgifter(c: Int){
        samledeudgifter = c
    }
    public func getsamledeindtægter() -> Int {
        return samledeindtægter
    }
    public func setsamledeindtægter(d: Int){
        samledeindtægter = d
    }
    public func getsamletomkostninger() -> Int {
        return samletomkostninger
    }
    public func setsamledeomkostninger(e: Int){
        samletomkostninger = e
    }
    public func getpengetilbage() -> Int {
        return pengeTilbage
    }
    public func setPengeTilbage(f: Int){
        pengeTilbage = f
    }
    public func getKeyID() -> String {
        return keyID
    }
    public func setKeyID(G: String){
        keyID = G
    }
    public func toString(){
        print("\(budgetnavn), \(beløbtilrådighed), \(samledeudgifter), \(samledeindtægter), \(samletomkostninger), \(pengeTilbage), \(keyID)")
    }
}
