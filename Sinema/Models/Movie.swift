//
//  Movie.swift
//  Sinema
//
//  Created by Metin Ozturk on 7.02.2021.
//

import UIKit

struct Movie : Identifiable, Codable {
    let id: Int
    let releaseDate: Date
    let title: String
    let overview: String
    let voteAverage: Float
    let backdropPath: String?
    let posterPath: String?
    
    var moviePosterImage : UIImage? = nil
    var movieBackdropImage: UIImage? = nil
    let movieType: MovieType? = nil
    
    private enum CodingKeys: String, CodingKey {
        case id, releaseDate, title, overview, voteAverage, backdropPath, posterPath
    }
}

struct Movies : Codable {
    var movies: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}
