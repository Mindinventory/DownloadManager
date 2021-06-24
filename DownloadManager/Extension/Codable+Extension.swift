//
//  Codable+Extension.swift
//  TwilloChatDemo
//
//  Created by macbook pro on 04/05/20.
//  Copyright © 2020 macbook pro. All rights reserved.
//

import Foundation



extension Decodable {
    static func decode<A: Codable>(_ data: Data) -> Result<A> {
            
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(A.self, from: data)
            return .success(result)
        } catch  {
            print(error.localizedDescription)
            return .failure(.unExpectedValue)
        }
    
    }

    static func decoded(from data: Data) -> Self? {
        do {
            let result = try JSONDecoder().decode(Self.self, from: data)
            return result
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

 extension Encodable {
    var jsonEncoded: JSONType? {
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: encodedData, options: JSONSerialization.ReadingOptions.mutableContainers)
            return (jsonObject as? JSONType)
        } catch {
            print("Error while encoding \(self): \(error)")
            return nil
        }
    }

    var encodedData: Data? {
        do {
            let encodedData = try JSONEncoder().encode(self)
            return encodedData
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
