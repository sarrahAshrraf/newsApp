//
//  FavoriteTableViewController.swift
//  NEWSApp
//
//  Created by sarrah ashraf on 03/05/2024.
//

import UIKit
import CoreData
import SDWebImage

class FavoriteTableViewController: UITableViewController {
  
    var favorites = [NewsArticle]()
    var noData :UILabel!
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
        updateBackgroundView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFavorites()
        updateBackgroundView()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let article = favorites[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "detailsVC") as? DeatilsViewController {
            detailsVC.article = article
            detailsVC.title = "News Details"
            navigationController?.pushViewController(detailsVC, animated: true)

            
        }
    }

    func fetchFavorites() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NewsArticle> = NewsArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorited == %@", NSNumber(value: true))
        
        do {
            favorites = try context.fetch(fetchRequest)
            tableView.reloadData()
            updateBackgroundView()
        } catch let error as NSError {
            print("couldnt fetch \(error), \(error.userInfo)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !favorites.isEmpty
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "confirm deletetion", message: "Do you really want to delete this?", preferredStyle: .alert)
                   
                   let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                       self.deleteFavorite(at: indexPath)
                   }
                   
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                       print("Cancel button tapped.")
                   }
                   
                   alertController.addAction(okAction)
                   alertController.addAction(cancelAction)
                   
                   self.present(alertController, animated: true, completion: nil)
           
        }
    }
    func deleteFavorite(at indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newsArticleToDelete = favorites[indexPath.row]
        context.delete(newsArticleToDelete)

        do {
            try context.save()
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        } catch {
            print("couldnt delete the article inn fav table \(error)")
        }
        updateBackgroundView()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)

        if favorites.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = "There are no Favorites yet"
            messageLabel.textColor = .gray
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 16)
            messageLabel.sizeToFit()
            tableView.backgroundView = messageLabel
        } else {
            tableView.backgroundView = nil
            let newsArticle = favorites[indexPath.row]
            cell.textLabel?.text = newsArticle.title

        }


        return cell
    }
    
    private func updateBackgroundView() {
        if favorites.isEmpty {
            let noFavLabel = UILabel()
            noFavLabel.text = "There are no Favorites yet"
            noFavLabel.textColor = .gray
            noFavLabel.numberOfLines = 0
            noFavLabel.textAlignment = .center
            noFavLabel.font = UIFont.systemFont(ofSize: 16)
            noFavLabel.sizeToFit()
            tableView.backgroundView = noFavLabel
        } else {
            tableView.backgroundView = nil
        }
    }

}
