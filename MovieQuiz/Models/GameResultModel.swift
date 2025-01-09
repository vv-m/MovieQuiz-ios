import Foundation

struct GameResult {
    var correct: Int
    var total: Int
    var date: Date

    func isBetterThen(_ gameResult: GameResult) -> Bool {
        correct > gameResult.correct
    }
}
