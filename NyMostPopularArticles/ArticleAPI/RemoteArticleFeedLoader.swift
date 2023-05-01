//
//  RemoteArticleFeedLoader.swift
//  NyMostPopularArticles
//
//  Created by Sonia AYADI on 30/04/2023.
//

import Foundation

public final class RemoteArticleFeedLoader : ArticleFeedLoader {
    private var url: URL
    private var client: HTTPClient
    
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadArticleFeedResult
    
    public init() {
        self.url = URL(string: "http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?api-key=RRJAll2KGW5VYAGqJ5ON08BcguUazXQh")!
        self.client = URLSessionHTTPClient()
    }
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {        
        client.get(from: url) { [weak self] result in
            guard self != nil else {return}
            switch result{
            case let .success(data, response):
                completion(ArticleFeedMapper.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

