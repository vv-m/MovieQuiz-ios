import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?

    // MARK: - Lifecycle.

    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки

        questionFactory.requestNextQuestion()
    }

    @IBAction private func noButtonClicked(_: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
        self.currentQuestion = currentQuestion
    }

    @IBAction private func yesButtonClicked(_: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
        self.currentQuestion = currentQuestion
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - Метод конвертации.

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionAmount)"
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0 // убираем рамку
            self.showNextQuestionOrResults()
        }
    }

    // MARK: - Резултат квиза

    private func showResultQuiz(text: String?) {
        let alert = UIAlertController(
            title: text, // заголовок всплывающего окна
            message: "Ваш результат: \(correctAnswers)/\(questionAmount)", // текст во всплывающем окне
            preferredStyle: .alert
        ) // preferredStyle может быть .alert или .actionSheet

        // создаём для алерта кнопку с действием
        // в замыкании пишем, что должно происходить при нажатии на кнопку
        let action = UIAlertAction(title: "Сыграть еще раз", style: .default) { _ in
            print("OK button is clicked!")

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alert.addAction(action) // добавляем в алерт кнопку
        present(alert, animated: true, completion: nil) // показываем всплывающее окно
    }

    // MARK: - Переход в один из сценариев.

    private func showNextQuestionOrResults() {
        let text = correctAnswers == questionAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
        if currentQuestionIndex + 1 == questionAmount {
            showResultQuiz(text: text)
        }

        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
}
