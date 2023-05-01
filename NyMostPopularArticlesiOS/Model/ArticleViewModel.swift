//
//  ArticleViewModel.swift
//  NyMostPopularArticlesiOS
//
//  Created by Sonia AYADI on 01/05/2023.
//

import Foundation

struct ArticleViewModel {
    
    let title: String
    let byline: String
    let published_date: String
    let abstract: String
    let iconeUrlImageArticle: String
    let urlImageArticle: String
    
    init(title: String, byline: String, published_date: String, abstract: String, iconeUrlImageArticle: String, urlImageArticle: String){
        self.title = title
        self.byline = byline
        self.published_date = published_date
        self.abstract = abstract
        self.iconeUrlImageArticle = iconeUrlImageArticle
        self.urlImageArticle = urlImageArticle
    }
    
}
