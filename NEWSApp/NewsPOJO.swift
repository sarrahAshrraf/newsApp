//
//  NewsPOJO.swift
//  NEWSApp
//
//  Created by sarrah ashraf on 03/05/2024.
//

import Foundation

class NewsPOJO: Codable {
    var author: String?
    var title: String
    var desription: String?
    var imageUrl: String?
    var url: String
    var publishedAt: String
    
    enum ContentType: String, CodingKey {
        case author = "author"
        case title = "title"
        case desription = "desription"
        case imageUrl = "imageUrl"
        case url = "url"
        case publishedAt = "publishedAt"
        
    }
    
}

func fetchData(handler: @escaping ([NewsPOJO]) -> Void) {
    guard let url = URL(string: "https://raw.githubusercontent.com/DevTides/NewsApi/master/news.json") else { return }
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else { return }
        do {
            let decoder = JSONDecoder()
            let newsResponse = try decoder.decode([NewsPOJO].self, from: data)
            handler(newsResponse)
        } catch {
            print("Error : \(error)")
            handler([])
        }
    }.resume()
}
