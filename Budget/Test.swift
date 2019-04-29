//
//  Test.swift
//  Budget
//
//  Created by linoj ravindran on 18/02/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
class Test {
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    var TestList = [Budget]()
    func tilføj() -> Bool{
        ref = Database.database().reference()
        let post2 : [String : Any] = ["Budget navn" : "Test", "Beløb til rådighed" : 10, "Foreløbige samlede udgifter" : 5, "Foreløbige samlede indtægter" : 0, "Samlede omkostninger" : 5, "Penge tilbage" : 5]
        self.ref?.child("Budget").childByAutoId().setValue(post2)
        databaseHandle = ref.child("Budget").observe(.childAdded, with: { (snapshot) -> Void in
            self.TestList.append(Budget(budgetnavn: "", beløbtilrådighed: 0, samledeudgifter: 0, samledeindtægter: 0, samletomkostninger: 0, pengeTilbage: 0, keyID: snapshot.key))
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Budget navn"){
                    self.TestList[self.TestList.count-1].setName(name: value as! String)
                    
                }
                else if(notenu == "Beløb til rådighed"){
                    self.TestList[self.TestList.count-1].setbeløbtilrådighed(b: value as! Int)
                }
                else if(notenu == "Foreløbige samlede udgifter"){
                    self.TestList[self.TestList.count-1].setsamledeudgifter(c: value as! Int)
                }
                else if(notenu == "Foreløbige samlede indtægter"){
                    self.TestList[self.TestList.count-1].setsamledeindtægter(d: value as! Int)
                }
                else if(notenu == "Penge tilbage"){
                    self.TestList[self.TestList.count-1].setPengeTilbage(f: value as! Int)
                }
                else if(notenu == "Samlede omkostninger"){
                    self.TestList[self.TestList.count-1].setsamledeomkostninger(e: value as! Int)
                }
            }
        })
        print("Count: \(self.TestList.count)")
        if(TestList.count > 0){
            print("Her")
            for budget in TestList {
                print("Check name: \(budget.budgetnavn)")
                if(budget.budgetnavn == "Test"){
                    print("Test 1 fuldført!")
                    return true
                }
            }
        }
        print("Test 1 fejl!")
        return false
    }
    func slet() -> Bool{
        let currentkey = self.TestList[0].getKeyID()
        self.ref?.child("Budget").child(currentkey).removeValue()
        self.TestList.remove(at: 0)
        if(TestList.count == 0){
            print("Test 2 fuldført!")
            return true
        }
        print("Test 2 fejl!")
        return false
    }
}
