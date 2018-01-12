//
//  EventTableViewCell.swift
//  Evento
//
//  Created by Aleksey Bykhun on 11.01.2018.
//  Copyright © 2018 Aleksey Bykhun. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    var eventId: Int!
    
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
