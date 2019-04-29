//
//  DetailedBudget.swift
//  Budget
//
//  Created by linoj ravindran on 12/04/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import Foundation
import UIKit

class DetailedBudget {
    var budgetnavn = "", keyID = ""
    var beløbTilrådighed = 0, udgifter = 0, totaltBeløb = 0
    var list = [String: Int]()
    init(budgetnavn: String, totaltBeløb: Int, udgifter: Int, beløbTilRådighed: Int, keyID: String)
    {
        self.budgetnavn = budgetnavn
        self.totaltBeløb = totaltBeløb
        self.udgifter = udgifter
        self.beløbTilrådighed = beløbTilRådighed
        self.keyID = keyID
    }
    public func getName() -> String {
        return budgetnavn
    }
    public func setName(a: String){
        budgetnavn = a
    }
    public func getKeyID() -> String {
        return keyID
    }
    public func setKeyID(b: String){
        keyID = b
    }
    public func getBeløbTilrådighed() -> Int {
        return beløbTilrådighed
    }
    public func setBeløbTilRådighed(c: Int){
        beløbTilrådighed = c
    }
    public func getUdgifter() -> Int {
        return udgifter
    }
    public func setUdgifter(d: Int){
        udgifter = d
    }
    public func getTotaltBeløb() -> Int {
        return totaltBeløb
    }
    public func setTotaltBeløb(e: Int){
        totaltBeløb = e
    }
}
