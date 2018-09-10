//
//  ViewController.swift
//  WikipediaSearch
//
//  Created by Lova Rama Krishna P on 08/09/18.
//  Copyright © 2018 Lova Rama Krishna P. All rights reserved.
//

import UIKit
import CoreData


class WikipediaTableSearchController: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    var articleArray = [Article]()
    var currentArticleArray = [Article]() //update table
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(WikipediaTableSearchController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    
    @IBOutlet weak var wikiTableView: UITableView!
    @IBOutlet weak var wikiSearchBar: UISearchBar!
    
    let queryService = QueryService()
    var coreDataStack = CoreDataStack()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        // Whitespace string
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style: .plain, target: nil, action: nil)
        setUpArticles()
        setUpSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc func statusManager(_ notification: NSNotification) {
        let Alert = alert()
         if Network.reachability?.isConnectedToNetwork == true {
        Alert.msg(message: "You can search online results now", title: "Internet Connection Enable")
         }else{
        Alert.msg(message: "Please pull to refresh for getting recent search results", title: "No Internet!")
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
          if Network.reachability?.isConnectedToNetwork == true {
            //Do what you need, for example send JSON request on server
             self.title = "Wikipedia Search"
            self.seatchForArticals(wikiSearchBar.text!)
            self.wikiTableView.reloadData()
        }else{
            setUpArticles()
            self.wikiTableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    
    private func setUpArticles(){
       if Network.reachability?.isConnectedToNetwork == true {
            //Do what you need, for example send JSON request on server
         self.title = "Wikipedia Search"
            currentArticleArray = articleArray
            self.wikiTableView.addSubview(self.refreshControl)
        }else{
            //Load from local
            self.title = "Recent Search Results"

            let moc = coreDataStack.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artical")
            request.returnsObjectsAsFaults = false
            do {
                let result = try moc.fetch(request)
                currentArticleArray = []
                for data in result as! [NSManagedObject] {
                    currentArticleArray.append(Article.init(name: data.value(forKey: "name") as! String, image:data.value(forKey: "image") as! String, description: data.value(forKey: "descriptionText") as! String, articalContent: data.value(forKey: "articalContent") as! String))
                }
            } catch {
                print("Failed")
            }
        }
    }
    
    private func setUpSearchBar() {
        wikiSearchBar.delegate = self
        wikiSearchBar.placeholder = "Search here..."
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentArticleArray.count == 0 {
            tableView.showEmptyListMessage("You don't have any search results yet.\nYou can search for results from search bar.")
            return 0
        }else{
            tableView.showEmptyListMessage("")
            return currentArticleArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCellTableViewCell else {
            return UITableViewCell()
        }
        if !currentArticleArray.isEmpty {
        let artical = currentArticleArray[indexPath.row]
        cell.configureTableViewCell(article: artical)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //       // guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCellTableViewCell else {
        //            return
        //        }
        let artical = currentArticleArray[indexPath.row]
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        // detailVC.imageToSave = cell.imgView.image
        detailVC.preasentArtical = Article(name: artical.name, image: artical.image, description: artical.description, articalContent: "")
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.50)
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }
        print(query)
        //searchBar.resignFirstResponder()
        if Network.reachability?.isConnectedToNetwork == true {
            //Do what you need, for example send JSON request on server
            self.title = "Wikipedia Search"
            self.seatchForArticals(searchBar.text!)
            self.wikiTableView.reloadData()
        }else{
            let Alert = alert()
            Alert.msg(message: "Please getting recent search results", title: "No Internet!")
            setUpArticles()
            self.wikiTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        if Network.reachability?.isConnectedToNetwork == true {
//            //Do what you need, for example send JSON request on server
//            self.title = "Wikipedia Search"
//            self.seatchForArticals(searchBar.text!)
//            self.wikiTableView.reloadData()
//        }else{
//            let Alert = alert()
//            Alert.msg(message: "Please getting recent search results", title: "No Internet!")
//            setUpArticles()
//            self.wikiTableView.reloadData()
//        }
        
    }
    
    func seatchForArticals(_ searchBarText: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        queryService.getSearchResults(searchTerm: searchBarText) { results, errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //let Alert = alert()
            
            if !errorMessage.isEmpty && (results?.isEmpty)! {
                print("Search error: " + errorMessage)
               // Alert.msg(message: "Dictionary does not contain results key", title: "Search error!")
            }
            
            if let results = results {
                self.articleArray = results
                self.currentArticleArray = self.articleArray
                DispatchQueue.main.async {
                    self.wikiTableView.reloadData()
                }
            }else{
                
            }
        }
    }
}



