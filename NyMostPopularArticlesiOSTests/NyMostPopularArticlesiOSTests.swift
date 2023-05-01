//
//  NyMostPopularArticlesiOSTests.swift
//  NyMostPopularArticlesiOSTests
//
//  Created by Sonia AYADI on 29/04/2023.
//

import XCTest
import UIKit
import NyMostPopularArticles

final class ArticleViewController: UITableViewController{
    private var loader: ArticleFeedLoader?
    
    convenience init(loader: ArticleFeedLoader){
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        loader?.load() { _ in}
    }
}
class NyMostPopularArticlesiOSTests: XCTestCase {
    
    func test_viewDidLoad_loadsFeed(){
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount,0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed(){
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.allTargets.forEach { target in
            sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ArticleViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ArticleViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: ArticleFeedLoader {
        
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (LoadArticleFeedResult) -> Void) {
            loadCallCount += 1
        }

    }

}
