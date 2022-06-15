//
//  AppEvent.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation
import UIKit


public struct AppEvent: Codable {
    
    let type: AppEventType
    let name: String
    let date: TimeInterval
}

extension AppEvent {
    
    enum CodingKeys: String, CodingKey {
        case type = "eventType"
        case name = "eventName"
        case date = "eventDate"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let typeRawValue = try? values.decode(String.self, forKey: .type),
              let nameValue = try? values.decode(String.self, forKey: .name),
              let dateValue = try? values.decode(TimeInterval.self, forKey: .date) else {
            throw NetworkError.invalidDataFormat
        }
        
        name = nameValue
        date = dateValue
        
        switch typeRawValue {
        case AppEventType.buttonClick.eventType:
            type = .buttonClick
        case AppEventType.viewOpen.eventType:
            type = .viewOpen
        default:
            type = .custom(typeRawValue)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
        try container.encode(type.eventType, forKey: .type)
    }
    
}

