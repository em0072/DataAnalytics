//
//  AppEventType.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation

public enum AppEventType {
    
    case buttonClick
    case viewOpen
    case stateTransition
    case custom(String)
    
    
    internal var eventType: String {
        switch self {
        case .buttonClick:
            return "Button Click"
        case .viewOpen:
            return "View Open"
        case .stateTransition:
            return "State Transition"
        case .custom(let eventTypeName):
            return eventTypeName
        }
    }
    
}
