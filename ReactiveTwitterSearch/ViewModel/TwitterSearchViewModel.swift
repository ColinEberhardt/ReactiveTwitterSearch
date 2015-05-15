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
    
    let name = MutableProperty<String>("")
    
    let textToSearchSignal: SignalProducer<String, NSError>  -> SignalProducer<TwitterResponse, NSError> =
      flatMap(.Latest) {
        text in self.searchService.signalForSearchWithText(text)
      }

    searchService.requestAccessToTwitterSignal()
      |> then(searchText.producer |> mapError { _ in TwitterInstantError.NoError.toError() })
      |> filter {
          count($0) > 3
        }
      |> throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
      |> on(next: {
          _ in self.isSearching.put(true)
        })
      |> textToSearchSignal
      |> observeOn(QueueScheduler.mainQueueScheduler)
      |> start(next: {
          response in
          self.isSearching.put(false)
          self.queryExecutionTime.put("Execution time: \(response.responseTime)")
          self.tweets.put(response.tweets.map { TweetViewModel(tweet: $0) })
        }, error: {
          println("Error \($0)")
        })
    
    timer(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
      |> start(next: {
        _ in
        for tweet in self.tweets.value {
          tweet.updateTime()
        }
      })
  }
}
