//
//  TredjeViewController.swift
//  FirebaseApp
//
//  Created by linoj ravindran on 12/01/2017.
//  Copyright © 2017 linoj ravindran. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class TredjeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    @IBOutlet var textfield: UITextField!
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var pengeTilbage: UILabel!
    @IBOutlet var forbrug: UILabel!
    @IBOutlet var indtægter: UILabel!
    @IBOutlet var totaltBeløb: UILabel!
    @IBOutlet var tilrådighedIProcent: UILabel!
    @IBOutlet var valuta: UILabel!
    @IBOutlet var addButton: UIButton!
    var ref: DatabaseReference!
    @IBOutlet weak var navigationbar: UINavigationItem!
    var budget = Budget(budgetnavn: "", beløbtilrådighed: 0, samledeudgifter: 0, samledeindtægter: 0, samletomkostninger: 0, pengeTilbage: 0, keyID: "")
    var circleAngle = 0.0
    var penge = 0
    var pickerDataSource = ["Udgift", "Indtægt"]
    var selected = ""
    var urlStringGammel = "https://www.xe.com/currencyconverter/convert/?Amount=1&From=USD&To=DKK"
    var urlStringGammel2 = "https://free.currencyconverterapi.com/api/v5/convert?q=USD_DKK&compact=y"
    var urlString = "https://www.floatrates.com/daily/usd.json"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = budget.getName()
        
        // Pickerview
        self.picker.delegate = self
        self.picker.dataSource = self
        textfield.keyboardType = .numberPad
        
        // Addbutton
        addButton.backgroundColor = UIColor(red:1.00, green:0.66, blue:0.00, alpha:1.0) // Orange
        addButton.layer.cornerRadius = 30
        addButton.layer.borderWidth = 0
        addButton.clipsToBounds = true
        ref = Database.database().reference()
        circleAngle = ((Double(budget.getsamledeudgifter())-Double(budget.getsamledeindtægter()))/Double(budget.getbeløbtilrådighed())*360)
        setColor(a: Int(circleAngle))
        penge = budget.getbeløbtilrådighed() - (budget.getsamledeudgifter()-budget.getsamledeindtægter())
        forbrug.text = "\(budget.getsamledeudgifter()) kr"
        indtægter.text = "\(budget.getsamledeindtægter()) kr"
        totaltBeløb.text = "\(budget.getbeløbtilrådighed()) kr"
        let p = (1-(Double(budget.getsamledeudgifter())-Double(budget.getsamledeindtægter()))/Double(budget.getbeløbtilrådighed()))*100
        tilrådighedIProcent.text = "\(Int(p)) %"
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            
            print("Data: \(data))")
            print("Response: \(response))")
        })
        task.resume()
        NotificationCenter.default.addObserver(self, selector: #selector(TredjeViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TredjeViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        navigationbar.leftBarButtonItem = UIBarButtonItem(title: "Tilbage", style: .plain, target: self, action: #selector(TredjeViewController.back))
    }
    func jsonToDict(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            } catch _ as NSError {
            }
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @objc func back(){
        let midOmkostninger = budget.getsamledeudgifter() - budget.getsamledeindtægter()
        self.ref.child("Budget").child("Simple").child(budget.getKeyID()).updateChildValues(["Samlede omkostninger" : midOmkostninger, "Penge tilbage" : budget.getbeløbtilrådighed() - midOmkostninger])
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func udgifterTilføj(_ sender: UIButton) {
        let i = Int(textfield.text!)
        if(textfield.text != ""){
            if(pickerDataSource[picker.selectedRow(inComponent: 0)] == "Udgift"){
                budget.setsamledeudgifter(c: budget.getsamledeudgifter()+i!)
                forbrug.text = "\(budget.getsamledeudgifter()) kr"
            }
            else if(pickerDataSource[picker.selectedRow(inComponent: 0)] == "Indtægt"){
                budget.setsamledeindtægter(d: budget.getsamledeindtægter()+i!)
                indtægter.text = "\(budget.getsamledeindtægter()) kr"
            }
            textfield.text = ""
            penge = budget.getbeløbtilrådighed() - (budget.getsamledeudgifter()-budget.getsamledeindtægter())
            let p = (1-(Double(budget.getsamledeudgifter())-Double(budget.getsamledeindtægter()))/Double(budget.getbeløbtilrådighed()))*100
            tilrådighedIProcent.text = "\(Int(p)) %"
            circleAngle = ((Double(budget.getsamledeudgifter())-Double(budget.getsamledeindtægter()))/Double(budget.getbeløbtilrådighed())*360)
            setColor(a: Int(circleAngle))
            view.endEditing(true)
        }
        else{
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tilAndenViewController") {
            if segue.destination is AndenViewController{
            }
        }
    }
    func setColor(a: Int){
        switch a {
        case 0..<271:
            //Green
            tilrådighedIProcent.textColor = UIColor(red:0.48, green:0.81, blue:0.30, alpha:1.0)
            break
        case 271..<360:
            //Yellow
            tilrådighedIProcent.textColor = UIColor(red:1.00, green:0.84, blue:0.15, alpha:1.0)
            break
        case 360...:
            //Red
            tilrådighedIProcent.textColor = UIColor(red:0.98, green:0.00, blue:0.00, alpha:1.0)
            break
        default:
            tilrådighedIProcent.textColor = UIColor(red:0.48, green:0.81, blue:0.30, alpha:1.0)
            break
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(row == 0){
            addButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0) //Red
        }
        else if(row == 1){
            addButton.backgroundColor = UIColor(red:0.00, green:0.67, blue:0.06, alpha:1.0) //Green
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.height
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.window?.frame.origin.y = -1 * keyboardHeight
            self.view.layoutIfNeeded()
        })
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.window?.frame.origin.y = 0
            self.view.layoutIfNeeded()
        })
    }
}

