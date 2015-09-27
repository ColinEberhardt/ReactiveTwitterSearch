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
      sink, _ in
      self.accountStore.requestAccessToAccountsWithType(self.twitterAccountType, options: nil) {
        (granted, _) in
        if granted {
          sendCompleted(sink)
        } else {
          sendError(sink, TwitterInstantError.AccessDenied.toError())
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
    
    return SignalProducer {
      sink, disposable in
      
      let request = requestforSearchText(text)
      let maybeTwitterAccount = self.getTwitterAccount()
      
      if let twitterAccount = maybeTwitterAccount {
        request.account = twitterAccount
        print("performing request")
        request.performRequestWithHandler {
          (data, response, _) -> Void in
          print("response received")
          if response != nil && response.statusCode == 200 {
            do {
            let timelineData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                sendNext(sink, TwitterResponse(tweetsDictionary: timelineData))
                sendCompleted(sink)
            } catch _  {
                sendError(sink, TwitterInstantError.InvalidResponse.toError())
            }
          } else {
            sendError(sink, TwitterInstantError.InvalidResponse.toError())
          }
        }
      } else {
        sendError(sink, TwitterInstantError.NoTwitterAccounts.toError())
      }
    }
  }
  
  private func getTwitterAccount() -> ACAccount? {
    let twitterAccounts = self.accountStore.accountsWithAccountType(self.twitterAccountType) as! [ACAccount]
    if twitterAccounts.count == 0 {
      return nil
    } else {
      return twitterAccounts[0]
    }
  }
}
