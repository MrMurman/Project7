//
//  Petition.swift
//  Project7
//
//  Created by Андрей Бородкин on 01.07.2021.
//

import Foundation


struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
