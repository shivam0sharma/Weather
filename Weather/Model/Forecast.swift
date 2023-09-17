//
//  Forecast.swift
//  Weather
//
//  Created by Shivam Sharma on 9/16/23.
//

import Foundation

struct Forecast: Codable {
    let daily: [ForecastDaily]
}

struct ForecastDaily: Codable {
    let dt: Date
    let temp: Temp
    let humidity: Int
    let weather: [Weather]
    let clouds: Int
    let pop: Double
}

struct Temp: Codable {
    let min: Double
    let max: Double
}

struct Weather: Codable {
    let id: Int
    let description: String
    let icon: String
}
