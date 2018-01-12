//
//  DataLoader.swift
//  Evento
//
//  Created by Aleksey Bykhun on 11.01.2018.
//  Copyright © 2018 Aleksey Bykhun. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

import SwiftyJSON
import BrightFutures

import FacebookCore

protocol JSONDataModel {
    init(json: JSON)
}

struct User: JSONDataModel {
    var id: Int
    var name: String
    
    init(rawResponse: Any?) {
        let json = JSON(rawResponse ?? "")
        
        self.init(json: json)
    }
    
    init(json: JSON) {
        print("user data:")
        print(json)
        
        id = json["id"].intValue
        name = json["name"].stringValue
    }
}
struct Event: JSONDataModel {
    var id: Int
    var name: String
    var location: String {
        return getLocation()
    }
    var place: JSON
    var pinned = false
    
    var picture: URL?
    var pictureCached: Future<UIImage, NSError>?
    var pictureParsed: UIImage? {
        return pictureCached?.result?.value
    }
    
    var date: Date
    var text: String
    
    var linkAddress: String {
        return "https://www.facebook.com/events/\(id)"
    }
    
    var isAtThisWeek: Bool {
        return date > Date(timeIntervalSinceNow: -24*60*60*7)
            && date < Date(timeIntervalSinceNow: 24*60*60*7)
    }
    
    static var dateParser: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return df
    }()
    
    static var dateFormatter: DateComponentsFormatter = {
        let df = DateFormatter()
        df.locale = Locale.init(identifier: "ru_RU")
        df.dateFormat = "EEEE dd MMM yyyy"
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
      
        return formatter
    }()
    
    init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        text = json["description"].stringValue
        picture = json["cover"]["source"].url
        
        place = json["place"]
        
        date = Event.dateParser.date(from: json["start_time"].stringValue) ?? Date(timeIntervalSinceNow: 0)
        
        pictureCached = prefetchPicture()
    }
    
    func getText() -> String {
        if let dateString = Event.dateFormatter.string(from: Date(), to: date) {
            return "\(dateString), \(location) \n \(text)"
        } else {
            return ""
        }
    }
    
    func getLocation() -> String {
        let loc = place["location"]
        return "\(place["name"].stringValue), \(loc["city"].stringValue), \(loc["country"].stringValue)"
    }
    
    func getDateString() -> String {
        
        if date > Date() {
            if let dateString = Event.dateFormatter.string(from: Date(), to: date) {
                return "in \(dateString)"
            } else {
                return ""
            }
        } else {
            if let dateString = Event.dateFormatter.string(from: date, to: Date()) {
                return "\(dateString) ago"
            } else {
                return ""
            }
        }

    }
    
    func prefetchPicture() -> Future<UIImage, NSError>? {
        guard let picture = picture else {
            return nil
        }
        
        let picturePromise = Promise<UIImage, NSError>()
        
        Alamofire.request(picture).responseImage {
            response in
            if let image = response.result.value {
                picturePromise.success(image)
            } else {
                picturePromise.failure(response.result.error! as NSError)
                
            }
        }
        
        return picturePromise.future
    }
}

protocol SocialConnection {
    func loadFriends() -> Future<[User], NSError>
    func loadEvents() -> Future<[Event], NSError>
}

extension GraphRequestConnection: SocialConnection {
    
    struct FBRequest<T: JSONDataModel>: GraphRequestProtocol {
        struct Response: GraphResponseProtocol {
            var json: JSON
            
            init(rawResponse: Any?) {
                json = JSON(rawResponse ?? "")
            }

            func getData(dataKey: String) -> [T] {
                return json[dataKey]["data"].arrayValue.map{ json in T.init(json: json) }
            }
        }
        
        var graphPath = "/me"

        var accessToken = AccessToken.current
        var httpMethod: GraphRequestHTTPMethod = .GET
        var apiVersion: GraphAPIVersion = .defaultVersion
        
        var parameters: [String : Any]?
        
        init(parameters: [String : Any]? = nil) {
            self.parameters = parameters ?? self.parameters
        }
    }
    
    func load<T: JSONDataModel>(parameters: [String : Any]? = nil, dataKey: String) -> Future<[T], NSError> {
        
        let p = Promise<[T], NSError>()
        
        self.add( FBRequest<T>( parameters: parameters ) ) { response, result in
            switch result {
            case .success(let response):
                
                print("response data:")
                let data = response.getData(dataKey: dataKey)
                print(data)
                
                p.success(data)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
            }
        }
        self.start()
        
        return p.future;
    }


    func loadFriends() -> Future<[User], NSError> {
        return self.load(parameters: ["fields":"friends"], dataKey: "friends")
    }
    
    func loadEvents() -> Future<[Event], NSError> {
       
        let params = ["fields": "events{category,description,owner,cover,start_time,place,name}"]
        
        return self.load(parameters: params, dataKey: "events")
            .map{ events in
                events
                    .sorted { $0.date > $1.date }
                    .filter { event in event.isAtThisWeek }
            }
        }
}

