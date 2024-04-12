//
//  cellViewTemplate.swift
//  developing_v3
//
//  Created by Sabrina Boc on 31/03/2024.
//

import UIKit

class CellViewTemplate: UITableViewCell {
    
    @IBOutlet weak var carbonLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var carbonEmissions: UILabel!
    @IBOutlet weak var dateVar: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
