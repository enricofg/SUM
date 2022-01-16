//
//  TableViewCell.swift
//  ppppppp
//
//  Created by Luís Sousa on 27/12/2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var button: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    static let identifier = "TableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "TableViewCell", bundle: nil)
    }
    
    func configure(with title: String){
        button.setTitle(title, for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitleColor(.link, for: .normal)
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }    
}
