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
import ReusableKit
import Then

class PhotoListViewController: UIViewController {
  
  // MARK : Constants
  
  struct Reusable {
    static let flickrCell = ReusableCell<PhotoCell>()
  }
  
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
  
  let dataSources = RxCollectionViewSectionedReloadDataSource<Photos>(configureCell: { dataSource,
                                                                                    collectionView,
                                                                                    indexPath,
                                                                                    item in
    let cell = collectionView.dequeue(Reusable.flickrCell, for: indexPath)
    let url = URL(string: item.flickrURL())
    cell.flickrPhoto.kf.setImage(with: url)
    
    return cell
  })

  let searchBar = UISearchBar(frame: .zero).then{
    $0.searchBarStyle = .prominent
    $0.placeholder = "Search Flickr"
    $0.sizeToFit()
  }
  
  let collectionView : UICollectionView = {
    let collectionView = UICollectionView(frame: .zero
      , collectionViewLayout: UICollectionViewFlowLayout())
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .white
    collectionView.register(Reusable.flickrCell)
    return collectionView
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
      view.photo = photo
      self.navigationController?.pushViewController(view, animated: true)
    })
    .disposed(by: disposeBag)
    
    self.searchBar.rx.text
      .orEmpty
      .debounce(1.0, scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .filter { !$0.isEmpty }
      .flatMap {
        return AppService.request(keyword: $0).catchErrorJustReturn([])
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

