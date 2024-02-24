import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func searchChannels(
    for searchQuery: String, liveOnly: Bool? = nil, limit: Int? = nil,
    after cursor: String? = nil
  ) async throws -> (channels: [Channel], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("query", searchQuery), ("live_only", liveOnly.map(String.init)), ("after", cursor),
      ("first", limit.map(String.init)))

    let (rawResponse, result): (_, HelixData<Channel>?) = try await self.request(
      .get("search/channels"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public struct Channel: Decodable, Identifiable {
  public let id: String
  public let login: String
  public let name: String
  public let language: String

  public let gameID: String
  public let gameName: String

  public let isLive: Bool
  public let tags: [String]

  public let profilePictureURL: String
  public let title: String
  @NilOnTypeMismatch var startedAt: Date?

  public init(id: String, login: String, name: String, language: String, gameID: String, gameName: String, isLive: Bool, tags: [String], profilePictureURL: String, title: String, startedAt: Date? = nil) {
    self.id = id
    self.login = login
    self.name = name
    self.language = language
    self.gameID = gameID
    self.gameName = gameName
    self.isLive = isLive
    self.tags = tags
    self.profilePictureURL = profilePictureURL
    self.title = title
    self.startedAt = startedAt
  }

  enum CodingKeys: String, CodingKey {
    case id
    case login = "broadcaster_login"
    case name = "display_name"
    case language = "broadcaster_language"

    case gameID = "game_id"
    case gameName = "game_name"

    case isLive = "is_live"
    case tags

    case profilePictureURL = "thumbnail_url"
    case title
    case startedAt = "started_at"
  }
}

@propertyWrapper struct NilOnTypeMismatch<Value> { var wrappedValue: Value? }

extension NilOnTypeMismatch: Decodable where Value: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.wrappedValue = try? container.decode(Value.self)
  }
}
