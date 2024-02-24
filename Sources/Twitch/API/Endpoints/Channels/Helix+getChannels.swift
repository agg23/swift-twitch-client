import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChannels(userIDs: [String]) async throws -> [Broadcaster] {
    let queryItems = userIDs.map { URLQueryItem(name: "broadcaster_id", value: $0) }

    let (rawResponse, result): (_, HelixData<Broadcaster>?) = try await self.request(
      .get("channels"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct Broadcaster: Decodable, Identifiable {
  public init(id: String, login: String, name: String, language: String, gameID: String, gameName: String, title: String, delay: Int, tags: [String]) {
    self.id = id
    self.login = login
    self.name = name
    self.language = language
    self.gameID = gameID
    self.gameName = gameName
    self.title = title
    self.delay = delay
    self.tags = tags
  }
    
  public let id: String
  public let login: String
  public let name: String
  public let language: String
  public let gameID: String
  public let gameName: String
  public let title: String
  public let delay: Int
  public let tags: [String]

  enum CodingKeys: String, CodingKey {
    case id = "broadcaster_id"
    case login = "broadcaster_login"
    case name = "broadcaster_name"
    case language = "broadcaster_language"
    case gameID = "game_id"
    case gameName = "game_name"
    case title
    case delay
    case tags
  }
}
