//
//  ArticleFeedLoader .swift
//  NyMostPopularArticles
//
//  Created by Sonia AYADI on 30/04/2023.
//

import Foundation

public enum LoadArticleFeedResult{
    case success([ArticleModel])
    case failure (Error)
}

public protocol ArticleFeedLoader {
    func load(completion: @escaping (LoadArticleFeedResult) -> Void)
}

