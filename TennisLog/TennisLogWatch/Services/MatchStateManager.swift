import Foundation
import WatchKit

/// In-memory match state that lives on the Watch during an active match.
/// When the match ends, it serialises itself and sends to iPhone via WatchConnectivity.
@MainActor
final class MatchStateManager: ObservableObject {

    // MARK: - Published state

    @Published var phase: MatchPhase = .playing
    @Published var sets: [(mine: Int, theirs: Int)] = [(0, 0)]
    @Published var myGamePoints: Int   = 0
    @Published var theirGamePoints: Int = 0
    @Published var isInTiebreak: Bool  = false
    @Published var isInSuperTiebreak: Bool = false
    @Published var isFirstServe: Bool  = true
    @Published var pendingPointWinner: PointWinner? = nil  // tap-mode: who won

    @Published var scoringMode: ScoringMode = .voicePlusTap
    @Published var matchFormat: MatchFormat = .singles

    @Published var recordedPoints: [RecordedPoint] = []
    @Published var lastGameWinner: PointWinner?
    @Published var lastSetScore: (mine: Int, theirs: Int)?

    // MARK: - Computed display

    var currentSetIndex: Int { sets.count - 1 }

    var mySetScore: Int  { sets[currentSetIndex].mine }
    var theirSetScore: Int { sets[currentSetIndex].theirs }

    /// Display string for current point in the game (0/15/30/40/Ad or tiebreak number)
    var myPointDisplay: String    { pointDisplay(my: myGamePoints, their: theirGamePoints, forMe: true) }
    var theirPointDisplay: String { pointDisplay(my: myGamePoints, their: theirGamePoints, forMe: false) }

    var isMatchComplete: Bool { phase == .matchOver }

    private var totalGamesPlayed: Int { sets.flatMap { [$0.mine, $0.theirs] }.reduce(0, +) }

    // MARK: - Scoring

    func scorePoint(winner: PointWinner, shotType: ShotType? = nil, errorType: ErrorType? = nil) {
        let point = RecordedPoint(
            winner: winner,
            shotType: shotType,
            errorType: errorType,
            serveWasFault: !isFirstServe,
            setIndex: currentSetIndex,
            gameIndex: totalGamesPlayed)
        recordedPoints.append(point)

        isFirstServe = true  // reset for next point

        if isInTiebreak || isInSuperTiebreak {
            scoreTiebreakPoint(winner: winner)
        } else {
            scoreRegularPoint(winner: winner)
        }
    }

    func callFault() {
        isFirstServe = false
        phase = .faultCalled
    }

    func callDoubleFault() {
        scorePoint(winner: .them, shotType: .doubleFault)
    }

    func confirmFaultDismissed() {
        // Return to playing after fault screen is acknowledged
        phase = .playing
    }

    func undoLastPoint() {
        guard !recordedPoints.isEmpty else { return }
        recordedPoints.removeLast()
        recomputeFromPoints()
    }

    // MARK: - Tap-mode shot entry

    /// Called in voicePlusTap mode after "point me/them" is spoken.
    func beginShotEntry(winner: PointWinner) {
        pendingPointWinner = winner
        phase = .awaitingShotType
    }

    func completeShotEntry(shotType: ShotType? = nil, errorType: ErrorType? = nil) {
        guard let winner = pendingPointWinner else { return }
        pendingPointWinner = nil
        phase = .playing
        scorePoint(winner: winner, shotType: shotType, errorType: errorType)
    }

    func skipShotEntry() {
        completeShotEntry()  // records without classification
    }

    // MARK: - Private scoring logic

    private func scoreRegularPoint(winner: PointWinner) {
        if winner == .me { myGamePoints += 1 }
        else             { theirGamePoints += 1 }

        // Win condition: 4+ points AND 2+ ahead
        if myGamePoints >= 4 && myGamePoints >= theirGamePoints + 2 {
            gameWon(by: .me)
        } else if theirGamePoints >= 4 && theirGamePoints >= myGamePoints + 2 {
            gameWon(by: .them)
        }
        // Normalise deuce — keep both at 3 so display works
        if myGamePoints > 3 && theirGamePoints > 3 && myGamePoints == theirGamePoints {
            myGamePoints = 3; theirGamePoints = 3
        }
    }

    private func scoreTiebreakPoint(winner: PointWinner) {
        if winner == .me { myGamePoints += 1 }
        else             { theirGamePoints += 1 }

        let limit = isInSuperTiebreak ? 10 : 7
        if myGamePoints >= limit && myGamePoints >= theirGamePoints + 2 {
            if isInSuperTiebreak { matchWon(by: .me) } else { setWon(by: .me) }
        } else if theirGamePoints >= limit && theirGamePoints >= myGamePoints + 2 {
            if isInSuperTiebreak { matchWon(by: .them) } else { setWon(by: .them) }
        }
    }

    private func gameWon(by winner: PointWinner) {
        lastGameWinner = winner
        myGamePoints = 0; theirGamePoints = 0
        if winner == .me { sets[currentSetIndex].mine += 1 }
        else             { sets[currentSetIndex].theirs += 1 }

        let (mine, theirs) = sets[currentSetIndex]

        // Tiebreak at 6-6 (or super tiebreak in set 3)
        if mine == 6 && theirs == 6 {
            if currentSetIndex == 2 {
                isInSuperTiebreak = true
            } else {
                isInTiebreak = true
            }
            phase = .gameOver
            return
        }

        // Set won: 6+ games AND 2+ ahead (no tiebreak applies above)
        if mine >= 6 && mine >= theirs + 2 {
            setWon(by: .me); return
        }
        if theirs >= 6 && theirs >= mine + 2 {
            setWon(by: .them); return
        }

        WKInterfaceDevice.current().play(.success)
        phase = .gameOver
    }

    private func setWon(by winner: PointWinner) {
        isInTiebreak = false; isInSuperTiebreak = false
        lastSetScore = sets[currentSetIndex]

        // Best of 3: check if match is over
        let setsWon = sets.filter { $0.mine > $0.theirs }.count + (winner == .me ? 0 : 0)
        // Recount properly
        var mySetWins = sets.filter { $0.mine > $0.theirs }.count
        var theirSetWins = sets.filter { $0.theirs > $0.mine }.count

        if winner == .me { mySetWins += 0 } // already counted from games, just flag
        // Actually just check after we'd add the new set result
        // The current set is already updated in sets[], so count directly
        let finalMy = sets.filter { $0.mine > $0.theirs }.count
        let finalTheir = sets.filter { $0.theirs > $0.mine }.count

        if finalMy == 2    { matchWon(by: .me);   return }
        if finalTheir == 2 { matchWon(by: .them);  return }

        // Start next set
        sets.append((0, 0))
        myGamePoints = 0; theirGamePoints = 0
        WKInterfaceDevice.current().play(.success)
        phase = .setOver
    }

    private func matchWon(by winner: PointWinner) {
        WKInterfaceDevice.current().play(.success)
        phase = .matchOver
        // Send result to iPhone
        WatchConnectivityBridge.shared.sendMatchResult(
            points: recordedPoints, sets: sets, winner: winner)
    }

    // MARK: - Undo helper

    private func recomputeFromPoints() {
        // Reset to blank and replay all points
        sets = [(0, 0)]
        myGamePoints = 0; theirGamePoints = 0
        isInTiebreak = false; isInSuperTiebreak = false
        isFirstServe = true
        phase = .playing

        let savedPoints = recordedPoints
        recordedPoints = []
        for p in savedPoints {
            scorePoint(winner: p.winner, shotType: p.shotType, errorType: p.errorType)
        }
    }

    // MARK: - Display helpers

    private func pointDisplay(my: Int, their: Int, forMe: Bool) -> String {
        let pts = forMe ? my : their
        let opp = forMe ? their : my

        if isInTiebreak || isInSuperTiebreak {
            return "\(pts)"
        }

        let isDeuce = my >= 3 && their >= 3
        if isDeuce {
            if pts == opp   { return "40" }   // deuce
            return pts > opp ? "AD" : "40"
        }
        return ["0", "15", "30", "40"][min(pts, 3)]
    }
}

// MARK: - RecordedPoint (watch-side value type)

struct RecordedPoint {
    let winner: PointWinner
    let shotType: ShotType?
    let errorType: ErrorType?
    let serveWasFault: Bool
    let setIndex: Int
    let gameIndex: Int
}
