//
//  ViewController.swift
//  Budget
//
//  Created by linoj ravindran on 16/02/2017.
//  Copyright © 2017 linoj ravindran. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn
class AndenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var budgetNavn = [String]()
    var budgetNavnForSegue = "", keysForSegue = ""
    var pengeForSegue = 0, udgifterForSegue = 0, indtægterForSegue = 0, midOmkostninger = 0, midPenge = 0
    var pengeTilbage = [Int](), beløbTilRådighed = [Int](), samledeUdgifter = [Int](), samledeIndtægter = [Int]()
    var penge = 0, budget = 0, udgifter = 0, indtægter = 0, samletOmkostninger = 0, beløbtilrådighedmidlertidig = 0
    var midlertidigeIndtægter = 0, midlertidigeUdgifter = 0, currentIndex = 0
    var keys = [String]()
    var update = false
    @IBOutlet var budgetTabBar: UITabBar!
    @IBOutlet var budgetTabBarItem1: UITabBarItem!
    @IBOutlet weak var listTableView: UITableView!
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        var databaseHandle: FIRDatabaseHandle
        ref = FIRDatabase.database().reference()
        budgetTabBar.selectedItem = budgetTabBar.items![1]
        databaseHandle = ref.child("Budget").observe(.childAdded, with: { (snapshot) -> Void in
            self.keys.append(snapshot.key)
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Budget navn"){
                    self.budgetNavn.append(value as! String)
                }
                else if(notenu == "Beløb til rådighed"){
                    self.beløbTilRådighed.append(value as! Int)
                    
                }
                else if(notenu == "Penge tilbage"){
                    self.pengeTilbage.append(value as! Int)
                }
                else if(notenu == "Foreløbige samlede udgifter"){
                    self.samledeUdgifter.append(value as! Int)
                }
                else if(notenu == "Foreløbige samlede indtægter"){
                    self.samledeIndtægter.append(value as! Int)
                }
                self.listTableView.reloadData()
            }
            //let notenu = value1?["Note"] as? String ?? ""
            //let checkednu = value1?["Checked"] as? Bool
            //for rest in snapshot.children.allObjects as! [FIRDataSnapshot] {
            //  self.posts.append(rest.value as! String)
            //}
        })
        if update == true {
            self.ref?.child("Budget").child(keysForSegue).updateChildValues(["Foreløbige samlede udgifter" : udgifterForSegue])
            self.ref?.child("Budget").child(keysForSegue).updateChildValues(["Foreløbige samlede indtægter" : indtægterForSegue])
            //self.midOmkostninger = udgifterForSegue - indtægterForSegue
            self.ref?.child("Budget").child(keysForSegue).updateChildValues(["Samlede omkostninger" : self.midOmkostninger])
            //self.midPenge = pengeForSegue - midOmkostninger
            self.ref?.child("Budget").child(keysForSegue).updateChildValues(["Penge tilbage" : self.midPenge])
            update = false
        }
        else{
        }
        databaseHandle = ref.child("Budget").observe(.childRemoved, with: { (snapshot) -> Void in
            self.listTableView.reloadData()
        })
        databaseHandle = ref.child("Budget").observe(.childChanged, with: { (snapshot) -> Void in
            self.pengeTilbage[self.currentIndex] = self.midPenge
            self.listTableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func tilbage(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "FirstViewController")
        self.present(controller!, animated: true, completion: nil)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgetNavn.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! CustomTableViewCell
        cell.tekst1.text = budgetNavn[indexPath.row]
        cell.tekst2.text = String(pengeTilbage[indexPath.row])
        if pengeTilbage[indexPath.row] > 0 {
            cell.tekst2.textColor = UIColor.green
            cell.procesbar.progressTintColor = UIColor(hue: 0.5694, saturation: 1, brightness: 1, alpha: 1.0)
            cell.procesbar.trackTintColor = UIColor.lightGray
            let mid1 = Float(pengeTilbage[indexPath.row])
            let mid2 = Float(beløbTilRådighed[indexPath.row])
            cell.procesbar.setProgress(1-(mid1/mid2), animated: true)
        }
        else if pengeTilbage[indexPath.row] < 0{
            cell.tekst2.textColor = UIColor.red
            cell.procesbar.progressTintColor = UIColor.red
            cell.procesbar.setProgress(1.0, animated: true)
        }
        else{
            cell.tekst2.textColor = UIColor.black
            cell.procesbar.setProgress(1.0, animated: true)
            cell.procesbar.progressTintColor = UIColor(hue: 0.5694, saturation: 1, brightness: 1, alpha: 1.0)
        }
        return cell
    }
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomTableViewCell
        //let i = budgetNavn[indexPath.row]
        //let controller = storyboard?.instantiateViewController(withIdentifier: "TredjeViewController")
        //self.present(controller!, animated: true, completion: nil)
        performSegue(withIdentifier: "tilTredjeViewController", sender: self)
    }
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            //self.ref?.child("Budgetter").child(key1!).removeValue()
            self.ref?.child("Budget").child(budgetNavn[indexPath.row]).removeValue()
            self.budgetNavn.remove(at: indexPath.row)
            self.beløbTilRådighed.remove(at: indexPath.row)
            self.pengeTilbage.remove(at: indexPath.row)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tilTredjeViewController") {
            if let destinationVC = segue.destination as? TredjeViewController{
            //var viewController = segue.destination as! TredjeViewController
            currentIndex = (listTableView.indexPathForSelectedRow?.row)!
            destinationVC.budgetNavn2 = budgetNavn[currentIndex]
            destinationVC.indtægter2 = samledeIndtægter[currentIndex]
            destinationVC.udgifter2 = samledeUdgifter[currentIndex]
            destinationVC.keys2 = keys[currentIndex]
            destinationVC.beløbTilRådighed2 = beløbTilRådighed[currentIndex]
            }
        }
    }
    public func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        self.listTableView.reloadData()
    }
    @IBAction func tilføj(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Tilføj Budget", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Tilføj", style: .default) { (_) in
            if ((alertController.textFields?[0].text?.characters.count)! >= 1){
                if ((alertController.textFields?[1].text?.characters.count)! >= 1){
                    if ((alertController.textFields?[2].text?.characters.count)! >= 1){
                        if ((alertController.textFields?[3].text?.characters.count)! >= 1){
                            let i1 = Int(alertController.textFields![2].text!)
                            let i2 = Int(alertController.textFields![3].text!)
                            self.samletOmkostninger = i1! - i2!
                            self.penge = Int((alertController.textFields?[1].text)!)! - self.samletOmkostninger
                            self.beløbtilrådighedmidlertidig = Int(alertController.textFields![1].text!)!
                            let post2 : [String : Any] = ["Budget navn" : alertController.textFields![0].text!, "Beløb til rådighed" : self.beløbtilrådighedmidlertidig, "Foreløbige samlede udgifter" : i1, "Foreløbige samlede indtægter" : i2, "Samlede omkostninger" : self.samletOmkostninger, "Penge tilbage" : self.penge]
                            self.ref?.child("Budget").childByAutoId().setValue(post2)
                            //self.ref?.child("Budget").childByAutoId().updateChildValues([AnyHashable : Any])
                        }
                        else{
                            // user did not fill samlede indtægter field
                            let i1 = Int(alertController.textFields![2].text!)
                            self.samletOmkostninger = i1!
                            self.penge = Int((alertController.textFields?[1].text)!)! - self.samletOmkostninger
                            self.beløbtilrådighedmidlertidig = Int(alertController.textFields![1].text!)!
                            let post2 : [String : Any] = ["Budget navn" : alertController.textFields![0].text!, "Beløb til rådighed" : self.beløbtilrådighedmidlertidig, "Foreløbige samlede udgifter" : i1, "Foreløbige samlede indtægter" : 0, "Samlede omkostninger" : self.samletOmkostninger, "Penge tilbage" : self.penge]
                            self.ref?.child("Budget").childByAutoId().setValue(post2)
                        }
                    }
                    else{
                        // user did not fill samlede udgifter field
                        self.samletOmkostninger = 0
                        self.penge = Int((alertController.textFields?[1].text)!)! - self.samletOmkostninger
                        self.beløbtilrådighedmidlertidig = Int(alertController.textFields![1].text!)!
                        let post2 : [String : Any] = ["Budget navn" : alertController.textFields![0].text!, "Beløb til rådighed" : self.beløbtilrådighedmidlertidig, "Foreløbige samlede udgifter" : 0, "Foreløbige samlede indtægter" : 0, "Samlede omkostninger" : self.samletOmkostninger, "Penge tilbage" : self.penge]
                        self.ref?.child("Budget").childByAutoId().setValue(post2)
                    }
                }
                else{
                    // user did not fill beløb til rådighed field
                    print("user did not fill beløb til rådighed field")
                }
            } else {
                // user did not fill name field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField0) in
            textField0.placeholder = "Budget navn"
        }
        alertController.addTextField { (textField1) in
            textField1.placeholder = "Beløb til rådighed"
            textField1.keyboardType = .numberPad
        }
        alertController.addTextField { (textField2) in
            textField2.placeholder = "Foreløbige samlede udgifter"
            textField2.keyboardType = .numberPad
        }
        alertController.addTextField { (textField3) in
            textField3.placeholder = "Foreløbige samlede indtægter"
            textField3.keyboardType = .numberPad
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}

