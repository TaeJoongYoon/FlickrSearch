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
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                             style: .done,
                                                             target: self,
                                                             action: #selector(save(_:)))
    
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
  
  // MARK: Functions
  
  //MARK: - Saving Image here
  
  @objc func save(_ sender: AnyObject) {
    guard let selectedImage = self.imageView.image else {
      print("Image not found!")
      return
    }
    UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
  }
  
  //MARK: - Add image to Library
  
  @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      showAlertWith(title: "Save error", message: error.localizedDescription)
    } else {
      showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
    }
  }
  
  func showAlertWith(title: String, message: String){
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
  }
}
