//
//  ReactiveCocoaExtensions.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 12/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

/*
extension RACSignal {
  func asSignal() -> Signal<AnyObject?, NSError> {
    return Signal {
        (observer: Observer<Value, Error>) in
      self.subscribeNext({
          (any: AnyObject!) -> Void in
          observer.sendNext(any)
        }, error: {
          error in
          observer.sendFailed(error)
        }, completed: {
          observer.sendCompleted()
        })
    }
  }
}
*/

public func toVoidSignal<T, E>(signal: Signal<T, E>) -> Signal<(), NoError> {
  return Signal {
    sink in
    signal.observe({
      event in
      switch event {
      case .Next:
        sink.sendNext(())
      default:
        break
      }
    })
  }
}