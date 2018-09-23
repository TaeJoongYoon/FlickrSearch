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
import RxCocoa
import RxSwift
import RxDataSources

class PhotoListViewController: UIViewController {
  
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
    self.collectionView.snp.makeConstraints{ make in
      make.top.equalTo(self.searchBar.snp.bottom)
      make.left.right.bottom.equalTo(self.view)
    }
    
    self.searchBar.snp.makeConstraints{ make in
      make.top.equalTo(self.view).offset(20 + 44)
      make.left.right.equalTo(self.view)
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
      .map { [weak self] keyword -> (String, [String: String], [String: String]) in
        var params = self?.parameters ?? [:]
        params["text"] = keyword

        let url = self?.BASE_URL ?? ""
        let headers = self?.headers ?? [:]
        return (url, headers, params)
      }
      .flatMap {
        return AppService.request(url: $0.0, headers: $0.1, params: $0.2).catchErrorJustReturn([])
      }
      .map { [Photos(photos: $0)] }
      .asDriver(onErrorJustReturn: [])
      .drive(collectionView.rx.items(dataSource: dataSources))
      .disposed(by: disposeBag)
  }
}


// MARK: Extension

extension PhotoListViewController: UICollectionViewDelegateFlowLayout{
  
  //DelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.bounds.size.width - 40) * 0.33,
                  height: (collectionView.bounds.size.width - 40) * 0.33)
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) ->CGFloat {
    return Metric.lineSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return Metric.intetItemSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(Metric.edgeInset,
                            Metric.edgeInset,
                            Metric.edgeInset,
                            Metric.edgeInset)
  }
}

