//
//  HTTPClient.swift
//  NyMostPopularArticles
//
//  Created by Sonia AYADI on 30/04/2023.
//

import Foundation

public protocol HTTPClient {
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}


public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
