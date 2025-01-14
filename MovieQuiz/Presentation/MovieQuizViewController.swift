import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionAmount: Int = Constants.amountQuestion
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertDelegate?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - Нажатие на кнопки.
    
    @IBAction private func noButtonClicked(_: Any) {
        setButton(state: false)
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        self.currentQuestion = currentQuestion
    }
    
    @IBAction private func yesButtonClicked(_: Any) {
        setButton(state: false)
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        self.currentQuestion = currentQuestion
    }
    
    // MARK: - Включение и отключение кнопок "да" и "нет".
    
    private func setButton(state: Bool) {
        noButton.isEnabled = state
        yesButton.isEnabled = state
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.setButton(state: true)
        }
    }
    
    // MARK: - Метод конвертации.
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
    }
    
    // MARK: - Метод вывода на экран вопроса.
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    // MARK: - Метод изменения цвета рамки.
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8 // метод красит рамку
        
        if isCorrect {
            print("Ответ правильный")
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor // делаем рамку зеленой
        } else {
            print("Ответ НЕправильный")
            imageView.layer.borderColor = UIColor.ypRed.cgColor // делаем рамку красной
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.imageView.layer.borderWidth = 0 // убираем рамку
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Переход в один из сценариев.
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            let gameResult = GameResult(correct: correctAnswers, total: questionAmount, date: Date())
            statisticService.store(gameResult)
            let text =
                """
                Ваш результат \(correctAnswers)/\(questionAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(
                    statisticService.bestGame.date
                        .dateTimeString
                ))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                """
            
            let alertData = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
            )
            
            alertPresenter?.show(alertData: alertData)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Показ индикатора загрузки
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // MARK: - Показ индикатора загрузки
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertData = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                
                currentQuestionIndex = 0
                correctAnswers = 0
                
                questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertData: alertData)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
}
