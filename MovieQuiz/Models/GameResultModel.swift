import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThen(_ gameResult: GameResult) -> Bool {
        correct > gameResult.correct
    }
}
