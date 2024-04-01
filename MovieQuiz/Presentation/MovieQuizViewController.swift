import UIKit

final class MovieQuizViewController:
                                        
                                        
    UIViewController {
    
    @IBOutlet weak var labelTest: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        func printAllAvailableFonts() {
            let familyNames = UIFont.familyNames.sorted()
            
            for familyName in familyNames {
                print("Family: \(familyName)")
                
                let fontNames = UIFont.fontNames(forFamilyName: familyName)
                for fontName in fontNames {
                    print("  Font: \(fontName)")
                }
            }
        }

        // Вызовите функцию, чтобы распечатать все доступные шрифты
        printAllAvailableFonts()
        
        labelTest.text = "Бла-бла бла"
        labelTest.font = UIFont(name: "YSDisplay-Medium", size: 20)
        buttonYes.setTitleColor(UIColor.ypBlack, for: .normal)
        buttonYes.tintColor = UIColor.ypGray
        buttonYes.frame.size.width = 156
        buttonYes.frame.size.height = 60
        buttonYes.contentVerticalAlignment = .center
        buttonYes.contentHorizontalAlignment = .center
        buttonYes.setTitle("Да", for: .normal)
        buttonYes.subtitleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        DispatchQueue.main.async {
            self.buttonYes.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
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
