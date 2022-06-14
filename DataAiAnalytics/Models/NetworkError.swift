//
//  NetworkError.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation

enum NetworkError: LocalizedError {
    case networkUnavailable
    case invalidDataFormat
    
    public var errorDescription: String? {
            switch self {
            case .networkUnavailable:
                return "Network is unavailable. Check your network connection!"
            case .invalidDataFormat:
                return "Data came in unexpected format."
            }
    }
}
