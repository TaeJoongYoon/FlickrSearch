//
//  CollectionViewCell.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 22/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import UIKit
import SnapKit

class PhotoCell: UICollectionViewCell {
  
  // MARK: Properties
  
  let flickrPhoto : UIImageView = {
    let f = UIImageView(frame: .zero)
    f.translatesAutoresizingMaskIntoConstraints = false
    
    return f
  }()
  
  // MARK: Initialize
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.contentView.addSubview(self.flickrPhoto)
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    fatalError("Interface Builder is not supported!")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    fatalError("Interface Builder is not supported!")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.flickrPhoto.image = nil
  }
  
  // MARK: Constraints
  
  func setupConstraints() {
    self.flickrPhoto.snp.makeConstraints{(make) -> Void in
      make.edges.equalTo(self.contentView)
    }
  }
}
