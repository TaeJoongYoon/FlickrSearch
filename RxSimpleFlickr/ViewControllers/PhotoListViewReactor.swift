//
//  PhotoListViewReactor.swift
//  RxSimpleFlickr
//
//  Created by Tae joong Yoon on 24/09/2018.
//  Copyright © 2018 Tae joong Yoon. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit

class PhotoListViewReactor : Reactor {
  
  enum Action {
    case searchFlickr(String)
  }
  
  enum Mutation {
    case flickrList([Photos])
  }
  
  struct State{
    var keyword : String?
    var photos : [Photos]?
  }
  
  var initialState: State = State()

  init() { }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .searchFlickr(keyword):
      return AppService.request(keyword: keyword)
              .catchErrorJustReturn([])
              .map{[Photos(photos: $0)]}
              .map {Mutation.flickrList($0)}
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .flickrList(photos):
      newState.photos = photos
    }
    
    return newState
  }
  
}
