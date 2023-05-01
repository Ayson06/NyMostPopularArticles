//
//  ArticleFeedMapper.swift
//  NyMostPopularArticles
//
//  Created by Sonia AYADI on 30/04/2023.
//

import Foundation

internal final class ArticleFeedMapper {
    private static var OK_200: Int { return 200}
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteArticleFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(ArticlesResponseModel.self, from: data) else {
            return .failure(RemoteArticleFeedLoader.Error.invalidData)
        }
        
        return .success(root.results)
    }
}
