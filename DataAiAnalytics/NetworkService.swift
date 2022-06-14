//
//  NetworkService.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation
import Combine

protocol Networkable {
    func sendRequest(_ data: Data) throws
}

internal class NetworkService: Networkable {
        
    internal func sendRequest(_ data: Data) throws {
        let number = Int.random(in: 665..<667)
        if number == 666 {
            throw NetworkError.networkUnavailable
        } else {
            let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            print("Request body:\n \(json ?? [:])")
        }
    }
    
}
