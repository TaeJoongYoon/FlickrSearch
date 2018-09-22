//
//  DetailViewController.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 23/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class DetailViewController: UIViewController {

  // MARK: Properties
  
  var photoTitle = String()
  var farm = Int()
  var server = String()
  var id = String()
  var secret = String()
  
  let photo : UIImageView = {
    let p = UIImageView(frame: .zero)
    p.translatesAutoresizingMaskIntoConstraints = false
    
    return p
  }()
  
  let titleLabel : UILabel = {
    let l = UILabel(frame: .zero)
    
    return l
  }()
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(photo)
    self.view.addSubview(titleLabel)
    
    setupConstraints()
    
    
    let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")
    self.photo.kf.setImage(with: url)
    
    self.titleLabel.text = photoTitle
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: Constraints
  
  func setupConstraints() {
    self.photo.snp.makeConstraints{(make) -> Void in
      make.center.equalTo(self.view)
      make.width.equalTo(240)
      make.height.equalTo(240)
    }
    
    self.titleLabel.snp.makeConstraints{(make) -> Void in
      make.top.equalTo(self.photo.snp.bottom).offset(20)
      make.centerX.equalTo(self.view)
    }
  }
}
