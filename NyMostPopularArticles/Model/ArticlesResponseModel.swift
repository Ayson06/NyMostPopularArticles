//
//  ArticlesResponseModel.swift
//  NyMostPopularArticles
//
//  Created by Sonia AYADI on 29/04/2023.
//

import Foundation

public struct ArticlesResponseModel: Decodable {
    public let status: String?
    public let copyright: String?
    public let numResults: Int?
    public let results: [ArticleModel]
    
    public let code: String?
    public let message: String?
    
}
