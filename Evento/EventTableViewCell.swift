//
//  EventTableViewCell.swift
//  Evento
//
//  Created by Aleksey Bykhun on 11.01.2018.
//  Copyright © 2018 Aleksey Bykhun. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    static let highlightColor = UIColor(red: 255/255, green: 241/255, blue: 180/255, alpha: 1.0)
    
    var eventId: Int!
    
    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    func setData(from event: Event) {
        eventId = event.id
        title.text = event.name
        dateLabel.text = event.getDateString()
        locationLabel.text = event.location
        
        pinButton.tag = event.id
        
        backgroundColor = (event.pinned) ? EventTableViewCell.highlightColor : .white
    }

}
