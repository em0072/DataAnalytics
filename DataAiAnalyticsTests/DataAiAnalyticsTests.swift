//
//  DataAiAnalyticsTests.swift
//  DataAiAnalyticsTests
//
//  Created by Evgeny Mitko on 14/06/2022.
//

import XCTest
@testable import DataAiAnalytics

class DataAiAnalyticsTests: XCTestCase {
    
    var networkService = MockNetworkService()
    var analyticsController: AnalyticsController!

    override func setUpWithError() throws {
        analyticsController = AnalyticsController(analyticsEventsService: AnalyticsEventsService(), networkService: networkService)
        analyticsController.addNewAppEvent(.custom("Database"), eventName: "New Entry Created")
        analyticsController.addNewAppEvent(.buttonClick, eventName: "Log In")
        analyticsController.addNewAppEvent(.stateTransition, eventName: "To foreground")
        analyticsController.addNewAppEvent(.viewOpen, eventName: "Registration Screen")
    }

    override func tearDownWithError() throws {
        
    }

    func testEventsListNumber() async throws {
        let eventsList = await analyticsController.getListOfAllEvents()
        XCTAssert(eventsList.count == 4)
    }
    
    func testEventsListComposition() async throws {
        let eventsList = await analyticsController.getListOfAllEvents()
        var hasCustomEvent = false,
            hasButtonEvent = false,
            hasStateTransitionEvent = false,
            hasViewOpenEvent = false
        for (i, events) in eventsList.enumerated() {
            switch events.type {
            case .custom(_):
                XCTAssert(i == 0)
                hasCustomEvent = true
            case .buttonClick:
                XCTAssert(i == 1)
                hasButtonEvent = true
            case .stateTransition:
                XCTAssert(i == 2)
                hasStateTransitionEvent = true
            case .viewOpen:
                XCTAssert(i == 3)
                hasViewOpenEvent = true
            }
        }
        XCTAssert(hasCustomEvent && hasButtonEvent && hasStateTransitionEvent && hasViewOpenEvent)
    }
    
    func testCachingMecanism() async {
            networkService.success = false
            await analyticsController.uploadAnalyticsIfNeeded()
            let eventsList = await analyticsController.getListOfAllEvents()
            XCTAssert(eventsList.count == 4)
    }
    
    func testSendingAnalytics() async {
        networkService.success = true
            await analyticsController.uploadAnalyticsIfNeeded()
            let eventsList = await analyticsController.getListOfAllEvents()
            XCTAssert(eventsList.count == 0)
    }
}
