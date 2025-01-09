import UIKit

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount

        case bestGameDate
        case bestGameCorrect
        case bestGameTotal

        case totalCorrectAnswers
        case totalAnswers
        case totalAccuracy
    }

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            if let bestGameDate = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                let bestGameCorrect = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
                let bestGameTotal = storage.integer(forKey: Keys.bestGameTotal.rawValue)
                return GameResult(correct: bestGameCorrect, total: bestGameTotal, date: bestGameDate)
            }

            return GameResult(correct: 0, total: 0, date: Date())
        }
        set {
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
        }
    }

    /// отношение всех правильных ответов от общего числа вопросов
    var totalAccuracy: Double {
        get {
            if gamesCount != 0 {
                print("Пытаюсь получить totalAccuracy")
                let totalCorrectAnswers = Double(storage.integer(forKey: Keys.totalCorrectAnswers.rawValue))

                let totalAnswers = Double(storage.integer(forKey: Keys.totalAnswers.rawValue))
                //            return Double(totalCorrectAnswers / qtyQuestion * gamesCount * 100)
                let accuracy = Double(totalCorrectAnswers / totalAnswers * 100)

                return accuracy
            }

            return 0
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }

    func store(_ gameResult: GameResult) {
        gamesCount += 1
        let currentTotalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        let currentTotalAnswers = storage.integer(forKey: Keys.totalAnswers.rawValue)

        let updatedTotalCorrectAnswers: Int = gameResult.correct + currentTotalCorrectAnswers
        let updatedTotalAnswers: Int = gameResult.total + currentTotalAnswers

        storage.set(updatedTotalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(updatedTotalAnswers, forKey: Keys.totalAnswers.rawValue)

        if gameResult.isBetterThen(bestGame) {
            print("Новый рекорд 🎉")
            bestGame = gameResult
        }
    }

    func getAll() {
        print("--- Статистика ---")
        print("Количество игр: \(gamesCount)")
        print("Лучшая игра: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))")
        print("Общая точность: \(String(format: "%.1f", totalAccuracy))%")
        print("Всего правильных ответов: \(storage.integer(forKey: Keys.totalCorrectAnswers.rawValue))")
        print("Всего вопросов: \(storage.integer(forKey: Keys.totalAnswers.rawValue))")
        print("----------------")
    }

    func clearAll() {
        gamesCount = 0
        bestGame.correct = 0
        bestGame.total = 0
        totalAccuracy = 0

        storage.set(0, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(0, forKey: Keys.totalAnswers.rawValue)
        print("--- ⚠️ Статистика сброшена ⚠️ ---")
        print("Количество игр: \(gamesCount)")
        print("Лучшая игра: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))")
        print("Общая точность: \(String(format: "%.1f", totalAccuracy))%")
        print("Всего правильных ответов: \(storage.integer(forKey: Keys.totalCorrectAnswers.rawValue))")
        print("Всего вопросов: \(storage.integer(forKey: Keys.totalAnswers.rawValue))")
        print("----------------")
    }
}
