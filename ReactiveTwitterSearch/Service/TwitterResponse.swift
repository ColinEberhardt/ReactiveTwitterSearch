//
//  TwitterResponse.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 12/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation

struct TwitterResponse {
  let responseTime: Double
  let tweets: [Tweet]
  
  init(tweetsDictionary: NSDictionary) {
    let statusData = tweetsDictionary["statuses"] as! [NSDictionary]
    let searchMetadata = tweetsDictionary["search_metadata"] as! NSDictionary
    
    tweets = statusData.map { Tweet(json: $0) }
    responseTime = searchMetadata["completed_in"] as! Double
  }
}