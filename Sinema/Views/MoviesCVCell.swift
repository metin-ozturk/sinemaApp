//
//  MoviesCVCell.swift
//  Sinema
//
//  Created by Metin Ozturk on 7.02.2021.
//

import UIKit


class MoviesCVCell: UICollectionViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    
    @IBOutlet weak var movieDetailView: UIView!
    @IBOutlet weak var movieDetailImageView: UIImageView!
    @IBOutlet weak var movieDetailLabel: UILabel!
    @IBOutlet weak var movieDetailLabelAlignCenterConstraint: NSLayoutConstraint!
    
    
    func update(image: UIImage, detailText: String?, detailDate: Date?) {
        let isShowingCurrentMovies = detailText != nil
        
        movieImageView.image = image
        movieDetailImageView.isHidden = !isShowingCurrentMovies
        
        movieDetailLabelAlignCenterConstraint.constant = !isShowingCurrentMovies ? -5 : 30
        
        if (isShowingCurrentMovies) {
            movieDetailLabel.text = detailText
        } else {
            let retrievedDate = detailDate!
            let calendar = Calendar.current
            let retrievedDateBeginning = calendar.startOfDay(for: retrievedDate)
            let currentDateBeginning = calendar.startOfDay(for: Date())
            
            let difference = calendar.dateComponents([.day], from: retrievedDateBeginning, to: currentDateBeginning)
            let differenceAsDays = difference.day ?? Int.max
            
            if (differenceAsDays < 0) {
                movieDetailLabel.text = "\(abs(differenceAsDays)) Gün Kaldı"
            } else {
                let converter = DateFormatter()
                converter.dateFormat = "dd.MM.YYYY"
                movieDetailLabel.text = converter.string(from: retrievedDate)
            }
            
            

        }

    }
}
