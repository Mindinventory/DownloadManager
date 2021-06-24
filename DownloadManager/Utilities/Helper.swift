//
//  Helper.swift
//  WebCluesPracticle
//
//  Created by Hardik Modha on 21/07/20.
//  Copyright © 2020 Hardik Modha. All rights reserved.
//

import Foundation

enum FileExtensionType: String, CustomStringConvertible {
    case swift
    case json
    case xml

    var description: String {
        return self.rawValue
    }

}

typealias JSONType = [String: Any]
typealias Header = [String: String]
typealias ResultHandler<A> = (Result<A>) -> Void
typealias EmptyHandler = () -> Void
typealias Progress = (Double) -> Void
typealias ConfirmationHandler = (Bool) -> Void
typealias ResponseStatusHandler = (Bool, String) -> Void


struct JSONHelper {

    static func readJSON() -> [Track]? {
        do {
            if let fileURL = Bundle.main.url(forResource: "music-datasource", withExtension: "json") {
                let data = try Data(contentsOf: fileURL)
                let response = try JSONDecoder().decode([Track].self, from: data)
                return response
            }
        } catch let error  {
            print(error.localizedDescription)
            return nil
        }
        return nil
    }
}
