//
//  DataAnalytics.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation
import UIKit

internal actor AnalyticsEventsService {
    
    var eventQueue: [AppEvent] = []
    var cachedEvents: [AppEvent] = []
    internal func addEvent(_ event: AppEvent) {
        eventQueue.append(event)
    }
    
    internal func getLatestEvents() -> [AppEvent] {
        var eventToSend = [AppEvent]()
        if !cachedEvents.isEmpty {
            //Check if there is 10 elements in the Cached Events array. If not, take what is there, otherwise take 10.
            let numberOfElements = min(cachedEvents.count, 10)
            eventToSend = Array(cachedEvents.prefix(numberOfElements))
            cachedEvents.removeFirst(numberOfElements)
        } else {
            eventToSend = eventQueue
            eventQueue.removeAll()
        }
        return eventToSend
    }
    
    internal func cacheEvents(_ events: [AppEvent]) {
        cachedEvents.append(contentsOf: events)
        cachedEvents.append(contentsOf: eventQueue)
        eventQueue.removeAll()
    }
    
    internal func getListOfAllEvents() -> [AppEvent] {
        var allEvents = [AppEvent]()
        allEvents.append(contentsOf: cachedEvents)
        allEvents.append(contentsOf: eventQueue)
        return allEvents
    }
    
    
}
