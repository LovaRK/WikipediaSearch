//
//  CustomCellTableViewCell.swift
//  WikipediaSearch
//
//  Created by Lova Rama Krishna P on 08/09/18.
//  Copyright © 2018 Lova Rama Krishna P. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    
    var coreDataStack = CoreDataStack()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgView.layer.cornerRadius = 10;
        self.imgView.layer.masksToBounds = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureTableViewCell(article: Article){
        self.nameLbl.text = article.name
        self.descriptionLbl.text = article.description
        if !article.image.isEmpty{
         self.imgView.loadImageUsingCache(withUrl:article.image )
          }else{
            self.imgView.image = UIImage(named: "logo")
            }        
    }
}





