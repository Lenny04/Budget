//
//  Detail.swift
//  Budget
//
//  Created by linoj ravindran on 19/04/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import Foundation
import UIKit

class Detail {
    var detaljeNavn = "", keyID = ""
    var beløb = 0
    init(detaljeNavn: String, beløb: Int, keyID: String)
    {
        self.detaljeNavn = detaljeNavn
        self.keyID = keyID
        self.beløb = beløb
    }
    public func getName() -> String {
        return detaljeNavn
    }
    public func setName(a: String){
        detaljeNavn = a
    }
    public func getKeyID() -> String {
        return keyID
    }
    public func setKeyID(b: String){
        keyID = b
    }
    public func getBeløb() -> Int {
        return beløb
    }
    public func setBeløb(c: Int){
        beløb = c
    }
}
