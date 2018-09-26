//
//  AppService.swift
//  RxSimpleFlickr
//
//  Created by 황병국 on 2018. 9. 23..
//  Copyright © 2018년 Tae joong Yoon. All rights reserved.
//

import Alamofire
import RxSwift
import SwiftyJSON
import ObjectMapper

class AppService {
  static let baseURL = "https://api.flickr.com/services/rest/"
  
  static let parameters = [
    "method": "flickr.photos.search",
    "api_key": "##########################",
    "format": "json",
    "per_page": "100",
    "nojsoncallback": "1"
  ]
  
  static let headers = [
    "Content-Type": "application/json"
  ]
    
  static func request(keyword: String) -> Observable<[Photo]> {
    return Observable.create { observer -> Disposable in
      var params = parameters
      params["text"] = keyword
      
      Alamofire.request(baseURL, parameters: params, headers: headers).responseJSON { response in
        
        switch response.result {
        case .success(let value):
          let result = JSON(value)["photos"]["photo"].rawString()
          let photos = Mapper<Photo>().mapArray(JSONString: result!)
          
          observer.onNext(photos!)
          observer.onCompleted()
          
        case .failure(let error):
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
}
