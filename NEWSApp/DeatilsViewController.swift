//
//  DeatilsViewController.swift
//  NEWSApp
//
//  Created by sarrah ashraf on 03/05/2024.
//

import UIKit
import SDWebImage
import CoreData
class DeatilsViewController: UIViewController {
 
    var news : NewsPOJO? //class to wrap the api fetched data
    var article: NewsArticle? //core data entity
 
    @IBOutlet weak var favBtnImage: UIButton!
    @IBOutlet weak var newsDescription: UITextView!
    @IBOutlet weak var newsDate: UILabel!
    @IBOutlet var newsAuthor: UILabel!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //bind api data to the view
        newsTitle.text = news?.title
        newsDescription.text = news?.desription
        newsAuthor.text = news?.author
        newsDate.text = news?.publishedAt
        //bind db data to the view
        checkFavoriteStateAndUpdateUI()
        updateFavoriteButton()
    }
    
    func setupUI(){
        if let article = article{
            newsTitle.text = article.title
            newsDescription.text = article.desription
            newsAuthor.text = article.author
            newsDate.text = article.publishedAt?.description
            updateImage(imageURL: article.imageUrl)
            isFavorited = article.isFavorited
        }
        else if let new = news {
           
            newsTitle.text = new.title
            newsDescription.text = new.desription
            newsAuthor.text = new.author
            newsDate.text = new.publishedAt
            updateImage(imageURL: new.imageUrl)
            isFavorited = false
            
            
        }
        
    }
    
    func checkFavoriteStateAndUpdateUI(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let new = news {
            let fetchrequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
            fetchrequest.predicate =  NSPredicate(format: "title ==%@", new.title)
            do {
                let result = try context.fetch(fetchrequest)
                if let existingArticle = result.first{
                    article = existingArticle
                    isFavorited = existingArticle.isFavorited
                }
                else {
                    isFavorited = false
                }
            } catch {
                print("error in fetching data form db \(error.localizedDescription)")
                }
            }
       setupUI() // to update the ui
        }
        
    
    
    @IBAction func favBtnAction(_ sender: UIButton) {
        
    }
    
    private var isFavorited = false {
        
        didSet{
            let imageName = isFavorited ? "heart.fill" : "heart"
            favBtnImage.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
    }
    func updateImage(imageURL: String?){
        if let imageUrlString = imageURL, let url = URL(string: imageUrlString) //cast as URL beacuse the imageURl from api is only string
        {
            newsImage.sd_setImage(with: url, placeholderImage: UIImage(named: "loading"))
            
        }
    }

    private func updateFavoriteButton() {
        let imageName = isFavorited ? "heart.fill" : "heart"
        favBtnImage.setImage(UIImage(systemName: imageName), for: .normal)
    }

}
