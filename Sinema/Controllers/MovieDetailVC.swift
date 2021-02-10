//
//  MovieDetailVC.swift
//  Sinema
//
//  Created by Metin Ozturk on 9.02.2021.
//

import UIKit

class MovieDetailVC: BaseVC {
    
    var movieDataRetrieved: Movie?
    
    private var retrievedMovieDetail: MovieDetail?
    
    @IBOutlet private weak var movieDetailNavigationBar: UINavigationBar!
    @IBOutlet private weak var backdropImageView: UIImageView!
    @IBOutlet private weak var moviePosterImageView: UIImageView!
    
    @IBOutlet private weak var movieDetailCollectionView: UICollectionView!
    
    private var numberOfMovieInfo : Int?
    private var movieInfoPresentationSequence = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItems()
        setMovieDetailCollectionView()

        
        RemoteDataManager.shared.getMovieDetail(movieId: movieDataRetrieved!.id) { (movieDetail) in
            self.retrievedMovieDetail = movieDetail
            self.numberOfMovieInfo = self.calculateNumberOfAvailableMovieInfo()
            DispatchQueue.main.async {
                self.movieDetailCollectionView.reloadData()
            }
        }
    }
    
    private func setNavigationItems() {
        let backButton = UIBarButtonItem(image: UIImage(named: "backButtonImage"), style: .plain, target: nil, action: #selector(backButtonTapped(_:)))
        let shareButton = UIBarButtonItem(image: UIImage(named: "shareButtonImage"), style: .plain, target: nil, action: #selector(shareButtonTapped(_:)))
        backButton.tintColor = .white
        shareButton.tintColor = .white
        
        let customNavigationItem = UINavigationItem(title: "")
        customNavigationItem.hidesBackButton = false
        customNavigationItem.leftBarButtonItem = backButton
        customNavigationItem.rightBarButtonItem = shareButton
        
        movieDetailNavigationBar.setItems([customNavigationItem], animated: false)
        
        
        movieDetailNavigationBar.shadowImage = UIImage()
        movieDetailNavigationBar.isTranslucent = true
        movieDetailNavigationBar.backgroundColor = .clear
        movieDetailNavigationBar.setBackgroundImage(UIImage(), for: .default)
                
        downloadImages()
    }
    
    private func setMovieDetailCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width - 16, height: 25)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        movieDetailCollectionView.collectionViewLayout = layout
        
        movieDetailCollectionView.register(UINib(nibName: "MovieDetailCVHeaderCell", bundle: nil), forCellWithReuseIdentifier: "MovieDetailCVHeaderCell")
        movieDetailCollectionView.register(UINib(nibName: "MovieDetailContentCell", bundle: nil), forCellWithReuseIdentifier: "MovieDetailContentCell")
        movieDetailCollectionView.register(UINib(nibName: "MovieDetailOverviewCell", bundle: nil), forCellWithReuseIdentifier: "MovieDetailOverviewCell")
        movieDetailCollectionView.delegate = self
        movieDetailCollectionView.dataSource = self
    }
    
    
    private func downloadImages() {
        if let movieDataRetrieved = movieDataRetrieved {
            if let posterPath = movieDataRetrieved.posterPath {
                RemoteDataManager.shared.getPosterImageForMovie(imagePath: posterPath) { (downloadedImage) in
                    DispatchQueue.main.async {
                        self.moviePosterImageView.image = downloadedImage
                    }
                }
            }

            if let backdropPath = movieDataRetrieved.backdropPath {
                RemoteDataManager.shared.getPosterImageForMovie(imagePath: backdropPath) { (downloadedImage) in
                    DispatchQueue.main.async {
                        self.backdropImageView.image = downloadedImage
                    }
                }
            }
            
        }
    }
    
    private func calculateNumberOfAvailableMovieInfo() -> Int {
        var counter = 0
        
        if (retrievedMovieDetail?.genres.count != 0) {
            counter += 1
            movieInfoPresentationSequence.append("G")
        }
        
        if (retrievedMovieDetail?.releaseDate != nil) {
            counter += 1
            movieInfoPresentationSequence.append("R")

        }
        
        if (retrievedMovieDetail?.runtime != nil) {
            counter += 1
            movieInfoPresentationSequence.append("D")
        }
        

        
        return counter
    }
    
    @objc func backButtonTapped(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func shareButtonTapped(_ sender: Any?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"

        let shareTextItem = "Film Adı: \(movieDataRetrieved?.title ?? "") Vizyon Tarihi: \(dateFormatter.string(from: movieDataRetrieved?.releaseDate ?? Date()))"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [shareTextItem], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension MovieDetailVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.row == 0) {
            return CGSize(width: 300, height: 125)
        } else if (1...((numberOfMovieInfo ??  1)) ~= indexPath.row) {
            return CGSize(width: collectionView.frame.width - 32, height: 25)
        } else {
            return CGSize(width: collectionView.frame.width - 32, height: 300)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfMovieInfo = numberOfMovieInfo {
            return numberOfMovieInfo + 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailCVHeaderCell", for: indexPath) as! MovieDetailCVHeaderCell
            
            cell.update(title: movieDataRetrieved?.title ?? "Error", vote: movieDataRetrieved?.voteAverage ?? -1)
            return cell
        } else if (0...((numberOfMovieInfo ?? 0)) ~= indexPath.row) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailContentCell", for: indexPath) as! MovieDetailContentCell
            
            let currentPresentationOrder = indexPath.row - 1
            
            if !movieInfoPresentationSequence.isEmpty {
                switch movieInfoPresentationSequence[currentPresentationOrder] {
                case "G":
    
                    cell.movieDetailTitleLabel.text = "Tür:"
                    var movieGenreString = ""
                    retrievedMovieDetail?.genres.forEach { movieGenreString += "\($0.name), " }
                    if (!movieGenreString.isEmpty) {
                        movieGenreString.removeLast(2)
                    }
                    cell.movieDetailContentLabel.text = movieGenreString
                case "R":
                    cell.movieDetailTitleLabel.text = "Vizyon Tarihi:"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM.YYYY"
                    cell.movieDetailContentLabel.text = dateFormatter.string(from: retrievedMovieDetail?.releaseDate ?? Date())
                case "D":
                    cell.movieDetailTitleLabel.text = "Süre:"
                    cell.movieDetailContentLabel.text = "\(retrievedMovieDetail?.runtime ?? 0) dk."
                default:
                    cell.movieDetailTitleLabel.text = ""
                    cell.movieDetailContentLabel.text = ""
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieDetailOverviewCell", for: indexPath) as! MovieDetailOverviewCell
            cell.movieDetailOverviewTextView.text = retrievedMovieDetail?.overview
            return cell
        }
    }
    
    
}
