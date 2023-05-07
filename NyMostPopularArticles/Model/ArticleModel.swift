//
//  ArticleModel.swift
//  NyMostPopularArticles
//
//  Created by Sonia AYADI on 29/04/2023.
//

import Foundation

public struct ArticleModel {
    
    public let title: String
    public let byline: String
    public let published_date: String
    public let abstract: String
    public let media: [Media]
    
    public init(title: String, byline: String, published_date:String, abstract: String, media: [Media]) {
        self.title = title
        self.byline = byline
        self.published_date = published_date
        self.abstract = abstract
        self.media = media
    }
    
}
extension ArticleModel: Codable {
}
extension ArticleModel: Equatable {}

public struct Media {
    public let mediaMetadata : [MediaMetadata]

    enum CodingKeys: String, CodingKey {
        case mediaMetadata = "media-metadata"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mediaMetadata = try values.decode([MediaMetadata].self, forKey: .mediaMetadata)
        
    }
    public func getUrlIcon() -> String{
        return (mediaMetadata.first?.url)!
    }
}

extension Media: Codable {}
extension Media: Equatable {}

public struct MediaMetadata {
    public let url: String?
    public let format: String?
    
}

extension MediaMetadata: Codable {}
extension MediaMetadata: Equatable {}
