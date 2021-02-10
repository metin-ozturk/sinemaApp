//
//  SinemaAppManager.swift
//  Sinema
//
//  Created by Metin Ozturk on 7.02.2021.
//

import UIKit

class SinemaAppManager {
    
    var primaryColor = UIColor(named: "PrimaryColor")!

    static let shared: SinemaAppManager = SinemaAppManager()
    
    private init() {}
}
