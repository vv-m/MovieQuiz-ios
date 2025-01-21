import UIKit



final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionAmount: Int = Constants.amountQuestion
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewControllerProtocol?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        self.currentQuestion = currentQuestion
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.setButton(state: true)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        // Вопрос для ревью - зачем мы называем функции в одном классе одинаковыми именами (так укзаано в теории)?
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let gameResult = GameResult(correct: correctAnswers, total: self.questionAmount, date: Date())
            
            statisticService.store(gameResult)
            
            let text =
                """
                Ваш результат \(correctAnswers)/\(self.questionAmount)
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
                    self?.restartGame()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                }
            )
            
            viewController?.alertPresenter?.show(alertData: alertData)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
}
