import UIKit

final class MovieQuizPresenter {
    let questionAmount: Int = Constants.amountQuestion
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    
    func noButtonClicked() {
//        viewController?.setButton(state: false)
        guard let currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        self.currentQuestion = currentQuestion
    }
    
    func yesButtonClicked() {
//        viewController?.setButton(state: false)
        guard let currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        self.currentQuestion = currentQuestion
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
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func swutchToTextQuestion() {
        currentQuestionIndex += 1
    }
}
