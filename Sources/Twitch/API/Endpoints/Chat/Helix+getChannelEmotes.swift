import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChannelEmotes(broadcasterId: String) async throws -> (
    templateUrl: String, emotes: [ChannelEmote]
  ) {
    let queryItems = self.makeQueryItems(("broadcaster_id", broadcasterId))

    let (rawResponse, result): (_, HelixData<ChannelEmote>?) = try await self.request(
      .get("chat/emotes"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }
    guard let template = result.template else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return (template, result.data)
  }
}

public struct ChannelEmote: Decodable {
  let id: String
  let name: String
  let tier: String?
  let type: String
  let setId: String
  let format: [Emote.Format]
  let scale: [Emote.Scale]
  let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case tier = "tier"
    case type = "emote_type"
    case setId = "emote_set_id"
    case format = "format"
    case scale = "scale"
    case themeMode = "theme_mode"
  }

  func getURL(
    from templateUrl: String, format: Emote.Format = .png, scale: Emote.Scale = .large,
    themeMode: Emote.ThemeMode = .dark
  ) -> URL? {
    return URL(
      string: templateUrl.replacingOccurrences(of: "{{id}}", with: self.id)
        .replacingOccurrences(of: "{{scale}}", with: scale.rawValue).replacingOccurrences(
          of: "{{format}}", with: format.rawValue
        ).replacingOccurrences(of: "{{theme_mode}}", with: themeMode.rawValue))
  }
}

public enum Emote {
  enum Format: String, Decodable {
    case gif = "animated"
    case png = "static"
  }

  enum Scale: String, Decodable {
    case small = "1.0"
    case medium = "2.0"
    case large = "3.0"
  }

  enum ThemeMode: String, Decodable { case light, dark }
}
