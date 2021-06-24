//
//  AppError.swift
//  CoreDataExample
//
//  Created by Hardik Modha on 28/12/19.
//  Copyright © 2019 Brijesh. All rights reserved.
//

import UIKit

enum AppError: Error {
    case noData
    case custom(title: String? = nil, message: String?, image: UIImage? = nil)
    case unExpectedValue
    case timeOut
    case noInternet
    case requestCancelled
    case sessionExpired401
    case internalServerError
    case error400
    case completed
    case notCompleted
}

extension AppError {
    
    var title: String {
        switch self {
        case .noData:
            return "No Records available"
        case .custom(_, let message,  _):
            return message!
        case .noInternet:
            return "No Internet"
        case .requestCancelled:
            return "Request has been cancelled."
        case .timeOut:
            return "Request Time Out."
        case .sessionExpired401:
            return "Seesion Expired!"
        case .unExpectedValue:
            return "Unextected Value come form the api"
        case .internalServerError:
            return  "Internal server error"
        case .error400:
            return "Torken not found"
        case .completed:
            return "Completed"
        case .notCompleted:
            return "Not Completed"
        }
    }
}
