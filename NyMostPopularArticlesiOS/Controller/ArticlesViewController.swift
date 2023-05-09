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
    private var mostArticlesList: [ArticleModel] = []
    
    //Search
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var articlesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refresh()
        articlesTableView.setContentOffset(CGPoint(x: 0, y: -articlesTableView.contentInset.top), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextFieldConfiguration()
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

        self.searchView.backgroundColor = .systemMint
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
    
    private func searchTextFieldConfiguration(){
        self.searchViewHeightConstraint.constant = 0
        self.searchTextField.delegate = self
        self.searchTextField.returnKeyType = .done
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func actionSearch(){
        if self.searchViewHeightConstraint.constant == 0 {
            self.searchViewHeightConstraint.constant = 50
            self.searchTextField.becomeFirstResponder()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }else{
            self.searchViewHeightConstraint.constant = 0
            self.searchTextField.text = ""
            self.searchTextField.resignFirstResponder()
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            self.articlesTableView.reloadData()
        }
    }
    
    
    // MARK : - MOCK Func

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
                        self?.mostArticlesList = results
                        DispatchQueue.main.async {
                            self?.articlesTableView.reloadData()
                            self?.refreshControl.endRefreshing()
                        }
                    case .failure(let message):
                        print(message)
                    }
            
        }
    }
    
    //MARK: - Search Article with title
    func searchArticles(with title: String){
        if title == ""{
            print("Text is empty")
            tableModel = mostArticlesList
        }else{
            print("Text Search = "+title)
            tableModel = title.isEmpty ? tableModel : mostArticlesList.filter{$0.title.lowercased().contains(title.lowercased())}
        }
        articlesTableView.reloadData()
        print(self.tableModel.count)
    }
    
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
        let iconeImage = cellModel.media.first?.getUrlIcon()
        if(iconeImage != "" && iconeImage != nil){
            cell.articleImageView.load(url: URL(string: iconeImage!)!)
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

//MARK: - Search TextField Delegate
extension ArticlesViewController: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField:UITextField){
        guard let searchText = textField.text else { return }
        self.searchArticles(with: searchText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
}
