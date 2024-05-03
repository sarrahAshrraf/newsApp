//
//  NewsController.swift
//  NEWSApp
//
//  Created by sarrah ashraf on 29/04/2024.
//

import UIKit
import SDWebImage
import Reachability
import CoreData

class NewsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
   
    var newsFromAPI = [NewsPOJO]()
    var newsFromDB = [NewsArticle]()
    var usingDB = false
    var activityIndicator: UIActivityIndicatorView!
    let reachability = try! Reachability()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupReachbility()
        fetchFromDB()

    }
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //put flag usingDB to detect the correct count
        return usingDB ? newsFromDB.count : newsFromAPI.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as? NewsCell)!
    
        if usingDB {
            let article = newsFromDB[indexPath.row]
            if let imageUrlString = article.imageUrl, let imageUrl = URL(string: imageUrlString) {
                cell.newImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "loading"))
            }
            cell.newAuthor.text = article.author
        } else {
            let article = newsFromAPI[indexPath.row]
            if let imageUrlString = article.imageUrl, let imageUrl = URL(string: imageUrlString) {
                cell.newImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "loading"))
            }
            cell.newAuthor.text = article.author
        }
    
        
        return cell
    }

   
    func setupReachbility(){
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do { try reachability.startNotifier()}
        catch {
            print("error in start notifier\(error.localizedDescription)")
        }
    }
    
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection != .unavailable //both wifi and cellular
        { //fetch data from api => network is on
            fetchData { [weak self] fetchedNews in
                self?.newsFromAPI = fetchedNews
                self?.usingDB = false
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.reloadData()
                    self?.deleteFromDB(fetchedNews)
                    self?.saveToDB(fetchedNews)
                }
            }
            
        } else {
            //fetch the data from db => network is off
            fetchFromDB()
            
        }
        
        
    }
    
    func saveToDB(_ articles: [NewsPOJO]){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 
        for article in articles {
            let savedArtcile = NewsArticle(context: context)
            savedArtcile.title = article.title
            savedArtcile.author = article.author
            savedArtcile.desription = article.desription
            savedArtcile.imageUrl = article.imageUrl
            savedArtcile.publishedAt = article.publishedAt
            savedArtcile.isFavorited = false //beacuse we are saving all the data from api, not the favorite data
        }
        
        do{ try context.save()}
        catch{print("error in saving data \(error.localizedDescription)")}
    }
    
    func deleteFromDB(_ articles: [NewsPOJO]){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        
        var deletedObj = [NewsArticle]()
        
        articles.forEach { article in
            fetchRequest.predicate = NSPredicate(format: "title ==%@ AND isFavorited == NO", article.title)
            do{
                let result = try context.fetch(fetchRequest)
                deletedObj.append(contentsOf: result)
            } catch {
                print("error in deletion \(error)")
                           }
        }
        for newObject in deletedObj{
            context.delete(newObject)
        }
        do{try context.save()}
        catch{print("error in saving\(error.localizedDescription)")}
        
    }
    
    func fetchFromDB(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        do{
            let articles = try context.fetch(fetchRequest)
            self.newsFromDB = articles
            self.usingDB = true
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
        catch {
            print("error in fetching from db \(error.localizedDescription)")
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2.5, height: view.frame.height / 4)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "detailsVC") as? DeatilsViewController {
            if usingDB {
                let article = newsFromDB[indexPath.item]
                detailsVC.article = article
            } else {
                let article = newsFromAPI[indexPath.item]
                detailsVC.news = article
            }
            detailsVC.title = "News Details"
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
