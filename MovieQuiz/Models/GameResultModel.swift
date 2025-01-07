import UIKit

struct GameResult {
    var correct: Int
    var total: Int
    var date: Date

    func isBetterThen(_ gameResult: GameResult) -> Bool {
        if correct > gameResult.correct {
            return true
        }

        return false
    }
}
