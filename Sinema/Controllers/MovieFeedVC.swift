//
//  ViewController.swift
//  Sinema
//
//  Created by Metin Ozturk on 6.02.2021.
//

import UIKit

class MovieFeedVC: BaseVC {

    @IBOutlet weak var movieStatusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var sortingByLabel: UILabel!
    @IBOutlet weak var sortingByColoredLabel: UILabel!
    @IBOutlet weak var sortingByContainerView: UIView!
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    @IBOutlet weak var moviesCollectionViewTopConstraint: NSLayoutConstraint!
    
    private var retrievedMovieData: Movies?
    private var retrievedUpcomingMovieData: Movies?
    
    private var currentPageNumberForCurrentMovies = 1
    private var currentPageNumberForUpcomingMovies = 1
    
    private let numberOfElementsInAPage = 20
    
    private var isShowingCurrentMovies : Bool = true
    
    private var primaryTopConstraintForCollectionView: NSLayoutConstraint?
    private var alternateTopConstraintForCollectionView: NSLayoutConstraint?
    
    private var selectedMovieIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MovieFeedVC Loaded")
        // Do any additional setup after loading the view.
        adjustSegmentedControlColor()
        movieStatusSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        movieStatusSegmentedControl.initializeSegmentedControlStyle()
        
        initializeMoviesCollectionView()
        
//        presentActivityIndicator()
        RemoteDataManager.shared.getMovies(pageNumber: 1, movieType: .CurrentlyPlaying) { (movies) in
            self.retrievedMovieData = movies
            self.downloadPosterImages(movieType: .CurrentlyPlaying, startIdx: 0)
            DispatchQueue.main.async {
                self.moviesCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        isShowingCurrentMovies = !isShowingCurrentMovies
        adjustSegmentedControlColor()
        UIView.animate(withDuration: 0.5) {
            if (self.isShowingCurrentMovies) {
                self.sortingByContainerView.alpha = 1
                self.sortingByLabel.alpha = 1
                self.alternateTopConstraintForCollectionView?.isActive = false
                self.primaryTopConstraintForCollectionView = NSLayoutConstraint(item: self.moviesCollectionView!, attribute: .top, relatedBy: .equal, toItem: self.sortingByLabel, attribute: .topMargin, multiplier: 1, constant: 16)
                self.primaryTopConstraintForCollectionView?.isActive = true

            } else {
                self.sortingByContainerView.alpha = 0
                self.sortingByLabel.alpha = 0
                
                if (self.moviesCollectionViewTopConstraint == nil) {
                    self.primaryTopConstraintForCollectionView?.isActive = false
                } else {
                    self.moviesCollectionViewTopConstraint.isActive = false
                }
                
                self.alternateTopConstraintForCollectionView = NSLayoutConstraint(item: self.moviesCollectionView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1, constant: 16)
                self.alternateTopConstraintForCollectionView?.isActive = true
            }
            self.view.layoutIfNeeded()
        }
        
        moviesCollectionView.reloadData()
        
        if (!isShowingCurrentMovies && retrievedUpcomingMovieData == nil) {
            RemoteDataManager.shared.getMovies(pageNumber: 1, movieType: .ComingSoon) { (movies) in
                self.retrievedUpcomingMovieData = movies
                self.downloadPosterImages(movieType: .ComingSoon, startIdx: 0)
                DispatchQueue.main.async {
                    self.moviesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func adjustSegmentedControlColor() {
        for idx in 0...movieStatusSegmentedControl.subviews.count - 1 {
            if let subview = movieStatusSegmentedControl.subviews[idx] as? UIImageView{
                if idx == self.movieStatusSegmentedControl.selectedSegmentIndex {
                    subview.backgroundColor = UIColor.white
                    subview.layer.cornerRadius = 0
                    subview.clipsToBounds = true
                } else{
                    subview.backgroundColor = .clear
                }
                
            }
        }
    }
    
    private func initializeMoviesCollectionView() {
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.register(UINib(nibName: "MoviesCVCell", bundle: nil), forCellWithReuseIdentifier: "MoviesCVCellIdentifier")
        moviesCollectionView.isPagingEnabled = true
    }
    
    
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        let attributedTitle = NSAttributedString(string: "Film Sıralama", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        
        let attributedMessage =  NSAttributedString(string: "Filmler neye göre sıralansın?", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.setValue(attributedTitle, forKey: "attributedTitle")
        actionSheet.setValue(attributedMessage, forKey: "attributedMessage")
        
        actionSheet.view.tintColor = SinemaAppManager.shared.primaryColor
        actionSheet.view.backgroundColor = .clear
                
        actionSheet.addAction(UIAlertAction(title: "Vizyon Tarihine Göre Sırala", style: .default, handler: { (alertAction) in
            self.sortingByLabel.text = "Tarihe Göre Vizyona Girenler".uppercased(with: Locale(identifier: "tr_TR"))
            self.sortingByColoredLabel.text = "Vizyon Tarihine Göre Sıralı"
            
            self.retrievedMovieData?.movies.sort(by: { $0.releaseDate > $1.releaseDate })
            self.moviesCollectionView.reloadData()
            

        }))
        
        actionSheet.addAction(UIAlertAction(title: "IMDB Puanına Göre Sırala", style: .default, handler: { (alertAction) in
            self.sortingByLabel.text = "IMDB Puanına Göre Vizyondakiler".uppercased(with: Locale(identifier: "tr_TR"))
            self.sortingByColoredLabel.text = "IMDB Puanına Göre Sıralı"
            
            self.retrievedMovieData?.movies.sort(by: { $0.voteAverage > $1.voteAverage })
            self.moviesCollectionView.reloadData()

        }))
        
        actionSheet.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: { (alertAction) in
            
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    

    
    
    
    
    private func downloadPosterImages(movieType: MovieType, startIdx: Int) {
        let data = movieType == .CurrentlyPlaying ? retrievedMovieData : retrievedUpcomingMovieData
        for (idx, movie) in data!.movies.enumerated() {
            if (idx < startIdx || movie.posterPath == nil) {
                continue
            }
            
            RemoteDataManager.shared.getPosterImageForMovie(imagePath: movie.posterPath!) { (posterImage) in
                DispatchQueue.main.async {
                    
                    autoreleasepool {
                        if (movieType == .CurrentlyPlaying) {
                            self.retrievedMovieData?.movies[idx].moviePosterImage = posterImage
                        } else {
                            self.retrievedUpcomingMovieData?.movies[idx].moviePosterImage = posterImage
                        }

                    }
                    self.moviesCollectionView.reloadItems(at: [IndexPath(row: idx, section: 0)])

                }
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MovieDetailVC") {
            let destinationVC = segue.destination as! MovieDetailVC
            if let movieData = retrievedMovieData, isShowingCurrentMovies, selectedMovieIndex >= 0  {
                destinationVC.movieDataRetrieved = movieData.movies[selectedMovieIndex]
            } else if let movieData = retrievedUpcomingMovieData, selectedMovieIndex >= 0 {
                destinationVC.movieDataRetrieved = movieData.movies[selectedMovieIndex]
            }
            
            selectedMovieIndex = -1

        }
    }
    
//    private func presentActivityIndicator() {
//        let dimmedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
//        dimmedView.backgroundColor = .black
//        dimmedView.alpha = 0.3
//
//        let activityIndicator = UIActivityIndicatorView(style: .large)
//        activityIndicator.frame = CGRect(x: (view.frame.width / 2) - 50, y: (view.frame.height / 2) - 50, width: 100, height: 100)
//        activityIndicator.color = SinemaAppManager.shared.primaryColor
//        activityIndicator.backgroundColor = .white
//        activityIndicator.layer.cornerRadius = 20
//        activityIndicator.startAnimating()
//
//        view.addSubview(dimmedView)
//        view.addSubview(activityIndicator)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            activityIndicator.removeFromSuperview()
//            dimmedView.removeFromSuperview()
//        }
//    }
    
    
}

extension MovieFeedVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isShowingCurrentMovies ? retrievedMovieData?.movies.count ?? 0 : retrievedUpcomingMovieData?.movies.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviesCVCellIdentifier", for: indexPath) as! MoviesCVCell
        
        let retrievedData = isShowingCurrentMovies ? self.retrievedMovieData : self.retrievedUpcomingMovieData
        
        
        
        cell.update(image:
                        (retrievedData?.movies[indexPath.row].moviePosterImage ?? UIImage(named: "placeholderImage"))!,
                    detailText:
                        isShowingCurrentMovies ? String(retrievedData?.movies[indexPath.row].voteAverage ?? -1) : nil,
                    detailDate:
                        isShowingCurrentMovies ? nil : retrievedData?.movies[indexPath.row].releaseDate)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 60 - 10) / 2
        let height = (3 / 2) * width + 36
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviesCVCellIdentifier", for: indexPath) as! MoviesCVCell
        selectedMovieIndex = indexPath.row
        performSegue(withIdentifier: "MovieDetailVC", sender: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedMovieIndex = -1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row != 0 && indexPath.row % (numberOfElementsInAPage - 1) == 0) {
            let pageNumber = ((indexPath.row + 1) / (numberOfElementsInAPage - 1)) + 1
            let localPageNumber = isShowingCurrentMovies ? self.currentPageNumberForCurrentMovies : self.currentPageNumberForUpcomingMovies
            guard pageNumber > localPageNumber else { return }
            
//            presentActivityIndicator()
            
            if (isShowingCurrentMovies) {
                self.currentPageNumberForCurrentMovies = pageNumber
            } else {
                self.currentPageNumberForUpcomingMovies = pageNumber
            }
            
            RemoteDataManager.shared.getMovies(pageNumber: pageNumber, movieType: isShowingCurrentMovies ? .CurrentlyPlaying : .ComingSoon) { (moviesData) in
                if let moviesData = moviesData {
                    if (self.isShowingCurrentMovies) {
                        self.retrievedMovieData?.movies.append(contentsOf: moviesData.movies)
                    } else {
                        self.retrievedUpcomingMovieData?.movies.append(contentsOf: moviesData.movies)
                    }
                    self.downloadPosterImages(movieType: self.isShowingCurrentMovies ? .CurrentlyPlaying : .ComingSoon, startIdx: (pageNumber - 1) * (self.numberOfElementsInAPage - 1))
                    DispatchQueue.main.async {
                        self.moviesCollectionView.reloadData()
                    }
                }

            }
        }
    }
        
    
}

