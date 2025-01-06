import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: UIViewController {
    var currentQuestionIndex: Int { get set }
    var correctAnswers: Int { get set }
    var questionFactory: QuestionFactoryProtocol? { get }
}

class AlertPresenter: AlertDelegate {
    weak var viewController: MovieQuizViewControllerProtocol?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
    }

    func showResultQuiz(alertData: AlertModel) {
        let alert = UIAlertController(
            title: alertData.title, // заголовок всплывающего окна
            message: alertData.message, // текст во всплывающем окне
            preferredStyle: .alert)

        let action = UIAlertAction(title: alertData.buttonText, style: .default) { _ in
            print("OK button is clicked!")
            alertData.completion()
        }

        alert.addAction(action) // добавляем в алерт кнопку
        viewController?.present(alert, animated: true, completion: nil)
    }
}
