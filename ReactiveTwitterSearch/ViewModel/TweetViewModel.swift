//
//  TweetViewModel.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 11/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation
import ReactiveCocoa

class TweetViewModel: NSObject {
  
  let status: ConstantProperty<String>
  let username: ConstantProperty<String>
  let profileImageUrl: ConstantProperty<String>
  let ageInSeconds: MutableProperty<Int>
  
  private let tweet: Tweet
  
  init (tweet: Tweet) {
    self.tweet = tweet;
    
    ageInSeconds = MutableProperty(Int(NSDate().timeIntervalSinceDate(tweet.timestamp)))
    status = ConstantProperty(tweet.status)
    username = ConstantProperty(tweet.username)
    profileImageUrl = ConstantProperty(tweet.profileImageUrl)
  }
  
  private func computeAge() -> Int {
    return Int(NSDate().timeIntervalSinceDate(tweet.timestamp))
  }
  
  func updateTime() {
    ageInSeconds.value = computeAge()
  }
  
}