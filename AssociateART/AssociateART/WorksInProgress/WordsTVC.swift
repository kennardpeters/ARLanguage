//
//  WordsTVC.swift
//  AssociateART
//
//  Created by Kennard Peters on 4/19/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class WordsTVC: UITableViewCell {

    @IBOutlet weak var wordsView: UIView!
    @IBOutlet weak var wordsLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
