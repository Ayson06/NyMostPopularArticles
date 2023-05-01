//
//  RemoteArticleLoaderTests.swift
//  NyMostPopularArticlesTests
//
//  Created by Sonia AYADI on 30/04/2023.
//

import XCTest
import NyMostPopularArticles

class RemoteArticleLoaderTests: XCTestCase {
    
    public func generateNyTimesURL() -> URL {
            return URL(string: "http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/7.json?api-key=RRJAll2KGW5VYAGqJ5ON08BcguUazXQh")!
    }
    
    func test_init_doesNotRequestDataFromURL(){
        let(_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url:url)
        sut.load{ _ in}
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURL(){
        let url = URL(string: "https://a-given-url.com")!
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
    
    /*func test_load_deliversItemsOn200HTTPResponseWithJSONList(){
        let(sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url.com")!)

        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }*/
    
    //MARK: -Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteArticleFeedLoader, client: HTTPClientSpy) {
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
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteArticleFeedLoader? = RemoteArticleFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteArticleFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteArticleFeedLoader, toCompleteWith expectedResult: RemoteArticleFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteArticleFeedLoader.Error), .failure(expectedError as RemoteArticleFeedLoader.Error)):
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
