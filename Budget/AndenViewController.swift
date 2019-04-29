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
import FirebaseAuth
import Floaty
class AndenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate{
    var budgetNavnForSegue = "", keysForSegue = ""
    var pengeForSegue = 0, udgifterForSegue = 0, indtægterForSegue = 0, midOmkostninger = 0, pengeTilbageForSegue = 0
    var allBudgets = [Budget]()
    var penge = 0, budget = 0, udgifter = 0, indtægter = 0, samletOmkostninger = 0, beløbtilrådighedmidlertidig = 0
    var midlertidigeIndtægter = 0, midlertidigeUdgifter = 0, currentIndex = 0
    @IBOutlet weak var listTableView: UITableView!
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    var counter = 0
    var refreshControl: UIRefreshControl!
//    @IBOutlet var floaty: Floaty!
    override func viewDidAppear(_ animated: Bool) {
        self.listTableView.reloadData()
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //tabBarController!.selectedIndex = 1
        Auth.auth().signIn(withEmail: "test@hotmail.com", password: "123456") { user, error in
            if error == nil && user != nil{
                //print("Logged in!")
            }
            else{
                //print("Login failed!")
            }
        }
        let f = Floaty()

        f.addItem("Detaljerede budgetter", icon: UIImage(named: "write_new"), titlePosition: .left) { (item) in
            //self.performSegue(withIdentifier: "piechart", sender: self)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Detailed") as UIViewController
            self.navigationController?.pushViewController(vc, animated: true)
            f.close()
        }
        f.addItem("Piechart oversigt", icon: UIImage(named: "Piechart"), titlePosition: .left) { (item) in
            self.performSegue(withIdentifier: "piechart", sender: self)
            f.close()
        }
        f.addItem("Tilføj nyt Budget", icon: UIImage(named: "write_new"), titlePosition: .left) { (item) in
            self.addBudget()
            f.close()
        }
        f.itemTitleColor = UIColor.white
        f.fabDelegate = self
        self.view.addSubview(f)
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(AndenViewController.refresh), for:.valueChanged)
        listTableView.addSubview(refreshControl)
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        listTableView.addGestureRecognizer(longPressRecognizer)
        ref = Database.database().reference()
        
        databaseHandle = ref.child("Budget").child("Simple").observe(.childAdded, with: { (snapshot) -> Void in
            self.allBudgets.append(Budget(budgetnavn: "", beløbtilrådighed: 0, samledeudgifter: 0, samledeindtægter: 0, samletomkostninger: 0, pengeTilbage: 0, keyID: snapshot.key))
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Budget navn"){
                    self.allBudgets[self.allBudgets.count-1].setName(name: value as! String)
                }
                else if(notenu == "Beløb til rådighed"){
                    self.allBudgets[self.allBudgets.count-1].setbeløbtilrådighed(b: value as! Int)
                }
                else if(notenu == "Foreløbige samlede udgifter"){
                    self.allBudgets[self.allBudgets.count-1].setsamledeudgifter(c: value as! Int)
                }
                else if(notenu == "Foreløbige samlede indtægter"){
                    self.allBudgets[self.allBudgets.count-1].setsamledeindtægter(d: value as! Int)
                }
                else if(notenu == "Penge tilbage"){
                    self.allBudgets[self.allBudgets.count-1].setPengeTilbage(f: value as! Int)
                }
                else if(notenu == "Samlede omkostninger"){
                    self.allBudgets[self.allBudgets.count-1].setsamledeomkostninger(e: value as! Int)
                }
                self.listTableView.reloadData()
            }
            //self.counter += 1
            self.ref.keepSynced(true)
        })
        databaseHandle = ref.child("Budget").child("Simple").observe(.childRemoved, with: { (snapshot) -> Void in
            self.listTableView.reloadData()
            self.ref.keepSynced(true)
        })
        databaseHandle = ref.child("Budget").child("Simple").observe(.childChanged, with: { (snapshot) -> Void in
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Budget navn"){
                    self.allBudgets[self.currentIndex].setName(name: value as! String)
                }
                else if(notenu == "Beløb til rådighed"){
                    self.allBudgets[self.currentIndex].setbeløbtilrådighed(b: value as! Int)
                }
                else if(notenu == "Foreløbige samlede udgifter"){
                    self.allBudgets[self.currentIndex].setsamledeudgifter(c: value as! Int)
                }
                else if(notenu == "Foreløbige samlede indtægter"){
                    self.allBudgets[self.currentIndex].setsamledeindtægter(d: value as! Int)
                }
                else if(notenu == "Penge tilbage"){
                    self.allBudgets[self.currentIndex].setPengeTilbage(f: value as! Int)
                    
                }
                else if(notenu == "Samlede omkostninger"){
                    self.allBudgets[self.currentIndex].setsamledeomkostninger(e: value as! Int)
                }
            }
            //self.allBudgets[self.currentIndex].toString()
            self.listTableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func tilbage(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "FirstViewController")
        self.present(controller!, animated: true, completion: nil)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allBudgets.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! CustomTableViewCell
        cell.tekst1.text = self.allBudgets[indexPath.row].getName()
        //self.allBudgets[indexPath.row].toString()
        cell.tekst2.text =  ("\(String(self.allBudgets[indexPath.row].getpengetilbage())) kr")
        cell.tekst3.text = ("\(self.allBudgets[indexPath.row].getsamletomkostninger())/ \(self.allBudgets[indexPath.row].getbeløbtilrådighed()) kr")
        let usageInPercentage = (Double(Double(self.allBudgets[indexPath.row].getsamletomkostninger())/Double(self.allBudgets[indexPath.row].getbeløbtilrådighed())) * 100)
        if(usageInPercentage >= 0 && usageInPercentage <= 60){
            cell.tekst2.textColor = UIColor(red:0.00, green:0.67, blue:0.06, alpha:1.0) //Black color
            cell.procesbar.progressTintColor = UIColor(red:0.00, green:0.67, blue:0.06, alpha:1.0) //Green color
            cell.procesbar.trackTintColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0) //Light gray color
            let mid1 = Float(self.allBudgets[indexPath.row].getpengetilbage())
            let mid2 = Float(self.allBudgets[indexPath.row].getbeløbtilrådighed())
            cell.procesbar.setProgress(1-(mid1/mid2), animated: true)
        }
        else if(usageInPercentage > 60 && usageInPercentage <= 90){
            cell.tekst2.textColor = UIColor(red:0.00, green:0.67, blue:0.06, alpha:1.0) //Black color
            cell.procesbar.progressTintColor = UIColor(red: 0.949, green: 0.9333, blue: 0, alpha: 1.0) //Yellow color
            cell.procesbar.trackTintColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0) //Light gray color
            let mid1 = Float(self.allBudgets[indexPath.row].getpengetilbage())
            let mid2 = Float(self.allBudgets[indexPath.row].getbeløbtilrådighed())
            cell.procesbar.setProgress(1-(mid1/mid2), animated: true)
        }
        else if(usageInPercentage > 90){
            cell.tekst2.textColor = UIColor.red
            cell.procesbar.progressTintColor = UIColor.red
            cell.procesbar.trackTintColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0) //Light gray color
            let mid1 = Float(self.allBudgets[indexPath.row].getpengetilbage())
            let mid2 = Float(self.allBudgets[indexPath.row].getbeløbtilrådighed())
            cell.procesbar.setProgress(1-(mid1/mid2), animated: true)
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
        _ = tableView.cellForRow(at: indexPath)! as! CustomTableViewCell
        //let controller = storyboard?.instantiateViewController(withIdentifier: "TredjeViewController")
        //self.present(controller!, animated: true, completion: nil)
        performSegue(withIdentifier: "tilTredjeViewController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            let currentkey = self.allBudgets[indexPath.row].getKeyID()
            self.ref?.child("Budget").child(currentkey).removeValue()
            self.allBudgets.remove(at: indexPath.row)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tilTredjeViewController") {
            //if let destinationVC = segue.destination as? UINavigationController{
            if let destinationVC = segue.destination as? TredjeViewController{
            //var viewController = segue.destination as! TredjeViewController
            currentIndex = (listTableView.indexPathForSelectedRow?.row)!
                destinationVC.budget = allBudgets[currentIndex]
            }
        }
    }
    public func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func tilføj(_ sender: UIButton) {
        self.addBudget()
    }
    @objc func refresh() {
        listTableView.reloadData()
        refreshControl.endRefreshing()
    }
    func addBudget(){
        let alertController = UIAlertController(title: "Nyt Budget", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Tilføj", style: .default) { (_) in
            if ((alertController.textFields?[0].text?.count)! >= 1){
                if ((alertController.textFields?[1].text?.count)! >= 1){
                    if ((alertController.textFields?[2].text?.count)! >= 1){
                        if ((alertController.textFields?[3].text?.count)! >= 1){
                            let i1 = Int(alertController.textFields![2].text!)
                            let i2 = Int(alertController.textFields![3].text!)
                            self.samletOmkostninger = i1! - i2!
                            self.penge = Int((alertController.textFields?[1].text)!)! - self.samletOmkostninger
                            self.beløbtilrådighedmidlertidig = Int(alertController.textFields![1].text!)!
                            let post2 : [String : Any] = ["Budget navn" : alertController.textFields![0].text!, "Beløb til rådighed" : self.beløbtilrådighedmidlertidig, "Foreløbige samlede udgifter" : i1!, "Foreløbige samlede indtægter" : i2!, "Samlede omkostninger" : self.samletOmkostninger, "Penge tilbage" : self.penge]
                            self.ref?.child("Budget").child("Simple").childByAutoId().setValue(post2)
                        }
                        else{
                            // user did not fill samlede indtægter field
                            let i1 = Int(alertController.textFields![2].text!)
                            self.samletOmkostninger = i1!
                            self.penge = Int((alertController.textFields?[1].text)!)! - self.samletOmkostninger
                            self.beløbtilrådighedmidlertidig = Int(alertController.textFields![1].text!)!
                            let post2 : [String : Any] = ["Budget navn" : alertController.textFields![0].text!, "Beløb til rådighed" : self.beløbtilrådighedmidlertidig, "Foreløbige samlede udgifter" : i1!, "Foreløbige samlede indtægter" : 0, "Samlede omkostninger" : self.samletOmkostninger, "Penge tilbage" : self.penge]
                            self.ref?.child("Budget").child("Simple").childByAutoId().setValue(post2)
                        }
                    }
                    else{
                        // user did not fill samlede udgifter field
                        self.beløbtilrådighedmidlertidig = Int(alertController.textFields![1].text!)!
                        let post2 : [String : Any] = ["Budget navn" : alertController.textFields![0].text!, "Beløb til rådighed" : self.beløbtilrådighedmidlertidig, "Foreløbige samlede udgifter" : 0, "Foreløbige samlede indtægter" : 0, "Samlede omkostninger" : 0, "Penge tilbage" : self.beløbtilrådighedmidlertidig]
                        self.ref?.child("Budget").child("Simple").childByAutoId().setValue(post2)
                    }
                }
                else{
                    // user did not fill beløb til rådighed field
                }
            } else {
                // user did not fill name field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in }
        
        alertController.addTextField { (textField0) in
            textField0.placeholder = "Budget navn"
            textField0.autocapitalizationType = .sentences
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
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func longPress(_ guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizer.State.began {
            let point = guesture.location(in: listTableView)
            let indexPath = listTableView.indexPathForRow(at: point)
            currentIndex = indexPath!.row
            let editInfo = UIAlertController(title: nil, message: "Details", preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in
                
            })
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
                if(!(editInfo.textFields![0].text?.isEmpty)!){
                    //Budget name has been changed!
                    if(!(editInfo.textFields![1].text?.isEmpty)!){
                        //BeløbTilRådighed has been changed!
                        let changedName = editInfo.textFields![0].text
                        let changedBeløbTilRådighed = Int(editInfo.textFields![1].text!)
                        //let fsu = self.allBudgets[indexPath!.row].getsamledeudgifter()
                        //let fsi = self.allBudgets[indexPath!.row].getsamledeindtægter()
                        let so = self.allBudgets[indexPath!.row].getsamletomkostninger()
                        let pi = changedBeløbTilRådighed! - so
                        let index = self.allBudgets[indexPath!.row].getKeyID()
                        
//                        let post2 : [String : Any] = ["Budget navn" : changedName!, "Beløb til rådighed" : changedBeløbTilRådighed!,
//                            "Foreløbige samlede udgifter" : fsu, "Foreløbige samlede indtægter" : fsi, "Samlede omkostninger" : so, "Penge tilbage" : pi]
//                        let childUpdates = ["/Budget/Simple\(index)": post2]
//                        self.ref.updateChildValues(childUpdates)
                        
                        self.ref.child("Budget").child("Simple").child(index).updateChildValues(["Budget navn" : changedName!, "Beløb til rådighed" : changedBeløbTilRådighed!, "Penge tilbage" : pi])
                    }
                }
            })
            
            editInfo.addTextField { (textField0) in
                textField0.text = String(self.allBudgets[(indexPath?.row)!].getName())
                textField0.autocapitalizationType = .sentences
            }
            editInfo.addTextField { (textField1) in
                textField1.text = String(self.allBudgets[(indexPath?.row)!].getbeløbtilrådighed())
                textField1.keyboardType = .numberPad
            }
            
            editInfo.addAction(cancelAction)
            editInfo.addAction(saveAction)
            self.present(editInfo, animated: true, completion: nil)
        }
    }
}


