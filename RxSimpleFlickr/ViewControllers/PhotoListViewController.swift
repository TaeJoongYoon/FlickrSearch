//
//  ViewController.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 22/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import UIKit

import Kingfisher
import ReactorKit
import ReusableKit
import RxCocoa
import RxDataSources
import RxOptional
import RxSwift
import SnapKit
import Then

class PhotoListViewController: UIViewController, ReactorKit.View {
  
  // MARK : Constants
  
  struct Reusable {
    static let flickrCell = ReusableCell<PhotoCell>()
  }
  
  struct Constant {
    static let cellIdentifier = "cell"
  }
  
  struct Metric {
    static let lineSpacing: CGFloat = 10
    static let intetItemSpacing: CGFloat = 10
    static let edgeInset: CGFloat = 8
  }
  
  // MARK : Rx
  
  var disposeBag = DisposeBag()
  
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
  
  let collectionView = UICollectionView(frame: .zero,
                                        collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .white
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.register(Reusable.flickrCell)
  }
  
  // MARK: Initializing
  
  init(reactor: PhotoListViewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Search RxFlickr"
    self.view.addSubview(self.searchBar)
    self.view.addSubview(self.collectionView)
    
    setupConstraints()
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
  
  func bind(reactor: PhotoListViewReactor) {
    // DataSource
    self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
    
    self.collectionView.rx.modelSelected(Photo.self).subscribe(onNext: { photo in
      let view = DetailViewController()
      view.photo = photo
      self.navigationController?.pushViewController(view, animated: true)
    })
      .disposed(by: disposeBag)
    
    // Action
    self.searchBar.rx.text
      .orEmpty
      .debounce(1.0, scheduler: MainScheduler.instance)
      .filter { !$0.isEmpty }
      .map(Reactor.Action.searchFlickr)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // State
    reactor.state.asObservable().map { $0.photos }
      .replaceNilWith([])
      .bind(to: collectionView.rx.items(dataSource: dataSources))
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoListViewController: UICollectionViewDelegateFlowLayout{
  
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

