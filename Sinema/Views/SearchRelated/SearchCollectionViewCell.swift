//
//  SearchCollectionViewCell.swift
//  Sinema
//
//  Created by Metin Ozturk on 9.02.2021.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailTextLabel: UILabel!
    @IBOutlet weak var imdbLogo: UIImageView!
    
    @IBOutlet weak var imdbLogoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imdbLogoTrailingConstraint: NSLayoutConstraint!
    
    func update(with movie: Movie) {
        movieImageView.image = movie.moviePosterImage
        movieTitleLabel.text = movie.title
        movieDetailTextLabel.text = "\(movie.voteAverage)"
        
        if (movie.releaseDate > Date()) {
            imdbLogo.isHidden = true
            let converter = DateFormatter()
            converter.dateFormat = "dd.MM.YYYY"
            
            let calendar = Calendar.current
            let movieStartDate = calendar.startOfDay(for: movie.releaseDate)
            let currentStartDate = calendar.startOfDay(for: Date())
            
            let components = calendar.dateComponents([.day], from: currentStartDate, to: movieStartDate)
            
            movieDetailTextLabel.text = "\(components.day ?? -1) gün sonra yayınlanacak."
            imdbLogoWidthConstraint.constant = 0
            imdbLogoTrailingConstraint.constant = 0
        } else {
            imdbLogo.isHidden = false
            imdbLogoWidthConstraint.constant = 30
            imdbLogoTrailingConstraint.constant = 8
        }
        
        DispatchQueue.main.async {
            self.imdbLogo.layoutIfNeeded()
        }
    }
    
}
