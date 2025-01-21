import UIKit

struct MostPopularMovies: Codable {
    let errorMessage: String?
    let items: [MostPopularMovie]
    
    enum IMDBError: LocalizedError {
        case invalidApiKeyError
        case expiredApiKeyError
        case maximumRequestLimitApiKeyError
        case unknownApiError
        
        var errorDescription: String? {
            switch self {
            case .invalidApiKeyError:
                return "Недействительный ключ API. Пожалуйста, проверьте ваш ключ."
            case .expiredApiKeyError:
                return "Срок действия ключа API истек. Пожалуйста, обновите ваш ключ."
            case .maximumRequestLimitApiKeyError:
                return "Достигнут максимальный лимит запросов. Попробуйте позже."
            case .unknownApiError:
                return "Произошла неизвестная ошибка. Попробуйте позже."
            }
        }
    }
    
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        guard let newUrl = URL(string: imageUrlString) else {
            return imageURL
        }
        
        return newUrl
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
    
    enum LoadError: LocalizedError {
        case imageLoadError
        
        var errorDescription: String? {
            switch self {
            case .imageLoadError:
                return "Не удалось загрузить изображение."
            }
        }
    }
}
