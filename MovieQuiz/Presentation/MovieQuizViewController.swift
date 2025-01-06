import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, MovieQuizViewControllerProtocol {
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionAmount: Int = 3
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertDelegate: AlertDelegate?

    // MARK: - Lifecycle.

    override func viewDidLoad() {
        print(NSHomeDirectory())
        super.viewDidLoad()
        alertDelegate = AlertPresenter(viewController: self)
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки

        questionFactory.requestNextQuestion()
    }

    @IBAction private func noButtonClicked(_: Any) {
        guard let currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
        self.currentQuestion = currentQuestion
    }

    @IBAction private func yesButtonClicked(_: Any) {
        guard let currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
        self.currentQuestion = currentQuestion
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - Метод конвертации.

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionAmount)"
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: questionNumber)
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
            imageView.layer.borderColor = UIColor.green.cgColor // делаем рамку зеленой
        } else {
            print("Ответ НЕправильный")
            imageView.layer.borderColor = UIColor.red.cgColor // делаем рамку красной
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.imageView.layer.borderWidth = 0 // убираем рамку
            self.showNextQuestionOrResults()
        }
    }

    // MARK: - Переход в один из сценариев.

    private func showNextQuestionOrResults() {
        let text = correctAnswers == questionAmount ?
            "Поздравляем, вы ответили на \(questionAmount) из \(questionAmount)!" :
            "Вы ответили на \(correctAnswers) из \(questionAmount), попробуйте ещё раз!"

        if currentQuestionIndex == questionAmount - 1 {
            let alertData = AlertModel(
                title: "Ваш результат: \(correctAnswers)/\(questionAmount)",
                message: text,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.currentQuestionIndex = 0
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                })
            alertDelegate?.showResultQuiz(alertData: alertData)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}
