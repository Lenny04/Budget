//
//  Details.swift
//  Budget
//
//  Created by linoj ravindran on 19/04/2018.
//  Copyright © 2018 linoj ravindran. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Floaty
class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FloatyDelegate{
    var details = [Detail]()
    var filtered = [Detail]()
    var ref: DatabaseReference!
    var handle: DatabaseHandle?
    var databaseHandle: DatabaseHandle?
    var currentIndex = 0
    var budgetPengeTilrådighed = 0, budgetPengeTilbage = 0
    var opdateretUdgifter = 0, opdateretBeløbTilrådighed = 0
    var isSearching = false
    //var budgetID = "", budgetNavn = ""
    var budget = DetailedBudget(budgetnavn: "", totaltBeløb: 0, udgifter: 0, beløbTilRådighed: 0, keyID: "")
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var navigationbar: UINavigationItem!
    @IBOutlet weak var searchbar: UISearchBar!
    var refreshControl: UIRefreshControl!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailsTableView.rowHeight = 50
        canRotate()
        detailsTableView.reloadData()
        self.navigationItem.title = budget.getName()
        self.detailsTableView.contentInset.bottom = self.tabBarController?.tabBar.frame.height ?? 0
        let f = Floaty()
        f.addItem("Cirkel diagram", icon: UIImage(named: "Piechart"), titlePosition: .left) { (item) in
            self.performSegue(withIdentifier: "grafiskOverblik", sender: self)
            f.close()
        }
        f.addItem("Søjle diagram", icon: UIImage(named: "barChart"), titlePosition: .left) { (item) in
            self.performSegue(withIdentifier: "barchartOverblik", sender: self)
            f.close()
        }
        f.addItem("Test", icon: UIImage(named: "Piechart"), titlePosition: .left) { (item) in
            self.performSegue(withIdentifier: "Test_piechart", sender: self)
            f.close()
        }
        f.addItem("Tilføj ny udgift", icon: UIImage(named: "write_new"), titlePosition: .left) { (item) in
            self.addDetail()
            f.close()
        }
        f.addItem("Sorter efter beløb", icon: UIImage(named: "123"), titlePosition: .left) { (item) in
            if(item.title == "Sorter efter beløb"){
                self.details.sort {$0.beløb < $1.beløb}
                self.detailsTableView.reloadData()
                item.title = "Sorter efter titel"
                item.icon = UIImage(named: "ABC")
            }
            else if(item.title == "Sorter efter titel"){
                self.details.sort {$0.detaljeNavn < $1.detaljeNavn}
                self.detailsTableView.reloadData()
                item.title = "Sorter efter beløb"
                item.icon = UIImage(named: "123")
            }
            f.close()
        }
        f.itemTitleColor = UIColor.white
        f.fabDelegate = self
        self.view.addSubview(f)
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        refreshControl.addTarget(self, action: #selector(DetailsViewController.refresh), for:.valueChanged)
        detailsTableView.addSubview(refreshControl)
        ref = Database.database().reference()
        self.detailsTableView.delegate = self
        self.detailsTableView.dataSource = self
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        detailsTableView.addGestureRecognizer(longPressRecognizer)
        searchbar.delegate = self
        searchbar.returnKeyType = UIReturnKeyType.done
        handle = ref?.child("Budget").child("Detailed").child(budget.getKeyID()).child("Details").observe(.childRemoved, with: { (snapshot) in
            self.detailsTableView.reloadData()
            self.ref.keepSynced(true)
        })
        handle = ref?.child("Budget").child("Detailed").child(budget.getKeyID()).child("Details").observe(.childAdded, with: { (snapshot) in
            self.details.append(Detail(detaljeNavn: "", beløb: 0, keyID: snapshot.key))
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                switch notenu{
                case "Navn":
                    self.details[self.details.count-1].setName(a: value as! String)
                    break
                case "Beløb":
                    self.details[self.details.count-1].setBeløb(c: value as! Int)
                default:
                    self.detailsTableView.reloadData()
                }
                self.detailsTableView.reloadData()
                //print("Plads: \(self.details.count-1), \(self.details[self.details.count-1].getName()), \(self.details[self.details.count-1].getKeyID()), \(self.details[self.details.count-1].getBeløb())")
            }
            self.details.sort {$0.detaljeNavn < $1.detaljeNavn}
            self.ref.keepSynced(true)
        })
        handle = ref.child("Budget").child("Detailed").child(budget.getKeyID()).child("Details").observe(.childChanged, with: { (snapshot) -> Void in
            let value1 = snapshot.value as? NSDictionary
            for (key, value) in value1! {
                let notenu = key as! String
                if(notenu == "Navn"){
                    self.details[self.currentIndex].setName(a: value as! String)
                }
                else if(notenu == "Beløb"){
                    self.details[self.currentIndex].setBeløb(c: value as! Int)
                }
            }
            self.detailsTableView.reloadData()
            self.details.sort {$0.detaljeNavn < $1.detaljeNavn}
            self.ref.keepSynced(true)
        })
    }
    @objc func canRotate() -> Void {}
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        detailsTableView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        if UIDevice.current.orientation.isLandscape {
            detailsTableView.reloadData()
        }
        else {
            detailsTableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == true {
            return filtered.count
        }
        return self.details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailsTableView.dequeueReusableCell(withIdentifier: "ItemCell3", for: indexPath) as! DetailedTableViewCell
        let moneyText = details[indexPath.row].getBeløb()
        if isSearching == true {
            cell.leftText.text = filtered[indexPath.row].getName()
            cell.rightText.text = "\(filtered[indexPath.row].getBeløb()) kr"
        }
        else{
            cell.leftText.text = details[indexPath.row].getName()
            cell.rightText.text = "\(moneyText) kr"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = detailsTableView.dequeueReusableCell(withIdentifier: "ItemCell3", for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        var navn = ""
        var beløb = 0
        if(isSearching == true){
            navn = filtered[indexPath.row].getName()
            beløb = filtered[indexPath.row].getBeløb()
        }
        else{
            navn = details[indexPath.row].getName()
            beløb = details[indexPath.row].getBeløb()
        }
        let alertController = UIAlertController(title: "Info", message: "Navn: \(navn) \n Beløb: \(beløb) kr.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(isSearching == true){
                let currentKey = self.filtered[indexPath.row].getKeyID()
                opdateretUdgifter = 0
                opdateretBeløbTilrådighed = 0
                opdateretUdgifter = self.budget.getUdgifter() - self.filtered[indexPath.row].getBeløb()
                opdateretBeløbTilrådighed = self.budget.getTotaltBeløb() - opdateretUdgifter
                self.ref?.child("Budget").child("Detailed").child(budget.getKeyID()).child("Details").child(currentKey).removeValue()
                self.details.remove(at: indexPath.row)
                detailsTableView.reloadData()
                self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).updateChildValues(["Udgifter": self.opdateretUdgifter, "Beløb til rådighed" : self.opdateretBeløbTilrådighed])
            }
            else{
                let currentKey = self.details[indexPath.row].getKeyID()
                opdateretUdgifter = 0
                opdateretBeløbTilrådighed = 0
                opdateretUdgifter = self.budget.getUdgifter() - self.details[indexPath.row].getBeløb()
                opdateretBeløbTilrådighed = self.budget.getTotaltBeløb() - opdateretUdgifter
                self.ref?.child("Budget").child("Detailed").child(budget.getKeyID()).child("Details").child(currentKey).removeValue()
                self.details.remove(at: indexPath.row)
                detailsTableView.reloadData()
                self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).updateChildValues(["Udgifter": self.opdateretUdgifter, "Beløb til rådighed" : self.opdateretBeløbTilrådighed])
            }
            
        }
    }
    @objc func refresh() {
        detailsTableView.reloadData()
        refreshControl.endRefreshing()
    }
    func addDetail(){
        let alertController = UIAlertController(title: "Ny udgift", message: "", preferredStyle: .alert)
        let tilføj = UIAlertAction(title: "Tilføj", style: .default) { (action:UIAlertAction) in
            if ((alertController.textFields?[0].text?.count)! >= 1){
                let characterSetNotAllowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz,.-<>$§!#€%&/()=?`^*¨'")
                if((alertController.textFields?[1].text?.count)! >= 1 && ((alertController.textFields?[1].text?.rangeOfCharacter(from: characterSetNotAllowed)) == nil)){
                    let post : [String : Any] = ["Navn" : alertController.textFields![0].text!, "Beløb" : Int(alertController.textFields![1].text!)!]
                    self.ref?.child("Budget").child("Detailed").child(self.budget.getKeyID()).child("Details").childByAutoId().setValue(post)
                    
                    
                    self.opdateretUdgifter = self.budget.getUdgifter() + Int(alertController.textFields![1].text!)!
                    self.opdateretBeløbTilrådighed = self.budget.getTotaltBeløb() - self.opdateretUdgifter
                    
                    self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).updateChildValues(["Udgifter": self.opdateretUdgifter, "Beløb til rådighed" : self.opdateretBeløbTilrådighed])
                    self.budget.setUdgifter(d: self.opdateretUdgifter)
                    self.budget.setBeløbTilRådighed(c: self.opdateretBeløbTilrådighed)
                }
                else{
                    let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst beløb. Det må kun indeholde tal!", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else{
                let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst navn og beløb", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (action:UIAlertAction) in
            
        }
        alertController.addTextField { (textField0) in
            textField0.placeholder = "Navn"
            textField0.autocapitalizationType = .words
        }
        alertController.addTextField { (textField1) in
            textField1.placeholder = "Beløb"
            textField1.keyboardType = .numberPad
        }
        alertController.addAction(cancel)
        alertController.addAction(tilføj)
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func tilføj(_ sender: UIButton) {
        addDetail()
    }
    @objc func longPress(_ guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizer.State.began {
            if(isSearching == true){
                
            }
            else{
                
            }
            let point = guesture.location(in: detailsTableView)
            let indexPath = detailsTableView.indexPathForRow(at: point)
            if(indexPath != nil){
                currentIndex = indexPath!.row
                let editInfo = UIAlertController(title: nil, message: "Detaljer", preferredStyle: UIAlertController.Style.alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in
                })
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
                    if(self.isSearching == true){
                        if(!(editInfo.textFields![0].text?.isEmpty)!){
                            //Budget name has been changed!
                            let characterSetNotAllowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz,.-<>$§!#€%&/()=?`^*¨'")
                            if(!(editInfo.textFields![1].text?.isEmpty)! && editInfo.textFields![1].text?.rangeOfCharacter(from: characterSetNotAllowed) == nil){
                                //BeløbTilRådighed has been changed!
                                let unChangedBeløb = self.filtered[indexPath!.row].getBeløb()
                                let changedName = editInfo.textFields![0].text
                                let changedBeløb = Int(editInfo.textFields![1].text!)
                                let keyID = self.filtered[indexPath!.row].getKeyID()
                                self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).child("Details").child(keyID).updateChildValues(["Navn" : changedName!, "Beløb" : changedBeløb!])
                                self.detailsTableView.reloadData()
                                
                                self.opdateretUdgifter = 0
                                self.opdateretBeløbTilrådighed = 0
                                self.opdateretUdgifter = self.budget.getUdgifter() - unChangedBeløb
                                self.opdateretUdgifter = self.opdateretUdgifter + changedBeløb!
                                self.opdateretBeløbTilrådighed = self.budget.getTotaltBeløb() - self.opdateretUdgifter
                                
                                self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).updateChildValues(["Udgifter": self.opdateretUdgifter, "Beløb til rådighed" : self.opdateretBeløbTilrådighed])
                            }
                            else{
                                let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst udgift. Det må kun indeholde tal!", preferredStyle: .alert)
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
                    else{
                        if(!(editInfo.textFields![0].text?.isEmpty)!){
                            //Budget name has been changed!
                            let characterSetNotAllowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz,.-<>$§!#€%&/()=?`^*¨'")
                            if(!(editInfo.textFields![1].text?.isEmpty)! && editInfo.textFields![1].text?.rangeOfCharacter(from: characterSetNotAllowed) == nil){
                                //BeløbTilRådighed has been changed!
                                let unChangedBeløb = self.details[indexPath!.row].getBeløb()
                                let changedName = editInfo.textFields![0].text
                                let changedBeløb = Int(editInfo.textFields![1].text!)
                                let keyID = self.details[indexPath!.row].getKeyID()
                                self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).child("Details").child(keyID).updateChildValues(["Navn" : changedName!, "Beløb" : changedBeløb!])
                                self.detailsTableView.reloadData()
                                
                                self.opdateretUdgifter = 0
                                self.opdateretBeløbTilrådighed = 0
                                self.opdateretUdgifter = self.budget.getUdgifter() - unChangedBeløb
                                self.opdateretUdgifter = self.opdateretUdgifter + changedBeløb!
                                self.opdateretBeløbTilrådighed = self.budget.getTotaltBeløb() - self.opdateretUdgifter
                                
                                self.ref.child("Budget").child("Detailed").child(self.budget.getKeyID()).updateChildValues(["Udgifter": self.opdateretUdgifter, "Beløb til rådighed" : self.opdateretBeløbTilrådighed])
                            }
                            else{
                                let alertController = UIAlertController(title: "Fejl", message: "Indtast venligst udgift. Det må kun indeholde tal!", preferredStyle: .alert)
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
                })
                editInfo.addTextField { (textField0) in
                    if(self.isSearching == true){
                        textField0.text = String(self.filtered[(indexPath?.row)!].getName())
                        textField0.autocapitalizationType = .sentences
                    }
                    else{
                        textField0.text = String(self.details[(indexPath?.row)!].getName())
                        textField0.autocapitalizationType = .sentences
                    }
                }
                editInfo.addTextField { (textField1) in
                    if(self.isSearching == true){
                        textField1.text = String(self.filtered[(indexPath?.row)!].getBeløb())
                        textField1.keyboardType = .numberPad
                    }
                    else{
                        textField1.text = String(self.details[(indexPath?.row)!].getBeløb())
                        textField1.keyboardType = .numberPad
                    }
                }
                
                editInfo.addAction(cancelAction)
                editInfo.addAction(saveAction)
                self.present(editInfo, animated: true, completion: nil)
            }
            else{
                let alertController = UIAlertController(title: "Fejl", message: "Du har ikke valgt en udgift!", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == nil || searchBar.text == ""){
            isSearching = false
            view.endEditing(true)
            detailsTableView.reloadData()
        }
        else{
            isSearching = true
            filtered = details.filter({$0.getName().lowercased().contains(searchBar.text!.lowercased())})
            detailsTableView.reloadData()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "grafiskOverblik") {
            //if let destinationVC = segue.destination as? UINavigationController{
            if let destinationVC = segue.destination as? GraphicalOverviewViewController{
                //let targetController = destinationVC.topViewController as! DetailsViewController
                destinationVC.udgifter = details
            }
        }
        if (segue.identifier == "barchartOverblik") {
            if let destinationVC = segue.destination as? BarchartViewController{
                destinationVC.udgifter = details
            }
        }
        if(segue.identifier == "Test_piechart"){
            if let destinationVC = segue.destination as? Test_piechart{
                destinationVC.udgifter = details
            }
        }
        
    }
}

