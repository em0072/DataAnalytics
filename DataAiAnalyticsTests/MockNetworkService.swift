//
//  SuccessMockNetworkService.swift
//  DataAiAnalyticsTests
//
//  Created by Evgeny Mitko on 14/06/2022.
//

import Foundation
@testable import DataAiAnalytics

internal class MockNetworkService: Networkable {
    
    internal var success: Bool = true
    
    func sendRequest(_ data: Data) throws {
        if !success {
            throw NetworkError.networkUnavailable
        }
    }
    
    
}
