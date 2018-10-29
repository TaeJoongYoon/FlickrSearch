//
//  UIViewController+Extension.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 29/10/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import SnapKit

extension UIView {
  
  var safeArea: ConstraintBasicAttributesDSL {
    
    #if swift(>=3.2)
    if #available(iOS 11.0, *) {
      return self.safeAreaLayoutGuide.snp
    }
    return self.snp
    #else
    return self.snp
    #endif
  }
}
