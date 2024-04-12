//
//  NoRoutesSavedTemplate.swift
//  developing_v3
//
//  Created by Sabrina Boc on 12/04/2024.
//

import UIKit

class NoRoutesSavedTemplate: UITableViewCell {
 
    @IBOutlet weak var noRoutes: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
