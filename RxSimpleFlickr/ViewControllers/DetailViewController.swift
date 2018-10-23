//
//  DetailViewController.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 23/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import UIKit

import Kingfisher
import SnapKit
import Then

class DetailViewController: UIViewController {

  // MARK: Properties
  var photo = Photo()
  
  let imageView = UIImageView(frame: .zero).then {
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  let titleLabel = UILabel(frame: .zero)
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.imageView)
    self.view.addSubview(self.titleLabel)
    
    setupConstraints()
    
    
    if let imageURL = photo?.flickrURL(), let url = URL(string: imageURL) {
        self.imageView.kf.setImage(with: url)
    }
    
    self.titleLabel.text = photo?.title
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: Constraints
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.center.equalTo(self.view)
      make.width.height.equalTo(240)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.imageView.snp.bottom).offset(20)
      make.centerX.equalTo(self.view)
    }
  }
}
