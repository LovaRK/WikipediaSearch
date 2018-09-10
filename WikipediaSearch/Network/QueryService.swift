
import Foundation
import CoreData


// Runs query data task, and stores results in array of Article
class QueryService {

  typealias JSONDictionary = [String: Any]
  typealias QueryResult = ([Article]?, String) -> ()
  typealias Results = (String, String) -> ()

  let defaultSession = URLSession(configuration: .default)
  var dataTask: URLSessionDataTask?
  var articles: [Article] = []
  var htmlString : String = ""
  var errorMessage = ""
   var coreDataStack = CoreDataStack()

  func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
    dataTask?.cancel()
    
    if Network.reachability?.isConnectedToNetwork == true {
        //Do what you need, for example send JSON request on server
    if var urlComponents = URLComponents(string: "https://en.wikipedia.org//w/api.php") {
        let newString = searchTerm.replacingOccurrences(of: " ", with: "+")
      urlComponents.query = "action=query&format=json&prop=pageimages|pageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=+\(newString)&gpslimit=10"
      guard let url = urlComponents.url else { return }
      dataTask = defaultSession.dataTask(with: url) { data, response, error in
        defer { self.dataTask = nil }
        if let error = error {
          self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
        } else if let data = data,
          let response = response as? HTTPURLResponse,
          response.statusCode == 200 {
          self.updateSearchResults(data)
          DispatchQueue.main.async {
            completion(self.articles, self.errorMessage)
          }
        }
      }
      dataTask?.resume()
    }
     }else{
        // No internet
        let Alert = alert()
       // Alert.msg(message: "")
        Alert.msg(message: "The Internet is not available", title: "No Internet!")
    }
  }
    
     func getSearchResultsForMainPage(searchTerm: String, completion: @escaping Results) {
        dataTask?.cancel()
         if Network.reachability?.isConnectedToNetwork == true {
            //Do what you need, for example send JSON request on server
        let text = searchTerm.removingWhitespaces()
        if var urlComponents = URLComponents(string: "https://en.wikipedia.org/api/rest_v1/page/mobile-html/\(text)") {
           // urlComponents.query = "\(searchTerm)"
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.updateSearchResultsForFullPage(data)
                    DispatchQueue.main.async {
                        completion( self.htmlString, self.errorMessage)
                    }
                }
            }
            dataTask?.resume()
        }
         }else{
            // No internet
            let Alert = alert()
             Alert.msg(message: "The Internet is not available", title: "No Internet!")
        }
    }

    
    fileprivate func updateSearchResultsForFullPage(_ data: Data) {
        let dataString = String(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
        htmlString = dataString
    }

  fileprivate func updateSearchResults(_ data: Data) {
    var response: JSONDictionary?
    articles.removeAll()
    do {
      response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
    } catch let parseError as NSError {
      errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
      return
    }
    

    guard let query = response!["query"] as? [String : AnyObject] else {
        errorMessage += "Dictionary does not contain results key\n"
        return
    }
    guard let array = query["pages"] as? [Any] else {
      errorMessage += "Dictionary does not contain results key\n"
      return
    }
    var index = 0
    var imageUrl = ""
    var name = ""
    var description = ""

    for trackDictionary in array {
        let trackDictionary = trackDictionary as? [String : AnyObject]
        if (trackDictionary?.keys.contains("thumbnail"))!
        {
        let preview = trackDictionary!["thumbnail"]!["source"] as? String
            imageUrl = preview!
        }
         name  = (trackDictionary!["title"] as? String)!
        if (trackDictionary?.keys.contains("terms"))!{
           let descriptionArray = (trackDictionary!["terms"]!["description"] as? NSArray)!
            description = descriptionArray.firstObject as! String
        }
        articles.append(Article(name: name, image: imageUrl, description: description, articalContent: ""))
            index += 1
    }
  }

}
