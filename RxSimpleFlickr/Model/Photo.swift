//
//  Photo.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 22/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import ObjectMapper

struct Photo: Mappable{
  var id: String?
  var owner: String?
  var secret: String?
  var server: String?
  var farm: Int?
  var title: String?
  var ispubilc: Int?
  var isfriend: Int?
  var isfamily: Int?
  
  init?() { }
  
  init?(map: Map) {  }
  
  mutating func mapping(map: Map) {
    id <- map["id"]
    owner <- map["owner"]
    secret <- map["secret"]
    server <- map["server"]
    farm <- map["farm"]
    title <- map["title"]
    ispubilc <- map["ispublic"]
    isfriend <- map["isfriend"]
    isfamily <- map["isfamily"]
  }
  
  func flickrURL() -> String{
    return "https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!).jpg"
  }
}
