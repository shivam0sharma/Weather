//
//  CLLocation+Extension.swift
//  Weather
//
//  Created by Shivam Sharma on 9/17/23.
//

import Foundation
import CoreLocation

extension CLLocation {
    func fetchCity(completion: @escaping (_ city: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $1) }
    }
}
