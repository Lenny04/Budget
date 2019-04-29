//
//  DetailedBudgetViewController.swift
//  Budget
//
//  Created by linoj ravindran on 12/04/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Floaty
class DetailedBudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FloatyDelegate{
    var detailedBudgets = [DetailedBudget]()
    var ref: DatabaseReference!
    var handle: DatabaseHandle?
    var databaseHandle: DatabaseHandle?
    var currentIndex = 0
    var visning = "Beløb tilbage"
    @IBOutlet weak var visningsKnap: UIBarButtonItem!
    @IBOutlet weak var detailedTableView: UITableView!
    var refreshControl: UIRefreshControl!
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailedTableView.rowHeight = 50
        let f = Floaty()
        f.addItem("Tilføj nyt Budget", icon: UIImage(named: "write_new"), titlePosition: .left) { (item) in
            self.addDetailedBudget()
            f.close()
        }
        f.itemTitleColor = UIColor.white
        f.fabDelegate = self
        self.view.addSubview(f)
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(DetailedBudgetViewController.refresh), for:.valueChanged)
        detailedTableView.addSubview(refreshControl)
        ref = Database.database().reference()
        self.detailedTableView.delegate = self
        self.detailedTableView.dataSource = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        detailedTableView.addGestureRecognizer(longPressRecognizer)
        handle = ref?.child("Budget").child("Detailed").observe(.childRemoved, with: { (snapshot) in
            self.detailedTableView.reloadData()
            self.ref.keepSynced(true)
        })
        handle = ref?.child("Budget").child("Detailed").observe(.childAdded, with: { (snapshot) in
            self.detailedBudgets.append(DetailedBudget(budgetnavn: "", totaltBeløb: 0, udgifter: 0, beløbTilRådighed: 0, keyID: snapshot.key))
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                switch notenu{
                case "Navn":
                    self.detailedBudgets[self.detailedBudgets.count-1].setName(a: value as! String)
                    break
                case "Total beløb":
                    self.detailedBudgets[self.detailedBudgets.count-1].setTotaltBeløb(e: value as! Int)
                    break
                case "Udgifter":
                    self.detailedBudgets[self.detailedBudgets.count-1].setUdgifter(d: value as! Int)
                    break
                case "Beløb til rådighed":
                    self.detailedBudgets[self.detailedBudgets.count-1].setBeløbTilRådighed(c: value as! Int)
                    break
                default:
                    self.detailedTableView.reloadData()
                }
                self.detailedTableView.reloadData()
                //print("Plads: \(self.detailedBudgets.count-1), \(self.detailedBudgets[self.detailedBudgets.count-1].getName()), \(self.detailedBudgets[self.detailedBudgets.count-1].getKeyID()), \(self.detailedBudgets[self.detailedBudgets.count-1].getUdgifter())")
            }
            self.detailedBudgets.sort {$0.budgetnavn < $1.budgetnavn}
            self.ref.keepSynced(true)
        })
        handle = ref.child("Budget").child("Detailed").observe(.childChanged, with: { (snapshot) -> Void in
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Navn"){
                    self.detailedBudgets[self.currentIndex].setName(a: value as! String)
                }
                else if(notenu == "Total beløb"){
                    self.detailedBudgets[self.currentIndex].setTotaltBeløb(e: value as! Int)
                }
                else if(notenu == "Udgifter"){
                    self.detailedBudgets[self.currentIndex].setUdgifter(d: value as! Int)
                }
                else if(notenu == "Beløb til rådighed"){
                    self.detailedBudgets[self.currentIndex].setBeløbTilRådighed(c: value as! Int)
                }
            }
            self.detailedTableView.reloadData()
            self.detailedBudgets.sort {$0.budgetnavn < $1.budgetnavn}
            self.ref.keepSynced(true)
        })
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detailedBudgets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailedTableView.dequeueReusableCell(withIdentifier: "ItemCell2", for: indexPath) as! DetailedTableViewCell
        var moneyText = detailedBudgets[indexPath.row].getBeløbTilrådighed()
        if(visning == "Beløb tilbage"){
            moneyText = detailedBudgets[indexPath.row].getBeløbTilrådighed()
            cell.rightText.text = "\(moneyText) kr"
            if(moneyText <= 0){
                cell.rightText.textColor = UIColor.red
            }
            else{
                cell.rightText.textColor = UIColor(red:0.00, green:0.67, blue:0.06, alpha:1.0)
            }
        }
        else if(visning == "Udgifter"){
            moneyText = detailedBudgets[indexPath.row].getUdgifter()
            cell.rightText.text = "\(moneyText) kr"
            cell.rightText.textColor = UIColor.black
        }
        cell.leftText.text = detailedBudgets[indexPath.row].getName()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = detailedTableView.dequeueReusableCell(withIdentifier: "ItemCell2", for: indexPath)
        performSegue(withIdentifier: "tilDetalje", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentKey = self.detailedBudgets[indexPath.row].getKeyID()
            self.ref?.child("Budget").child("Detailed").child(currentKey).removeValue()
            self.detailedBudgets.remove(at: indexPath.row)
        }
    }
    @objc func refresh() {
        detailedTableView.reloadData()
        refreshControl.endRefreshing()
    }
    func addDetailedBudget(){
        let alertController = UIAlertController(title: "Nyt detaljeret budget", message: "", preferredStyle: .alert)
        let tilføj = UIAlertAction(title: "Tilføj", style: .default) { (action:UIAlertAction) in
            if ((alertController.textFields?[0].text?.count)! >= 1){
                let characterSetNotAllowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz,.-<>$§!#€%&/()=?`^*¨'")
                if((alertController.textFields?[1].text?.count)! >= 1 && ((alertController.textFields?[1].text?.rangeOfCharacter(from: characterSetNotAllowed)) == nil)){
                    let post : [String : Any] = ["Navn" : alertController.textFields![0].text!, "Total beløb" : Int(alertController.textFields![1].text!)!, "Udgifter": 0, "Beløb til rådighed": Int(alertController.textFields![1].text!)!, "Details": ""]
                    self.ref?.child("Budget").child("Detailed").childByAutoId().setValue(post)
                }
                else{
                let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst total beløb. Det må kun indeholde tal!", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                }
            }
            else{
            let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst navn og total beløb", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action:UIAlertAction) in
            
        }
        alertController.addTextField { (textField0) in
            textField0.placeholder = "Budget navn"
            textField0.autocapitalizationType = .words
        }
        alertController.addTextField { (textField1) in
            textField1.placeholder = "Total beløb"
            textField1.keyboardType = .numberPad
        }
        alertController.addAction(cancel)
        alertController.addAction(tilføj)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func tilføj(_ sender: UIButton) {
        addDetailedBudget()
    }
    @IBAction func visning(_ sender: UIButton) {
        if(visning == "Beløb tilbage"){
            visning = "Udgifter"
            visningsKnap.title = "Vis beløb tilbage"
        }
        else{
            visning = "Beløb tilbage"
            visningsKnap.title = "Vis udgifter"
        }
        detailedTableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tilDetalje") {
            //if let destinationVC = segue.destination as? UINavigationController{
            if let destinationVC = segue.destination as? DetailsViewController{
                currentIndex = (detailedTableView.indexPathForSelectedRow?.row)!
                //let targetController = destinationVC.topViewController as! DetailsViewController
                destinationVC.budget = detailedBudgets[currentIndex]
            }
        }
    }
    @objc func longPress(_ guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizer.State.began {
            let point = guesture.location(in: detailedTableView)
            let indexPath = detailedTableView.indexPathForRow(at: point)
            if(indexPath != nil){
                currentIndex = indexPath!.row
                let editInfo = UIAlertController(title: nil, message: "Details", preferredStyle: UIAlertController.Style.alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in
                    
                })
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
                    if(!(editInfo.textFields![0].text?.isEmpty)!){
                        //Budget name has been changed!
                        let characterSetNotAllowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz,.-<>$§!#€%&/()=?`^*¨'")
                        if(!(editInfo.textFields![1].text?.isEmpty)! && editInfo.textFields![1].text?.rangeOfCharacter(from: characterSetNotAllowed) == nil){
                            //BeløbTilRådighed has been changed!
                            let changedName = editInfo.textFields![0].text
                            let changedTotalBeløb = Int(editInfo.textFields![1].text!)
                            let sammeUdgifter = Int(self.detailedBudgets[(indexPath?.row)!].getUdgifter())
                            let changedBeløbTilrådighed = changedTotalBeløb! - sammeUdgifter
                            let id = self.detailedBudgets[indexPath!.row].getKeyID()
                            
                            self.ref.child("Budget").child("Detailed").child(id).updateChildValues(["Navn" : changedName!, "Total beløb" : changedTotalBeløb!, "Beløb til rådighed" : changedBeløbTilrådighed])
                            self.detailedTableView.reloadData()
                        }
                        else{
                            let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst total beløb. Det må kun indeholde tal!", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    else{
                        let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst navn og total beløb", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
                
                editInfo.addTextField { (textField0) in
                    textField0.text = String(self.detailedBudgets[(indexPath?.row)!].getName())
                    textField0.autocapitalizationType = .sentences
                }
                editInfo.addTextField { (textField1) in
                    textField1.text = String(self.detailedBudgets[(indexPath?.row)!].getTotaltBeløb())
                    textField1.keyboardType = .numberPad
                }
                
                editInfo.addAction(cancelAction)
                editInfo.addAction(saveAction)
                self.present(editInfo, animated: true, completion: nil)
            }
            else{
                let alertController = UIAlertController(title: "Fejl", message: "Du har ikke valgt et budget!", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
