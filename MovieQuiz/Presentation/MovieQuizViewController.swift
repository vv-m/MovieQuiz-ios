import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    var alertPresenter: AlertDelegate? { get set }
    func show(quiz step: QuizStepViewModel)
    func showAnswerResult(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func setButton(state: Bool)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    var alertPresenter: AlertDelegate?
    
    // MARK: - Lifecycle. ✅
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.transform = CGAffineTransform(scaleX: 3.0, y: 3.0) // увеличить в 3 раза
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButton(state: false)
        presenter.yesButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButton(state: false)
        presenter.yesButtonClicked()
    }
    func setButton(state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
    }
    func show(quiz step: QuizStepViewModel) {
            imageView.layer.borderColor = UIColor.clear.cgColor
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
        }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.didAnswer(isCorrectAnswer: isCorrect)
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor // делаем рамку красной
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.imageView.layer.borderWidth = 0 // убираем рамку
            self?.presenter.showNextQuestionOrResults()
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertData = AlertModel(
            identifier: "",
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                presenter.restartGame()
                presenter.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertData: alertData)
    }
}
