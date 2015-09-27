//
//  TwitterSearchViewModel.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation
import ReactiveCocoa

class TwitterSearchViewModel {
  
  let searchText = MutableProperty<String>("")
  let queryExecutionTime = MutableProperty<String>("")
  let isSearching = MutableProperty<Bool>(false)
  let tweets = MutableProperty<[TweetViewModel]>([TweetViewModel]())
  
  private let searchService: TwitterSearchService
  
  init(searchService: TwitterSearchService) {
    
    self.searchService = searchService
    
    let _ = MutableProperty<String>("")
    
    
    
    searchService.requestAccessToTwitterSignal()
        .then(searchText.producer.mapError({ _ in TwitterInstantError.NoError.toError() })
            .filter {
                $0.characters.count > 3
            }
            .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .on(next: {
                _ in self.isSearching.value = true
            })
            .flatMap(.Latest) { text in
                self.searchService.signalForSearchWithText(text)
            })
        .observeOn(QueueScheduler.mainQueueScheduler).start(Event.sink(error: {
            print("Error \($0)")
            },
            next: {
                response in
                self.isSearching.value = false
                self.queryExecutionTime.value = "Execution time: \(response.responseTime)"
                self.tweets.value = (response.tweets.map { TweetViewModel(tweet: $0) })
        }))
    
    timer(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
      .startWithNext( {
        _ in
        for tweet in self.tweets.value {
          tweet.updateTime()
        }
      })
  }
}
