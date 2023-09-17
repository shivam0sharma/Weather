//
//  APIError.swift
//  Weather
//
//  Created by Shivam Sharma on 9/16/23.
//

import Foundation

public enum APIError: Error {
    case error(_ errorString: String)
}
