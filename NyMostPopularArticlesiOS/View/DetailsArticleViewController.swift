//
//  DetailsArticleViewController.swift
//  NyMostPopularArticlesiOS
//
//  Created by Sonia AYADI on 30/04/2023.
//

import UIKit
import NyMostPopularArticles

class DetailsArticleViewController: UIViewController {

    @IBOutlet weak var articleDetails: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    var articleModel: ArticleViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleImageView.load(url: URL(string: articleModel.urlImageArticle)!)
        
        articleTitle.text = self.articleModel.title
        
        articleDetails.text = self.articleModel.abstract
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}