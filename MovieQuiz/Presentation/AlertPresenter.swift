import UIKit

final class AlertPresenter: AlertDelegate {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func show(alertData: AlertModel) {
        let alert = UIAlertController(
            title: alertData.title, // заголовок всплывающего окна
            message: alertData.message, // текст во всплывающем окне
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = alertData.identifier
        
        let action = UIAlertAction(title: alertData.buttonText, style: .default) { _ in
            alertData.completion()
        }

        alert.addAction(action) // добавляем в алерт кнопку
        viewController?.present(alert, animated: true, completion: nil)
    }
}
