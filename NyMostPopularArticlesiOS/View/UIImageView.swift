//
//  UIImageView.swift
//  NyMostPopularArticlesiOS
//
//  Created by Sonia AYADI on 30/04/2023.
//

import SwiftUI

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
