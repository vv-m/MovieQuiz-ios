import UIKit

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    
    private var mostPopularMoviesUrl: URL {
        // Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    if let errorMessage = mostPopularMovies.errorMessage {
                        switch errorMessage {
                        case "Invalid API Key":
                            handler(.failure(MostPopularMovies.IMDBError.invalidApiKeyError))
                        case "API Key Expired":
                            handler(.failure(MostPopularMovies.IMDBError.expiredApiKeyError))
                        case "Maximum usage reached":
                            handler(.failure(MostPopularMovies.IMDBError.maximumRequestLimitApiKeyError))
                        case "":
                            break
                        default:
                            handler(.failure(MostPopularMovies.IMDBError.unknownApiError))
                        }
                    }
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
