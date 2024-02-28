import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getVideosById(_ id: String) async throws -> [Video] {
    let id = URLQueryItem(name: "id", value: id)

    let (videos, _) = try await self.getVideosWithQueryItems([id])
    return videos
  }

  public func getVideosByUserId(_ userId: String, period: VideoPeriod? = nil, sort: VideoSort? = nil, type: VideoTypeFilter? = nil, limit: Int? = nil, before endCursor: String? = nil, after startCursor: String? = nil) async throws -> (videos: [Video], cursor: String?) {
    let userId = [URLQueryItem(name: "user_id", value: userId)]
    let period = period.map { URLQueryItem(name: "period", value: $0.rawValue) }
    let sort = sort.map { URLQueryItem(name: "sort", value: $0.rawValue) }
    let type = type.map { URLQueryItem(name: "type", value: $0.rawValue) }
    let limit = limit.map { URLQueryItem(name: "limit", value: String($0)) }
    let before = endCursor.map { URLQueryItem(name: "before", value: $0) }
    let after = startCursor.map { URLQueryItem(name: "after", value: $0) }

    var queryItems = userId
    queryItems.append(contentsOf: [period, sort, type, limit, before, after].compactMap { $0 })

    return try await self.getVideosWithQueryItems(queryItems)
  }

  public func getVideosByGameId(_ gameId: String, language: String? = nil, period: VideoPeriod? = nil, sort: VideoSort? = nil, type: VideoTypeFilter? = nil, limit: Int? = nil) async throws -> [Video] {
    let gameId = [URLQueryItem(name: "game_id", value: gameId)]
    let language = language.map { URLQueryItem(name: "language", value: $0) }
    let period = period.map { URLQueryItem(name: "period", value: $0.rawValue) }
    let sort = sort.map { URLQueryItem(name: "sort", value: $0.rawValue) }
    let type = type.map { URLQueryItem(name: "type", value: $0.rawValue) }
    let limit = limit.map { URLQueryItem(name: "limit", value: String($0)) }

    var queryItems = gameId
    queryItems.append(contentsOf: [language, period, sort, type, limit].compactMap { $0 })

    let (videos, _) = try await self.getVideosWithQueryItems(queryItems)
    return videos  }

  private func getVideosWithQueryItems(_ queryItems: [URLQueryItem]) async throws -> (videos: [Video], cursor: String?) {
    let (rawResponse, result): (_, HelixData<Video>?) = try await self.request(
      .get("videos"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public enum VideoPeriod: String {
  case all
  case day
  case month
  case week
}

public enum VideoSort: String {
  case time
  case trending
  case views
}

public enum VideoTypeFilter: String {
  case all
  case archive
  case highlight
  case upload
}

public enum VideoType: String, Encodable, Decodable {
  case archive
  case highlight
  case upload
}

public struct VideoMutedSegment: Encodable, Decodable {
  public let duration: Int
  public let offset: Int
}

public struct Video: Encodable, Decodable, Identifiable {
  public let id: String

  public let streamId: String?

  public let userId: String
  public let userLogin: String
  public let userName: String

  public let title: String
  public let description: String

  public let createdAt: Date
  public let publishedAt: Date

  public let url: String
  public let thumbnailUrl: String

  public let viewCount: Int

  public let language: String
  public let type: VideoType

  public let duration: String
  public let mutedSegments: [VideoMutedSegment]

  enum CodingKeys: String, CodingKey {
    case id

    case streamId = "stream_id"

    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"

    case title
    case description

    case createdAt = "created_at"
    case publishedAt = "published_at"

    case url
    case thumbnailUrl = "thumbnail_url"

    case viewCount = "view_count"

    case language
    case type

    case duration
    case mutedSegments = "muted_segments"
  }
}
