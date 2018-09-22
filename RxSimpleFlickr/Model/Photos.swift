//
//  Photos.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 22/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import RxDataSources

struct Photos {
  var photos : [Photo]
}

extension Photos : SectionModelType {
  var items: [Photo] { return self.photos }
  
  init(original: Photos, items: [Photo]) {
    self = original
    self.photos = items
  }
}
