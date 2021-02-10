//
//  RemoteDataManager.swift
//  Sinema
//
//  Created by Metin Ozturk on 7.02.2021.
//

import UIKit

class RemoteDataManager {
    
    static let shared : RemoteDataManager = RemoteDataManager()
    
    private lazy var movieDBAPIKey =  Bundle.main.infoDictionary!["MovieDBAPIKey"] as! String
    private let baseUrl = "https://api.themoviedb.org/3"
    private let imageBaseUrl = "https://image.tmdb.org/t/p/w500"
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(DateFormatter.movieDBDateFormat)
        return decoder
    }()
    
    private init() {}
    
    private func getDataFromUrl(requestUrl: URL, completion: @escaping (Data?, Int?) -> Void ) {
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let httpResponseCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let error = error {
                print("Error while requesting data from API: \(error)")
                completion(nil, httpResponseCode)
                return
            }
            
            if let data = data, 200...299 ~= httpResponseCode {
                completion(data, httpResponseCode)
            } else  {
                completion(nil, httpResponseCode)
            }
            
        }
        
        task.resume()
    }
    
    func getPosterImageForMovie(imagePath: String, completion: @escaping (UIImage?) -> Void) {
        if let requestUrl = URL(string: imageBaseUrl + "\(imagePath)") {
            getDataFromUrl(requestUrl: requestUrl) { (data, httpResponse) in
                if let data = data, let retrievedImage = UIImage(data: data) {
                    completion(retrievedImage)
                } else {
                    completion(nil)
                }
                
            }
        }
    }
    
    func getMovies(pageNumber: Int, movieType: MovieType, completion: @escaping (Movies?) -> Void) {
        if let requestUrl = URL(string: baseUrl + "/movie/\(movieType.rawValue)?api_key=\(movieDBAPIKey)&language=en-US&page=\(pageNumber)") {
            
            getDataFromUrl(requestUrl: requestUrl) { data, httpResponse in
                if let data = data, let movies = try? self.jsonDecoder.decode(Movies.self, from: data) {
                    if (movieType == .Popular) {
                        completion(movies)
                    } else {
                        let sortedMovies = Movies(movies: movies.movies.sorted(by: { $0.releaseDate > $1.releaseDate }))
                        completion(sortedMovies)
                    }

                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getSearchResults(query: String, pageNumber: Int, completion: @escaping (Movies?) -> Void) {
        if let requestUrl = URL(string: baseUrl + "/search/movie?api_key=\(movieDBAPIKey)&language=en-US&query=\(query)&page=\(pageNumber)&include_adult=false") {
            getDataFromUrl(requestUrl: requestUrl) { (data, httpResponse) in
                if let data = data, let movies = try? self.jsonDecoder.decode(Movies.self, from: data) {
                    completion(movies)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getMovieDetail(movieId: Int, completion: @escaping (MovieDetail?) -> Void) {
        if let requestUrl = URL(string: baseUrl + "/movie/\(movieId)?api_key=\(movieDBAPIKey)&language=tr-TR") {
            getDataFromUrl(requestUrl: requestUrl) { (data, httpResponse) in
                if let data = data, let movieDetail = try? self.jsonDecoder.decode(MovieDetail.self, from: data){
                    completion(movieDetail)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
}
