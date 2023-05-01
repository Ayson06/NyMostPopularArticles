//
//  NyMostPopularArticlesTests.swift
//  NyMostPopularArticlesTests
//
//  Created by Sonia AYADI on 29/04/2023.
//

import XCTest
@testable import NyMostPopularArticles

class NyMostPopularArticlesTests: XCTestCase {
    
    public func generateNyTimesURL() -> URL {
            return URL(string: "http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?api-key=RRJAll2KGW5VYAGqJ5ON08BcguUazXQh")!
    }
    

    func test_init_doesNotRequestDataFromURL(){
        let(_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = generateNyTimesURL()
        let (sut, client) = makeSUT(url:url)
        sut.load{ _ in}
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURL(){
        let url = generateNyTimesURL()
        let (sut, client) = makeSUT(url:url)
        sut.load{ _ in}
        sut.load{ _ in}

        XCTAssertEqual(client.requestedURLs,[url, url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let(sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse(){
        let(sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach{ index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code,data:json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJSON(){
        let(sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList(){
        let(sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONList(){
        let(sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: generateNyTimesURL())

        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: generateNyTimesURL())
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    //MARK: -Helpers
    private func makeSUT(url: URL = generateNyTimesURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteArticleFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteArticleFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteArticleFeedLoader.Error) -> RemoteArticleFeedLoader.Result {
        return .failure(error)
    }
    
    func test_load_doesNotDeliverResultAfterSutInstanceHasBeenDeallocated(){
        let url = generateNyTimesURL()
        let client = HTTPClientSpy()
        var sut: RemoteArticleFeedLoader? = RemoteArticleFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteArticleFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func makeItem(title: String, byline: String, published_date:String, abstract: String, media: [Media]) -> (model: ArticleModel, json: [String: Any] ){
        let item = ArticleModel(title: title, byline: byline, published_date:published_date, abstract: abstract, media: media)
        let json = [
            "title" : title,
            "byline" : byline,
            "published_date" : published_date,
            "abstract" : abstract,
            "media" : [
                "media-metadata" : media.first?.mediaMetadata,
            ]
        ].reduce(into: [String: Any]()){(acc, e) in if let value = e.value { acc[e.key] = value }
            
        }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func getArticleModel() -> [ArticleModel] {
        let previewDataURL = Bundle.main.path(forResource: "articles", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: previewDataURL))
        /* Convert to a string and print
        if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
           print(JSONString)
        }*/
        do {
            let jsonData = try JSONDecoder().decode(ArticlesResponseModel.self, from: data)
            return jsonData.results ?? []
        } catch {
                    print("error:\(error)")
                }
        return []
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL]{
            return messages.map { $0.url }
        }

        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
            messages.append((url, completion))
        }
        
        func complete(with error:Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0){
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                    statusCode: code,
                    httpVersion: nil,
                    headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
