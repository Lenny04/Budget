//
//  CustomTableViewCell.swift
//  FirebaseApp
//
//  Created by linoj ravindran on 12/01/2017.
//  Copyright © 2017 linoj ravindran. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet var tekst1: UILabel!
    @IBOutlet var tekst2: UILabel!
    @IBOutlet var tekst3: UILabel!
    @IBOutlet var procesbar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        procesbar.transform = procesbar.transform.scaledBy(x: 1, y: 7)
        procesbar.layer.masksToBounds = true
        self.procesbar.clipsToBounds = true
        procesbar.layer.cornerRadius = 10
    }
    
}
