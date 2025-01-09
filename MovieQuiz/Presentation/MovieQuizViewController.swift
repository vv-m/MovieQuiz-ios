import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionAmount: Int = Constants.amountQuestion
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertDelegate: AlertDelegate?
    private var statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Lifecycle.

    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService.clearAll()
        alertDelegate = AlertPresenter(viewController: self)
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки

        questionFactory.requestNextQuestion()
    }

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
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionAmount)"

        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber
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

            alertDelegate?.showResultQuiz(alertData: alertData)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
