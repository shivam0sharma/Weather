//
//  UIApplication+Extension.swift
//  Weather
//
//  Created by Shivam Sharma on 9/16/23.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
