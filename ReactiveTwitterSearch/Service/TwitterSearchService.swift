//
//  TwitterSearchService.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation
import Accounts
import Social
import ReactiveCocoa

class TwitterSearchService {
  
  private let accountStore: ACAccountStore
  private let twitterAccountType: ACAccountType
  
  init() {
    accountStore = ACAccountStore()
    twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
  }
  
  func requestAccessToTwitterSignal() -> SignalProducer<Int, NSError> {
    return SignalProducer {
      (observer: Observer<Int, NSError>, _) in
      self.accountStore.requestAccessToAccountsWithType(self.twitterAccountType, options: nil) {
        (granted, _) in
        if granted {
          observer.sendCompleted()
        } else {
          observer.sendFailed(TwitterInstantError.AccessDenied.toError())
        }
      }
    }
  }
  
  func signalForSearchWithText(text: String) -> SignalProducer<TwitterResponse, NSError> {
    
    func requestforSearchText(text: String) -> SLRequest {
      let url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
      let params = [
        "q" : text,
        "count": "100",
        "lang" : "en"
      ]
      return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: params)
    }
    
    return SignalProducer { sink, disposable in
      let request = requestforSearchText(text)
      let maybeTwitterAccount = self.getTwitterAccount()
      
      if let twitterAccount = maybeTwitterAccount {
        request.account = twitterAccount
        print("performing request")
        request.performRequestWithHandler { (data, response, _) in
          print("response received")
          if response != nil && response.statusCode == 200 {
            do {
                let timelineData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                sink.sendNext(TwitterResponse(tweetsDictionary: timelineData))
                sink.sendCompleted()
            } catch _ {
                sink.sendFailed(TwitterInstantError.InvalidResponse.toError())
            }
          } else {
            sink.sendFailed(TwitterInstantError.InvalidResponse.toError())
          }
        }
      } else {
        sink.sendFailed(TwitterInstantError.NoTwitterAccounts.toError())
      }
    }
  }
  
  private func getTwitterAccount() -> ACAccount? {
    return self.accountStore.accountsWithAccountType(self.twitterAccountType).first as? ACAccount ?? nil
  }
}
