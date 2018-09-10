//
//  DetailViewController.swift
//  WikipediaSearch
//
//  Created by Lova Rama Krishna P on 09/09/18.
//  Copyright © 2018 Lova Rama Krishna P. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class DetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    var coreDataStack = CoreDataStack()
     let queryService = QueryService()
    var preasentArtical = Article(name: "", image: "", description: "", articalContent: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       if Network.reachability?.isConnectedToNetwork == true {
            //Do what you need, for example send JSON request on server
        self.makeServiceCall()
        }else{
            //Load from local
            self.getFromLocalDb()
        }
    }
    
    func makeServiceCall(){
        let sv = UIViewController.displaySpinner(onView: self.view)
        queryService.getSearchResultsForMainPage(searchTerm:(preasentArtical.name))  { results, errorMessage in
            if !results.isEmpty {
                let htmlString:String! = results
                self.webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
                 UIViewController.removeSpinner(spinner: sv)
                self.title = self.preasentArtical.name
                let newArtical = Article.init(name: self.preasentArtical.name, image: self.preasentArtical.image, description: self.preasentArtical.description, articalContent: htmlString)
                self.savedToRecentelyViewedArticals(newArtical: newArtical)
            }else{
                let Alert = alert()
                Alert.msg(message: "Dictionary does not contain results key", title: "Loading error!")
                 UIViewController.removeSpinner(spinner: sv)
            }
        }
    }
    
    func savedToRecentelyViewedArticals(newArtical : Article){
        let moc = coreDataStack.persistentContainer.viewContext
        let artical = Artical(context: moc)
        artical.descriptionText = newArtical.description
        artical.image = newArtical.image as String
        artical.name = newArtical.name
        artical.articalContent = newArtical.articalContent
        coreDataStack.saveContext()
    }
    
    func getFromLocalDb(){

        let moc = coreDataStack.persistentContainer.viewContext
        // let artical = Artical(context: moc)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artical")
        request.predicate = NSPredicate(format: "name == %@", preasentArtical.name)
        request.returnsObjectsAsFaults = false
        do {
            let result = try moc.fetch(request) as! [Artical]
            if let aArtical = result.first {
                let htmlString:String! = aArtical.articalContent
                self.webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
            }
        } catch {
            print("Failed")
        }
    }
}

