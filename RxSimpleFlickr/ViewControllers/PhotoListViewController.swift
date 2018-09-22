//
//  ViewController.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 22/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Alamofire
import SwiftyJSON
import RxCocoa
import RxSwift
import RxDataSources

class PhotoListViewController: UIViewController {
  
  let BASE_URL = "https://api.flickr.com/services/rest/"
  
  var parameters = [
    "method": "flickr.photos.search",
    "api_key": "##############################",
    "format": "json",
    "per_page": "100",
    "nojsoncallback": "1"
  ]
  
  let headers = [
    "Content-Type": "application/json"
  ]
  
  // MARK : Constants
  
  struct Constant {
    static let cellIdentifier = "cell"
  }
  
  struct Metric {
    static let lineSpacing : CGFloat = 10
    static let intetItemSpacing : CGFloat = 10
    static let edgeInset : CGFloat = 8
  }
  
  // MARK : Rx
  
  let disposeBag = DisposeBag()
  
  // MARK: Properties
  
  let dataSources = RxCollectionViewSectionedReloadDataSource<Photos>(configureCell: { dataSource, collectionView, indexPath, item in
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.cellIdentifier, for: indexPath) as! PhotoCell
    
    let url = URL(string: "https://farm\(item.farm).staticflickr.com/\(item.server)/\(item.id)_\(item.secret).jpg")
    cell.flickrPhoto.kf.setImage(with: url)
    
    return cell
  })
  
  let searchBar : UISearchBar = {
    let s = UISearchBar(frame: .zero)
    s.searchBarStyle = .prominent
    s.placeholder = " Search Flickr"
    s.sizeToFit()
    
    return s
  }()
  
  let collectionView : UICollectionView = {
    let c = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    c.translatesAutoresizingMaskIntoConstraints = false
    c.backgroundColor = .white
    c.register(PhotoCell.self, forCellWithReuseIdentifier: Constant.cellIdentifier)
    return c
  }()
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Search RxFlickr"
    self.view.addSubview(self.searchBar)
    self.view.addSubview(self.collectionView)
    
    setupConstraints()
    bind()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: Constraints
  
  func setupConstraints() {
    self.collectionView.snp.makeConstraints{(make) -> Void in
      make.top.equalTo(self.searchBar.snp.bottom)
      make.left.equalTo(self.view)
      make.bottom.equalTo(self.view)
      make.right.equalTo(self.view)
    }
    
    self.searchBar.snp.makeConstraints{(make) -> Void in
      make.top.equalTo(self.view).offset(20 + 44)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
    }
  }
  
  // MARK: Binding
  
  func bind() {
    self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    self.collectionView.rx.modelSelected(Photo.self).subscribe(onNext: { photo in
      let view = DetailViewController()
      view.photoTitle = photo.title
      view.farm = photo.farm
      view.server = photo.server
      view.id = photo.id
      view.secret = photo.secret
      self.navigationController?.pushViewController(view, animated: true)
    })
    .disposed(by: disposeBag)
    self.searchBar.rx.text
      .orEmpty
      .debounce(0.5, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [unowned self] text in
        self.parameters["text"] = text
        Alamofire.request(self.BASE_URL, parameters: self.parameters, headers: self.headers).responseJSON { response in
          
          switch response.result {
          case .success(let value):
            let result = JSON(value)
            let photos = result["photos"]["photo"].arrayValue.map{Photo(id: $0["id"].stringValue, owner: $0["owner"].stringValue, secret: $0["secret"].stringValue, server: $0["server"].stringValue
              , farm: $0["farm"].intValue, title: $0["title"].stringValue, ispubilc: $0["ispublic"].intValue, isfriend: $0["isfriend"].intValue, isfamily: $0["isfamily"].intValue)}
            
            self.collectionView.dataSource = nil
            
            BehaviorRelay(value: [Photos(photos: photos)])
              .bind(to: self.collectionView.rx.items(dataSource: self.dataSources))
              .disposed(by: self.disposeBag)
          
          case .failure(let error):
            print(error)
          }
        }
      })
      .disposed(by: disposeBag)
  }
}


// MARK: Extension

extension PhotoListViewController: UICollectionViewDelegateFlowLayout{
  
  //DelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.bounds.size.width-40)/3, height: (collectionView.bounds.size.width-40)/3)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) ->CGFloat {
    return Metric.lineSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return Metric.intetItemSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.init(top: Metric.edgeInset, left: Metric.edgeInset, bottom: Metric.edgeInset, right: Metric.edgeInset)
  }
}

