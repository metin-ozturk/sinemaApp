//
//  MovieDetail.swift
//  Sinema
//
//  Created by Metin Ozturk on 10.02.2021.
//

import Foundation

struct MovieDetail: Identifiable, Codable {
    let id: Int
    let releaseDate: Date
    let title: String
    let genres: [Genre]
    let overview: String?
    let runtime: Int?
}

struct Genre: Identifiable, Codable {
    let id: Int
    let name: String
}
