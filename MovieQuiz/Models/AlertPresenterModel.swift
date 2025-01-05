import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: String {
        return message
    }
}
