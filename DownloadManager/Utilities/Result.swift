//
//  Result.swift
//  ChatApp
//
//  Created by Hardik Modha on 12/01/20.
//  Copyright © 2020 Hardik Modha. All rights reserved.
//

import Foundation

enum request {
    case fetching
    case refresh
    case loadMore
}

enum response<A> {
    case success(value: Result<A>)
    case error(error: Error)
}

enum Result<A> {
    case success(A)
    case failure(AppError)
    
    var value: A? {
        switch self {
        case .success(let data):
            return data
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
