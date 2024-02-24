import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getStreams(
    userIDs: [String]? = nil, userLogins: [String]? = nil, gameIDs: [String]? = nil,
    type: StreamType? = nil, languages: [String]? = nil, limit: Int? = nil,
    before endCursor: String? = nil, after startCursor: String? = nil
  ) async throws -> (streams: [Stream], cursor: String?) {
    let userIDs = userIDs?.compactMap { URLQueryItem(name: "user_id", value: $0) } ?? []
    let userLogins =
      userLogins?.compactMap { URLQueryItem(name: "user_login", value: $0) } ?? []
    let gameIDs = gameIDs?.compactMap { URLQueryItem(name: "game_id", value: $0) } ?? []
    let languages =
      languages?.compactMap { URLQueryItem(name: "language", value: $0) } ?? []

    let type = type.map { URLQueryItem(name: "type", value: $0.rawValue) }
    let limit = limit.map { URLQueryItem(name: "first", value: String($0)) }
    let before = endCursor.map { URLQueryItem(name: "before", value: $0) }
    let after = startCursor.map { URLQueryItem(name: "after", value: $0) }

    var queryItems = userIDs + userLogins + gameIDs + languages
    queryItems.append(contentsOf: [type, limit, before, after].compactMap { $0 })

    let (rawResponse, result): (_, HelixData<Stream>?) = try await self.request(
      .get("streams"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public enum StreamType: String {
  case live
  case all
}

public struct Stream: Decodable, Identifiable {
  public init(id: String, userId: String, userLogin: String, userName: String, gameID: String, gameName: String, type: String, title: String, language: String, tags: [String], isMature: Bool, viewerCount: Int, startedAt: Date, thumbnailURL: String) {
    self.id = id
    self.userId = userId
    self.userLogin = userLogin
    self.userName = userName
    self.gameID = gameID
    self.gameName = gameName
    self.type = type
    self.title = title
    self.language = language
    self.tags = tags
    self.isMature = isMature
    self.viewerCount = viewerCount
    self.startedAt = startedAt
    self.thumbnailURL = thumbnailURL
  }
    
  public let id: String

  public let userId: String
  public let userLogin: String
  public let userName: String

  public let gameID: String
  public let gameName: String

  public let type: String
  public let title: String
  public let language: String
  public let tags: [String]
  public let isMature: Bool

  public let viewerCount: Int
  public let startedAt: Date
  public let thumbnailURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"

    case gameID = "game_id"
    case gameName = "game_name"

    case type
    case title
    case language
    case tags
    case isMature = "is_mature"

    case viewerCount = "viewer_count"
    case startedAt = "started_at"
    case thumbnailURL = "thumbnail_url"
  }
}
