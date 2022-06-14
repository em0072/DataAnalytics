//
//  NetworkRequest.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation

internal struct AnalyticsBatchUpdate: Codable {
    let requestDate: TimeInterval
    let bundleID: String
    let appState: String
    let systemVersion: String
    
    let events: [AppEvent]
}
