//
//  Network.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 22/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxCocoa
import RxSwift

class Network {
  
  static func getPhotos(with : String) -> [String]?{
    let BASE_URL = "https://api.flickr.com/services/rest/"
    
    var parameters = [
      "method": "flickr.photos.search",
      "api_key": "36530b310e1eabc357cb00ba6c14bebd",
      "format": "json",
      "per_page": "100",
      "nojsoncallback": "1"
    ]
    
    let headers = [
      "Content-Type": "application/json"
    ]
    var PHOTOS = [String]()
    
    parameters["text"] = with
  
    Alamofire.request(BASE_URL, parameters: parameters, headers: headers).responseJSON { response in
      
      switch response.result {
      case .success(let value):
        let result = JSON(value)
        let photos = result["photos"]["photo"].arrayValue
        
        PHOTOS = photos.map{"https://farm\($0["farm"]).staticflickr.com/\($0["server"])/\($0["id"])_\($0["secret"]).jpg"}
       
      case .failure(let error):
        print(error)
      }
    }
    return PHOTOS
  }
}
