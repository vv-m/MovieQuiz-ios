import Foundation

protocol AlertDelegate: AnyObject {
    func show(alertData: AlertModel)
}
