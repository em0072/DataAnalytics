//
//  Network.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation


struct NetworkConst {
    static let requestDate = "request_date"
    static let bundleID = "bundle_id"
    static let systemVersion = "system_version"
    static let appState = "app_state"
    static let BGTaskIdentifier = "me.mitko.sendAnalytics"
}

struct NetworkSettings {
    static let eventsBundlingDuration: TimeInterval = 10 * 60 // 10 minutes
}
