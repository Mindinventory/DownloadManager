// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - WelcomeElement
class Track: Codable {
    var index: Int = 0
    let trackCensoredName: String
    let collectionViewURL: String
    let currency: Currency
    let wrapperType: WrapperType
    let artworkUrl60: String
    let collectionName: String
    let isStreamable: Bool
    let releaseDate: String
    let artworkUrl100: String
    let trackExplicitness: Explicitness
    let trackCount, discNumber, trackNumber, trackID: Int
    let trackPrice: Double
    let artistID: Int
    let collectionExplicitness: Explicitness
    let trackName: String
    let artistName: ArtistName
    let trackTimeMillis: Int
    let artistViewURL: String
    let primaryGenreName: PrimaryGenreName
    let kind: Kind
    let country: Country
    let collectionID: Int
    let previewURL: String
    let artworkUrl30: String
    let trackViewURL: String
    let discCount: Int
    let collectionCensoredName: String
    let collectionPrice: Double
    let contentAdvisoryRating, collectionArtistName: String?
    let collectionArtistID: Int?
    var isDownloaded: Bool = false

    enum CodingKeys: String, CodingKey {
        case trackCensoredName
        case collectionViewURL = "collectionViewUrl"
        case currency, wrapperType, artworkUrl60, collectionName, isStreamable, releaseDate, artworkUrl100, trackExplicitness, trackCount, discNumber, trackNumber
        case trackID = "trackId"
        case trackPrice
        case artistID = "artistId"
        case collectionExplicitness, trackName, artistName, trackTimeMillis
        case artistViewURL = "artistViewUrl"
        case primaryGenreName, kind, country
        case collectionID = "collectionId"
        case previewURL = "previewUrl"
        case artworkUrl30
        case trackViewURL = "trackViewUrl"
        case discCount, collectionCensoredName, collectionPrice, contentAdvisoryRating, collectionArtistName
        case collectionArtistID = "collectionArtistId"
    }
}

extension Track {

}

enum ArtistName: String, Codable {
    case oneDirection = "One Direction"
    case zayn = "ZAYN"
    case zaynTaylorSwift = "ZAYN & Taylor Swift"
}

enum Explicitness: String, Codable {
    case explicit = "explicit"
    case notExplicit = "notExplicit"
}

enum Country: String, Codable {
    case usa = "USA"
}

enum Currency: String, Codable {
    case usd = "USD"
}

enum Kind: String, Codable {
    case song = "song"
}

enum PrimaryGenreName: String, Codable {
    case pop = "Pop"
    case soundtrack = "Soundtrack"
}

enum WrapperType: String, Codable {
    case track = "track"
}


