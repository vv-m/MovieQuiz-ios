import UIKit

final class MovieQuizViewController:
                                        
                                        
    UIViewController {
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 1 // толщина рамки
        imageView.layer.borderColor = UIColor.white.cgColor // делаем рамку белой
        imageView.layer.cornerRadius = 6 // радиус скругления углов рамки
        
        let currentQuestion = questions[currentQuestionIndex]
        
        show(quiz: convert(model: currentQuestion))
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        if givenAnswer == currentQuestion.correctAnswer {
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        
        if givenAnswer == currentQuestion.correctAnswer {
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private let questions: [QuizQuestion] = [QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
                                             QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
                                             
    ]
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        // Попробуйте написать код конвертации самостоятельно
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        // попробуйте написать код показа на экран самостоятельно
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        imageView.layer.borderWidth = 8
        if isCorrect {
            correctAnswer += 1
            imageView.layer.borderColor = UIColor.green.cgColor // делаем рамку зеленой
        } else {
            imageView.layer.borderColor = UIColor.red.cgColor // делаем рамку красной
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 1
            self.imageView.layer.borderColor = UIColor.white.cgColor // делаем рамку белой
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 { // 1
            // идём в состояние "Результат квиза"
            // создаём объекты всплывающего окна
            let alert = UIAlertController(title: "Этот раунд окончен!", // заголовок всплывающего окна
                                          message: "Ваш результат: \(correctAnswer)/\(questions.count)", // текст во всплывающем окне
                                          preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

            // создаём для алерта кнопку с действием
            // в замыкании пишем, что должно происходить при нажатии на кнопку
            let action = UIAlertAction(title: "Сыграть еще раз", style: .default) { _ in
              print("OK button is clicked!")
                self.currentQuestionIndex = 0
                self.correctAnswer = 0
                self.show(quiz: self.convert(model: self.questions[0]))
            }

            // добавляем в алерт кнопку
            alert.addAction(action)

            // показываем всплывающее окно
            self.present(alert, animated: true, completion: nil)
        } else { // 2
            currentQuestionIndex += 1
            // идём в состояние "Вопрос показан"
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
        
    }
}
    /*
     Mock-данные
     
     
     Картинка: The Godfather
     Настоящий рейтинг: 9,2
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: The Dark Knight
     Настоящий рейтинг: 9
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: Kill Bill
     Настоящий рейтинг: 8,1
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: The Avengers
     Настоящий рейтинг: 8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: Deadpool
     Настоящий рейтинг: 8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: The Green Knight
     Настоящий рейтинг: 6,6
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: ДА
     
     
     Картинка: Old
     Настоящий рейтинг: 5,8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     
     
     Картинка: The Ice Age Adventures of Buck Wild
     Настоящий рейтинг: 4,3
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     
     
     Картинка: Tesla
     Настоящий рейтинг: 5,1
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     
     
     Картинка: Vivarium
     Настоящий рейтинг: 5,8
     Вопрос: Рейтинг этого фильма больше чем 6?
     Ответ: НЕТ
     */
