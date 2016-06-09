//
//  TweetCell.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 11/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

class TweetCellView: UITableViewCell, ReactiveView {

	@IBOutlet weak var usernameText: UILabel!
	@IBOutlet weak var statusText: UILabel!
	@IBOutlet weak var avatarImageView: UIImageView!
	@IBOutlet weak var ageText: UILabel!

	lazy var scheduler: QueueScheduler = {
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
		return QueueScheduler(queue: queue)
	}()

	lazy var reuseSignal : Signal<(), NoError> = {
		return self.prepareForReuseSignal().on (
			next: { _ in
//				print("reuse triggered")
		})
	}()

	func bindViewModel(viewModel: AnyObject) {
		if let tweetViewModel = viewModel as? TweetViewModel {
			DynamicProperty(object: statusText, keyPath: "text") <~ tweetViewModel.status
			DynamicProperty(object: usernameText, keyPath: "text") <~ tweetViewModel.username.producer.map { "@\($0)" }

			// because the ageInSeconds property is mutable, we need to ensure that we 'complete'
			// the signal that the rac_text property is bound to. Hence the use of takeUntil.
			DynamicProperty(object: ageText, keyPath: "text") <~ tweetViewModel.ageInSeconds.producer
				.map { "\($0) secs" }
				.takeUntil(reuseSignal)

			avatarImageView.image = nil
			avatarImageSignalProducer(tweetViewModel.profileImageUrl.value)
				.startOn(scheduler)
				.takeUntil(reuseSignal)
				.observeOn(UIScheduler())
				.startWithNext { [weak self] in
					self?.avatarImageView.image = $0
				}
		}
	}

	private func avatarImageSignalProducer(imageUrl: String) -> SignalProducer<UIImage?, NoError> {
		return SignalProducer { (observer: Observer<UIImage?, NoError>, _) in
			if let url = NSURL(string: imageUrl), data = NSData(contentsOfURL: url) {
				observer.sendNext(UIImage(data: data))
			}
			observer.sendCompleted()
		}
	}
}
