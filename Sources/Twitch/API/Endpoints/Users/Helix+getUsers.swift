import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getUsers(userIDs: [String] = [], userLogins: [String] = []) async throws
    -> [User]
  {
    let idQueryItems = userIDs.map { URLQueryItem(name: "id", value: $0) }
    let loginQueryItems = userLogins.map { URLQueryItem(name: "login", value: $0) }

    let queryItems = idQueryItems + loginQueryItems

    let (rawResponse, result): (_, HelixData<User>?) = try await self.request(
      .get("users"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct User: Decodable {
  public let id: String
  public let login: String
  public let displayName: String

  public let type: String
  public let broadcasterType: BroadcasterType

  public let description: String
  public let profileImageUrl: String
  public let offlineImageUrl: String
  public let createdAt: Date

  public let email: String?

  public enum BroadcasterType: String, Decodable {
    case partner
    case affiliate
    case none = ""
  }

  enum CodingKeys: String, CodingKey {
    case id
    case login
    case displayName = "display_name"

    case type
    case broadcasterType = "broadcaster_type"

    case description
    case profileImageUrl = "profile_image_url"
    case offlineImageUrl = "offline_image_url"
    case createdAt = "created_at"

    case email
  }
}
