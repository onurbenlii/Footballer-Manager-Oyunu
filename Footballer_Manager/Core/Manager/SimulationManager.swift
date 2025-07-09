//
//  SimulationManager.swift
//  Footballer_Manager
//
//  Created by OnurBenliM2 on 9.07.2025.
//


// In: Core/Manager/SimulationManager.swift

import Foundation

class SimulationManager {
    
    // Bir maç haftasının simülasyon sonucunu ve güncellenmiş tabloyu tutar
    struct MatchWeekResult {
        let recentResults: [MatchResult]
        let updatedLeagueTable: [TeamStats]
        let updatedPlayers: [Footballer]
    }
    
    // Bir ayın tüm maçlarını simüle eden ana fonksiyon
    func simulateMatchWeek(teams: [Team], allPlayers: [Footballer], currentLeagueTable: [TeamStats]) -> MatchWeekResult {
        var shuffledTeams = teams.shuffled()
        var results: [MatchResult] = []
        var updatedTable = currentLeagueTable
        var updatedPlayers = allPlayers
        
        while shuffledTeams.count >= 2 {
            let homeTeam = shuffledTeams.removeFirst()
            let awayTeam = shuffledTeams.removeFirst()
            
            let matchSimulationResult = simulateMatch(homeTeam: homeTeam, awayTeam: awayTeam, allPlayers: updatedPlayers)
            let matchResult = matchSimulationResult.result
            
            results.append(matchResult)
            updatedTable = updateLeagueTable(with: matchResult, currentTable: updatedTable)
            updatedPlayers = matchSimulationResult.updatedPlayers // Oyuncu notları güncellenmiş listeyi al
        }
        
        return MatchWeekResult(recentResults: results, updatedLeagueTable: updatedTable, updatedPlayers: updatedPlayers)
    }
    
    private func getSquad(for teamId: UUID, from allPlayers: [Footballer]) -> [Footballer] {
        return allPlayers.filter { $0.teamID == teamId && $0.injury == nil && $0.activeTraining == nil }
    }

    private func simulateMatch(homeTeam: Team, awayTeam: Team, allPlayers: [Footballer]) -> (result: MatchResult, updatedPlayers: [Footballer]) {
        let homeSquad = getSquad(for: homeTeam.id, from: allPlayers)
        let awaySquad = getSquad(for: awayTeam.id, from: allPlayers)
        
        var mutablePlayers = allPlayers

        let homeAttack = homeSquad.filter { $0.position == .forward || $0.position == .midfielder }.reduce(0) { $0 + $1.shooting + ($1.pace / 2) }
        let homeDefense = homeSquad.filter { $0.position == .defender || $0.position == .goalkeeper }.reduce(0) { $0 + $1.defending + ($1.passing / 4) }
        
        let awayAttack = awaySquad.filter { $0.position == .forward || $0.position == .midfielder }.reduce(0) { $0 + $1.shooting + ($1.pace / 2) }
        let awayDefense = awaySquad.filter { $0.position == .defender || $0.position == .goalkeeper }.reduce(0) { $0 + $1.defending + ($1.passing / 4) }

        let homeGoalChance = (Double(homeAttack) * 1.1) / max(1.0, Double(awayDefense))
        let awayGoalChance = Double(awayAttack) / max(1.0, Double(homeDefense))
        
        var homeScore = 0
        var awayScore = 0
        
        for _ in 0..<6 {
            if Double.random(in: 0...2.5) < homeGoalChance { homeScore += 1 }
            if Double.random(in: 0...3.0) < awayGoalChance { awayScore += 1 }
        }

        let allPlaying = homeSquad + awaySquad
        let averageAbility = allPlaying.reduce(0) { $0 + $1.currentAbility } / max(1, allPlaying.count)
        
        for player in allPlaying {
            if let playerIndex = mutablePlayers.firstIndex(where: { $0.id == player.id }) {
                let rating = calculatePlayerRating(player: player, averageAbility: averageAbility, homeScore: homeScore, awayScore: awayScore, isHomeTeam: player.teamID == homeTeam.id)
                mutablePlayers[playerIndex].lastMatchRating = rating
            }
        }
        
        let finalResult = MatchResult(homeTeamID: homeTeam.id, awayTeamID: awayTeam.id, homeScore: homeScore, awayScore: awayScore)
        return (result: finalResult, updatedPlayers: mutablePlayers)
    }

    private func calculatePlayerRating(player: Footballer, averageAbility: Int, homeScore: Int, awayScore: Int, isHomeTeam: Bool) -> Double {
        var rating = 6.0
        rating += Double(player.currentAbility - averageAbility) / 15.0
        
        let goalsFor = isHomeTeam ? homeScore : awayScore
        let goalsAgainst = isHomeTeam ? awayScore : homeScore
        
        switch player.position {
        case .forward, .midfielder:
            rating += Double(goalsFor) * 0.4 - Double(goalsAgainst) * 0.1
        case .defender, .goalkeeper:
            rating -= Double(goalsAgainst) * 0.3 + Double(goalsFor) * 0.1
        }
        
        if goalsFor > goalsAgainst { rating += 0.5 }
        else if goalsFor < goalsAgainst { rating -= 0.3 }
        else { rating += 0.1 }

        return max(4.0, min(10.0, rating))
    }
    
    private func updateLeagueTable(with result: MatchResult, currentTable: [TeamStats]) -> [TeamStats] {
        var updatedTable = currentTable
        guard let homeStatsIndex = updatedTable.firstIndex(where: { $0.teamID == result.homeTeamID }),
              let awayStatsIndex = updatedTable.firstIndex(where: { $0.teamID == result.awayTeamID })
        else { return updatedTable }
        
        updatedTable[homeStatsIndex].played += 1
        updatedTable[awayStatsIndex].played += 1
        updatedTable[homeStatsIndex].goalsFor += result.homeScore
        updatedTable[homeStatsIndex].goalsAgainst += result.awayScore
        updatedTable[awayStatsIndex].goalsFor += result.awayScore
        updatedTable[awayStatsIndex].goalsAgainst += result.homeScore
        
        if result.homeScore > result.awayScore {
            updatedTable[homeStatsIndex].won += 1
            updatedTable[awayStatsIndex].lost += 1
        } else if result.awayScore > result.homeScore {
            updatedTable[awayStatsIndex].won += 1
            updatedTable[homeStatsIndex].lost += 1
        } else {
            updatedTable[homeStatsIndex].drawn += 1
            updatedTable[awayStatsIndex].drawn += 1
        }
        
        return updatedTable
    }
    
    func resetLeagueTable(for teams: [Team]) -> [TeamStats] {
        var newTable: [TeamStats] = []
        for team in teams {
            newTable.append(TeamStats(teamID: team.id))
        }
        return newTable
    }
}