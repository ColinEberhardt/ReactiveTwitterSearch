//
//  TweetCell.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 11/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

class TweetCellView: UITableViewCell, ReactiveView {
  
  @IBOutlet weak var usernameText: UILabel!
  @IBOutlet weak var statusText: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var ageText: UILabel!
  
  lazy var scheduler: QueueScheduler = {
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
    return QueueScheduler(queue: queue)
  }()
  
  func bindViewModel(viewModel: AnyObject) {
    if let tweetViewModel = viewModel as? TweetViewModel {
      
        
    //FIXME: how to lift this to signal producer for takeUntil?
      let triggerSignal = toVoidSignal(self.rac_prepareForReuseSignal.asSignal())

        
      statusText.rac_text <~ tweetViewModel.status
      
      usernameText.rac_text <~ tweetViewModel.username.producer.map { "@\($0)" }
      
      // because the ageInSeconds property is mutable, we need to ensure that we 'complete' 
      // the signal that the rac_text property is bound to. Hence the use of takeUntil.
      ageText.rac_text <~ tweetViewModel.ageInSeconds.producer
          .map { "\($0) secs" }
//          .takeUntil(triggerSignal)
      
      
      avatarImageView.image = nil
      avatarImageSignalProducer(tweetViewModel.profileImageUrl.value)
        .startOn(scheduler)
//        .takeUntil(triggerSignal)
        .observeOn(QueueScheduler.mainQueueScheduler)
        .start(Event.sink(next: {
          self.avatarImageView.image = $0
        }))
    }
  }
  
  private func avatarImageSignalProducer(imageUrl: String) -> SignalProducer<UIImage?, NoError> {
    return SignalProducer {
      sink, _ in
        guard let url = NSURL(string: imageUrl), data = NSData(contentsOfURL: url) else {
            print("App Transport Security rejected URL: \(imageUrl)")
            return
        }
      let image = UIImage(data: data)
      sendNext(sink, image)
      sendCompleted(sink)
    }
  }
}
