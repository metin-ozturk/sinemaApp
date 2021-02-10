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
        movieDetailHeaderTitleLabel.text = title

        movieDetailImdbVoteLabel.text = vote != 0 ? "\(vote)" : ""
        movieDetailImdbLogoImageView.isHidden = vote != 0 ? false : true
    }
    
}
