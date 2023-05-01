//
//  ArticleTableViewCell.swift
//  NyMostPopularArticlesiOS
//
//  Created by Sonia AYADI on 29/04/2023.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var bylineArticle: UILabel!
    @IBOutlet weak var publishedDateArticle: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
