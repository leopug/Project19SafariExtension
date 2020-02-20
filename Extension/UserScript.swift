//
//  UserScript.swift
//  Extension
//
//  Created by Ana Caroline de Souza on 17/02/20.
//  Copyright © 2020 Ana e Leo Corp. All rights reserved.
//

import Foundation

class UserScript: Codable {
    
    var name: String
    var script: String
    
    init(name: String, script: String) {
    
        self.name = name
        self.script = script
    }
    
}
