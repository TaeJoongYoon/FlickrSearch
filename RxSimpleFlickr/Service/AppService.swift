//
//  AppService.swift
//  RxSimpleFlickr
//
//  Created by 황병국 on 2018. 9. 23..
//  Copyright © 2018년 Tae joong Yoon. All rights reserved.
//

import RxSwift
import Alamofire
import SwiftyJSON

class AppService {
  static func request(url: String, headers: [String: String], params: [String: String]) -> Observable<[Photo]> {
    return Observable.create { observer -> Disposable in
      
      Alamofire.request(url, parameters: params, headers: headers).responseJSON { response in
        
        switch response.result {
        case .success(let value):
          let result = JSON(value)
          let photos = result["photos"]["photo"].arrayValue
            .map { Photo(id: $0["id"].stringValue,
                         owner: $0["owner"].stringValue,
                         secret: $0["secret"].stringValue,
                         server: $0["server"].stringValue,
                         farm: $0["farm"].intValue,
                         title: $0["title"].stringValue,
                         ispubilc: $0["ispublic"].intValue,
                         isfriend: $0["isfriend"].intValue,
                         isfamily: $0["isfamily"].intValue)
          }
          observer.onNext(photos)
          observer.onCompleted()
          
        case .failure(let error):
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
}
