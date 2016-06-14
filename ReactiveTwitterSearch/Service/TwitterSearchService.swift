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

	func requestAccessToTwitterSignal() -> SignalProducer<Int, TwitterInstantError> {
		return SignalProducer { (observer: Observer<Int, TwitterInstantError>, _) in
			self.accountStore.requestAccessToAccountsWithType(self.twitterAccountType, options: nil) {
				(granted, _) in
				if granted {
					observer.sendCompleted()
				} else {
					observer.sendFailed(TwitterInstantError.AccessDenied)
				}
			}
		}
	}

	func signalForSearchWithText(text: String) -> SignalProducer<TwitterResponse, TwitterInstantError> {
		func requestforSearchText(text: String) -> SLRequest {
			let url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
			let params = [
				"q" : text,
				"count": "100",
				"lang" : "en"
			]
			return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: params)
		}

		return SignalProducer { sink, _ in
			let request = requestforSearchText(text)

			guard let twitterAccount = self.getTwitterAccount() else {
				sink.sendFailed(TwitterInstantError.NoTwitterAccounts)
				return
			}

			request.account = twitterAccount
			request.performRequestWithHandler { (data, response, _) in
				guard response != nil && response.statusCode == 200,
					let timelineData = (try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? NSDictionary else {
					sink.sendFailed(TwitterInstantError.InvalidResponse)
					return
				}
				
				sink.sendNext(TwitterResponse(tweetsDictionary: timelineData))
				sink.sendCompleted()
			}
		}
	}

	private func getTwitterAccount() -> ACAccount? {
		return self.accountStore.accountsWithAccountType(self.twitterAccountType).first as? ACAccount //?? nil
	}
}
