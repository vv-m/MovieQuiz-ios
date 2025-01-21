import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private let presenter: MovieQuizPresenter = MovieQuizPresenter()
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertDelegate?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.transform = CGAffineTransform(scaleX: 3.0, y: 3.0) // увеличить в 3 раза
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        showLoadingIndicator()
        questionFactory?.loadData()
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
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.setButton(state: true)
        }
    }
    
    // MARK: - Метод вывода на экран вопроса.
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    // MARK: - Метод изменения цвета рамки.
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8 // метод красит рамку
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor // делаем рамку зеленой
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor // делаем рамку красной
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.imageView.layer.borderWidth = 0 // убираем рамку
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Переход в один из сценариев.
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let gameResult = GameResult(correct: correctAnswers, total: presenter.questionAmount, date: Date())
            statisticService.store(gameResult)
            let text =
                """
                Ваш результат \(correctAnswers)/\(presenter.questionAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(
                    statisticService.bestGame.date
                        .dateTimeString
                ))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            
            let alertData = AlertModel(
                identifier: "Game results",
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.presenter.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
            )
            
            alertPresenter?.show(alertData: alertData)
        } else {
            presenter.swutchToTextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Показ индикатора загрузки
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    // MARK: - Показ индикатора загрузки
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertData = AlertModel(
            identifier: "",
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                
                presenter.resetQuestionIndex()
                correctAnswers = 0
                
                questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertData: alertData)
    }
    
    func didLoadDataFromServer() {
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
        hideLoadingIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}
