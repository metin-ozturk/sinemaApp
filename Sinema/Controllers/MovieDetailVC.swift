//
//  MovieDetailVC.swift
//  Sinema
//
//  Created by Metin Ozturk on 9.02.2021.
//

import UIKit
import AVFoundation
import AVKit

class MovieDetailVC: BaseVC {
    
    var movieDataRetrieved: Movie?
    
    private var retrievedMovieDetail: MovieDetail?
    
    @IBOutlet weak var movieDetailNavBarTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var movieDetailNavigationBar: UINavigationBar!
    @IBOutlet private weak var backdropImageView: UIImageView!
    @IBOutlet private weak var moviePosterImageView: UIImageView!
    
    @IBOutlet private weak var movieDetailCollectionView: UICollectionView!
    private var movieDetailCVLayout: UICollectionViewFlowLayout?
    @IBOutlet weak var videoView: UIView!
    
    private var numberOfMovieInfo : Int?
    private var movieInfoPresentationSequence = [String]()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private var isShowingBackdropImage = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItems()
        setMovieDetailCollectionView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoViewTapped))
        videoView.addGestureRecognizer(tapGesture)

        
        RemoteDataManager.shared.getMovieDetail(movieId: movieDataRetrieved!.id) { (movieDetail) in
            self.retrievedMovieDetail = movieDetail
            self.numberOfMovieInfo = self.calculateNumberOfAvailableMovieInfo()
            DispatchQueue.main.async {
                self.movieDetailCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        movieDetailNavBarTopConstraint.constant = statusBarHeight + 4
        movieDetailNavigationBar.layoutIfNeeded()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    
        movieDetailCVLayout?.invalidateLayout()
        DispatchQueue.main.async {
            self.movieDetailCollectionView.reloadData()
            self.movieDetailCollectionView.layoutIfNeeded()
        }
        
        if UIDevice.current.orientation.isLandscape && player != nil {
            videoViewTapped(nil)
        }
    }
    
    private func setNavigationItems() {
        let backButton = UIBarButtonItem(image: UIImage(named: "backButtonImage"), style: .plain, target: nil, action: #selector(backButtonTapped(_:)))
        let shareButton = UIBarButtonItem(image: UIImage(named: "shareButtonImage"), style: .plain, target: nil, action: #selector(shareButtonTapped(_:)))
        let changeButton = UIBarButtonItem(image: UIImage(named: "changeButtonImage"), style: .plain, target: nil, action: #selector(changeButtonTapped(_:)))
        [backButton, shareButton, changeButton].forEach { $0.tintColor = .white }
        

        changeButton.imageInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: -16)
        shareButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let customNavigationItem = UINavigationItem(title: "")
        customNavigationItem.hidesBackButton = false
        customNavigationItem.leftBarButtonItem = backButton
        customNavigationItem.rightBarButtonItems = [shareButton , changeButton]
        
        movieDetailNavigationBar.setItems([customNavigationItem], animated: false)
        
        
        movieDetailNavigationBar.shadowImage = UIImage()
        movieDetailNavigationBar.isTranslucent = true
        movieDetailNavigationBar.backgroundColor = .clear
        movieDetailNavigationBar.setBackgroundImage(UIImage(), for: .default)
                
        downloadImages()
    }
    
    private func setMovieDetailCollectionView() {
        movieDetailCVLayout = UICollectionViewFlowLayout()
        movieDetailCVLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        movieDetailCVLayout?.itemSize = CGSize(width: view.frame.width - 16, height: 25)
        movieDetailCVLayout?.minimumLineSpacing = 0
        movieDetailCVLayout?.minimumInteritemSpacing = 0
        movieDetailCollectionView.collectionViewLayout = movieDetailCVLayout!
        
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
        
        if (retrievedMovieDetail?.runtime != nil && retrievedMovieDetail?.runtime != 0) {
            counter += 1
            movieInfoPresentationSequence.append("D")
        }
        

        
        return counter
    }
    
    @objc private func backButtonTapped(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func shareButtonTapped(_ sender: Any?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"

        let shareTextItem = "Film Adı: \(movieDataRetrieved?.title ?? "") Vizyon Tarihi: \(dateFormatter.string(from: movieDataRetrieved?.releaseDate ?? Date()))"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [shareTextItem], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
     
    @objc private func changeButtonTapped(_ sender: Any?) {
        if (isShowingBackdropImage) {
            videoView.isHidden = false
            if let url = URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4") {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: playerItem)
                player?.volume = 0
                
                playerLayer = AVPlayerLayer(player: player)
                playerLayer?.frame = videoView.bounds
                playerLayer?.videoGravity = .resizeAspectFill
                

                videoView.layer.addSublayer(playerLayer!)
                
                player?.play()
                                
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (notif) in
                    self.player?.seek(to: CMTime.zero)
                    self.player?.play()
                }
            }
        } else {
            player?.pause()
            player = nil
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
            videoView.isHidden = true
        }
        
        isShowingBackdropImage = !isShowingBackdropImage

    }
    
    @objc private func videoViewTapped(_ sender: UITapGestureRecognizer?) {
        if (!isShowingBackdropImage) {
            changeButtonTapped(nil)
            
            if let url = URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4") {
                let localPlayer = AVPlayer(url: url)
                localPlayer.volume = 1
                let playerVC = AVPlayerViewController()
                playerVC.player = localPlayer
                
                self.present(playerVC, animated: true) {
                    localPlayer.play()
                }
                
            }
        }
    }
}

extension MovieDetailVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.row == 0) {
            return CGSize(width: collectionView.frame.width - 32, height: 125)
        } else if (1...((numberOfMovieInfo ??  1)) ~= indexPath.row) {
            return CGSize(width: collectionView.frame.width - 32, height: 25)
        } else {
            return CGSize(width: collectionView.frame.width -  32, height: 300)
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
