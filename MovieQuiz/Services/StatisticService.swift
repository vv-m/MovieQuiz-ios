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
        case totalAnwsers
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

                let totalAnwsers = Double(storage.integer(forKey: Keys.totalAnwsers.rawValue))
                //            return Double(totalCorrectAnswers / qtyQuestion * gamesCount * 100)
                let accurency = Double(totalCorrectAnswers / totalAnwsers * 100)
                return accurency
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
        let currentTotalAnwsers = storage.integer(forKey: Keys.totalAnwsers.rawValue)

        let updatedtTotalCorrectAnswers: Int = gameResult.correct + currentTotalCorrectAnswers
        let updatedtTotalAnwsers: Int = gameResult.total + currentTotalAnwsers

        storage.set(updatedtTotalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(updatedtTotalAnwsers, forKey: Keys.totalAnwsers.rawValue)

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
        print("Всего вопросов: \(storage.integer(forKey: Keys.totalAnwsers.rawValue))")
        print("----------------")
    }

    func clearAll() {
        gamesCount = 0
        bestGame.correct = 0
        bestGame.total = 0
        totalAccuracy = 0

        storage.set(0, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(0, forKey: Keys.totalAnwsers.rawValue)
        print("--- ⚠️ Статистика сброшена ⚠️ ---")
        print("Количество игр: \(gamesCount)")
        print("Лучшая игра: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))")
        print("Общая точность: \(String(format: "%.1f", totalAccuracy))%")
        print("Всего правильных ответов: \(storage.integer(forKey: Keys.totalCorrectAnswers.rawValue))")
        print("Всего вопросов: \(storage.integer(forKey: Keys.totalAnwsers.rawValue))")
        print("----------------")
    }
}
