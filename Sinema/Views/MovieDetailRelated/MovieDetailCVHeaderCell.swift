//
//  MovieDetailHeaderCell.swift
//  Sinema
//
//  Created by Metin Ozturk on 9.02.2021.
//

import UIKit

class MovieDetailCVHeaderCell: UICollectionViewCell {
    @IBOutlet weak var movieDetailHeaderTitleLabel: UILabel!
    @IBOutlet weak var movieDetailImdbVoteLabel: UILabel!
    @IBOutlet weak var movieDetailImdbLogoImageView: UIImageView!
    
    func update(title: String, vote: Float) {
        movieDetailImdbVoteLabel.text = "\(vote)"
        movieDetailHeaderTitleLabel.text = title
    }
    
}
