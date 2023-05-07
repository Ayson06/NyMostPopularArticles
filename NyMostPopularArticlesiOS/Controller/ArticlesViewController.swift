//
//  ViewController.swift
//  NyMostPopularArticlesiOS
//
//  Created by Sonia AYADI on 29/04/2023.
//

import UIKit
import SwiftUI
import NyMostPopularArticles


class ArticlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let loader = RemoteArticleFeedLoader()
    var tableModel = [ArticleModel]()
    let articleCellId = "articleCell"
    let articleDetailsId = "articleDetailsView"
    var selectedArticle: ArticleModel!
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var articlesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refresh()
        articlesTableView.setContentOffset(CGPoint(x: 0, y: -articlesTableView.contentInset.top), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurationNavigationBar()
        self.articlesTableView.delegate = self
        self.articlesTableView.dataSource = self
        self.articlesTableView.allowsSelection = true
        
        self.refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        self.articlesTableView.addSubview(refreshControl)
        
        load()
    }
    
    func configurationNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemMint//UIColor(red: 46.0/255.0, green: 14.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let action = [UIMenuElement]()
        let menuRight = UIMenu(title: "",  children: action)
        let menuLeft = UIMenu(title: "",  children: action)
        
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.actionSearch))
        let dots = UIBarButtonItem(title: "", image: UIImage(named: "bar_dots"), menu: menuRight)
        
        let menu = UIBarButtonItem(title: "", image: UIImage(named: "bar_menu"), menu: menuLeft)
        navigationItem.rightBarButtonItems = [dots, search]
        navigationItem.setLeftBarButton(menu, animated: true)
        
    }
    
    // MARK : - MOCK Func
    @objc func actionSearch(){
        print("Search a specific Article")
    }
    
    @objc func addTapped(){
        print("Dots selected")
    }
    
    // MARK : - Load Results from ArticleLoader
    
    @objc private func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            print(result)
            switch result {
                    case .success(let results):
                        self?.tableModel = results
                        DispatchQueue.main.async {
                            self?.articlesTableView.reloadData()
                            self?.refreshControl.endRefreshing()
                        }
                    case .failure(let message):
                        print(message)
                    }
            
        }
    }
    
    /*func setResults(results : [ArticleModel]) -> Void {
        for result in results {
            let model = ArticleViewModel(title: result.title, byline: result.byline, published_date: result.published_date, abstract: result.abstract, iconeUrlImageArticle: result.media.first?.mediaMetadata.first?.url! ?? "", urlImageArticle: result.media.first?.mediaMetadata.first?.url! ?? "")
            self.tableModel.append(model)
        }
    }*/
    
    // MARK : - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(getArticleModel().count)
        return tableModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellModel = tableModel[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleTableViewCell

        print(cellModel.title)
        cell.articleTitle.text = cellModel.title
        cell.bylineArticle.text = cellModel.byline
        cell.publishedDateArticle.text = cellModel.published_date
        let iconeImage = cellModel.media.first?.mediaMetadata.first?.url ?? ""
        if(iconeImage != ""){
            cell.articleImageView.load(url: URL(string: iconeImage)!)
        }
        


        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedArticle = tableModel[indexPath.row]
        //print("selectedArticle = \(tableModel[indexPath.row])")
        performSegue(withIdentifier: articleDetailsId, sender: nil)
        self.articlesTableView.deselectRow(at: indexPath, animated: true)
   }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == articleDetailsId {
            let detailsVC = segue.destination as! DetailsArticleViewController
            detailsVC.articleModel = selectedArticle
        }
    }
}

