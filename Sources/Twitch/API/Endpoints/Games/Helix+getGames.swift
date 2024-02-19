import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getGames(
    gameIDs: [String] = [], names: [String] = [], igdbIDs: [String] = []
  ) async throws -> [Game] {
    let idQueryItems = gameIDs.map { URLQueryItem(name: "id", value: $0) }
    let nameQueryItems = names.map { URLQueryItem(name: "name", value: $0) }
    let igdbQueryItems = igdbIDs.map { URLQueryItem(name: "igdb_id", value: $0) }

    let queryItems = idQueryItems + nameQueryItems + igdbQueryItems

    let (rawResponse, result): (_, HelixData<Game>?) = try await self.request(
      .get("games"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct Game: Decodable {
  public let id: String
  public let name: String
  public let boxArtUrl: String
  public let igdbId: String

  public init(id: String, name: String, boxArtUrl: String, igdbId: String) {
    self.id = id
    self.name = name
    self.boxArtUrl = boxArtUrl
    self.igdbId = igdbId
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case boxArtUrl = "box_art_url"
    case igdbId = "igdb_id"
  }
}
