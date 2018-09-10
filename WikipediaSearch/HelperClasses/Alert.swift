//
//  File.swift
//  WikipediaSearch
//
//  Created by Lova Rama Krishna P on 10/09/18.
//  Copyright © 2018 Lova Rama Krishna P. All rights reserved.
//

import Foundation
import UIKit
class alert {
    func msg(message: String, title: String = "")
    {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
    }
}
