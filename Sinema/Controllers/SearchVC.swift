//
//  SearchVC.swift
//  Sinema
//
//  Created by Metin Ozturk on 9.02.2021.
//

import UIKit

class SearchVC: BaseVC {
    
    private var searchTimer : Timer?
    
    private lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = UIColor(red: 3 / 255, green: 3 / 255, blue: 3 / 255, alpha: 0.21)
        searchBar.barTintColor = SinemaAppManager.shared.primaryColor
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.tintColor = SinemaAppManager.shared.primaryColor
                
        var textField : UITextField?

        if #available(iOS 13.0, *) {
            textField = searchBar.searchTextField
        } else {
            textField = searchBar.value(forKey: "searchField") as? UITextField
        }

        textField?.font = UIFont.systemFont(ofSize: 15)
        textField?.textColor = .white
        textField?.backgroundColor = .clear
        
        return searchBar
    }()
    
    @IBOutlet weak var popularMoviesTableView: UITableView!
    @IBOutlet weak var popularMoviesLabel: UILabel!
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    
    private var popularMovies = [Movie]()
    private var searchResults = [Movie]()
    
    private var selectedSearchMovieIdx = -1
    private var selectedPopularMovieIdx = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMoviesTableView()
        setSearchBar()
        setSearchCollectionView()
        
        RemoteDataManager.shared.getMovies(pageNumber: 1, movieType: .Popular) { (movies) in
            if let movies = movies {
                self.popularMovies = Array(movies.movies[0...4])
                DispatchQueue.main.async {
                    self.popularMoviesTableView.reloadData()
                }
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchTimer?.invalidate()
        searchTimer = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailVC
        
        if (selectedPopularMovieIdx != -1) {
            destinationVC.movieDataRetrieved = popularMovies[selectedPopularMovieIdx]
        } else if (selectedSearchMovieIdx != -1) {
            destinationVC.movieDataRetrieved = searchResults[selectedSearchMovieIdx]

        }
        
        selectedPopularMovieIdx = -1
        selectedSearchMovieIdx = -1
    }
    
    private func setMoviesTableView() {
        popularMoviesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "popularMoviesCell")
        popularMoviesTableView.delegate = self
        popularMoviesTableView.dataSource = self
        popularMoviesTableView.separatorStyle = .none
    }
    
    private func setSearchCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: view.frame.width - 16, height: view.frame.height / 5)
        searchCollectionView.collectionViewLayout = layout
        searchCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "searchCollectionViewCell")
        searchCollectionView.isHidden = true
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
    
    private func setSearchBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:searchBar)
        searchBar.delegate = self
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: searchBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.width - 32),
            NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        ])
    }
    
    private func downloadPosterImages(isForSearchResults: Bool, startIdx: Int) {
        let data = isForSearchResults ? searchResults : popularMovies
        
        for (idx, movie) in data.enumerated() {
            if (idx < startIdx || movie.posterPath == nil) {
                continue
            }
            
            RemoteDataManager.shared.getPosterImageForMovie(imagePath: movie.posterPath!) { (posterImage) in
                DispatchQueue.main.async {
                    
                    autoreleasepool {
                        if (isForSearchResults) {
                            self.searchResults[idx].moviePosterImage = posterImage
//                            self.searchCollectionView.reloadItems(at: [IndexPath(row: idx, section: 0)])
                            self.searchCollectionView.reloadData()
                        } else {
                            self.popularMovies[idx].moviePosterImage = posterImage
                            self.popularMoviesTableView.reloadData()
//                            self.popularMoviesTableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
                        }

                    }
                    
                }
            }
        }
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popularMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularMoviesCell")!
        cell.selectionStyle = .none
        cell.textLabel?.textColor = SinemaAppManager.shared.primaryColor
        
        cell.textLabel?.text = popularMovies[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "popularMoviesCell")!
        selectedPopularMovieIdx = indexPath.row
        performSegue(withIdentifier: "MovieDetailVCFromSearch", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedPopularMovieIdx = -1
        return indexPath
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.lowercased()
        
        if searchTimer != nil { searchTimer?.invalidate() }
        
        guard !searchText.isEmpty else {
            if (popularMoviesTableView.isHidden) {
                toggleListViewsVisibility()
            }
            return
        }
        
        if (searchCollectionView.isHidden) {
            toggleListViewsVisibility()
        }

        searchTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(searchMovie), userInfo: ["searchText" : searchText], repeats: false)
        RunLoop.current.add(searchTimer ?? Timer(), forMode: .default)
    }
    
    @objc func searchMovie(_ timer: Timer) {
        guard let query = (timer.userInfo as! [String : String])["searchText"] else { return }

        RemoteDataManager.shared.getSearchResults(query: query, pageNumber: 1) { (movies) in
            if let movies = movies {
                self.searchResults = movies.movies

                self.downloadPosterImages(isForSearchResults: true, startIdx: 0)
                DispatchQueue.main.async {
                    print("Search Results Retrieved \(self.searchResults.count)")
                    self.searchCollectionView.reloadData()
                }
            }
        }
    }
    
    private func toggleListViewsVisibility() {
        [searchCollectionView as UIView, popularMoviesTableView as UIView, popularMoviesLabel as UIView].forEach { (listView) in
            listView.isHidden = !listView.isHidden
        }

    }
    
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell

        cell.update(with: searchResults[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
        selectedSearchMovieIdx = indexPath.row
        performSegue(withIdentifier: "MovieDetailVCFromSearch", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedSearchMovieIdx = -1
    }
    
}

