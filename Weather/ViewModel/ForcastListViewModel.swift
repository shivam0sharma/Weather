//
//  ForcastListViewModel.swift
//  Weather
//
//  Created by Shivam Sharma on 9/16/23.
//

import CoreLocation
import Foundation
import SwiftUI

class ForecastListViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    struct AppError: Identifiable {
        let id = UUID().uuidString
        let errorString: String
    }
    
    @Published var forecasts: [ForecastViewModel] = []
    var appError: AppError? = nil
    @Published var isLoading: Bool = false
    @AppStorage("location") var storageLocation: String = ""
    @Published var location = ""
    @AppStorage("system") var system: Int = 0 {
        didSet {
            for i in 0..<forecasts.count {
                forecasts[i].system = system
            }
        }
    }
    
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        location = storageLocation
        getWeatherForecast()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        location.fetchCity { city, error in
            guard let city = city, error == nil else { return }
            
            self.location = city
            self.getWeatherForecast()
        }
    }
    
    func getWeatherForecast() {
        storageLocation = location
        UIApplication.shared.endEditing()
        if location == "" {
            forecasts = []
        } else {
            isLoading = true
            let apiService = APIService.shared
            CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
                if let error = error as? CLError {
                    switch error.code {
                    case .locationUnknown, .geocodeFoundNoResult, .geocodeFoundPartialResult:
                        self.appError = AppError(errorString: NSLocalizedString("Unable to determine location from this text.", comment: ""))
                    case .network:
                        self.appError = AppError(errorString: NSLocalizedString("You do not appear to have a network connection.", comment: ""))
                    default:
                        self.appError = AppError(errorString: error.localizedDescription)
                    }
                    self.isLoading = false
                }
                
                self.fetchWeatherForecastFor(lat: placemarks?.first?.location?.coordinate.latitude, lon: placemarks?.first?.location?.coordinate.longitude)
            }
        }
    }
    
    private func fetchWeatherForecastFor(lat: CLLocationDegrees?, lon: CLLocationDegrees?) {
        if let lat = lat, let lon = lon {
            APIService.shared.getJSON(urlString: "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,hourly,alerts&appid=3816382f0ab20f15b3c1c58ce2899019")  { (result: Result<Forecast, APIError>) in
                switch result {
                case .success(let forecast):
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.forecasts = forecast.daily.map { ForecastViewModel(forecast: $0, system: self.system)}
                    }
                case .failure(let apiError):
                    switch apiError {
                    case .error(let errorString):
                        self.isLoading = false
                        self.appError = AppError(errorString: errorString)
                    }
                }
            }
        }
    }
}
