//
//  ReactiveCocoaExtensions.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 12/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation
import ReactiveCocoa

extension RACSignal {
  func asSignal() -> Signal<AnyObject?, NSError> {
    return Signal {
      sink in
      self.subscribeNext({
          any in
          sendNext(sink, any)
        }, error: {
          error in
          sendError(sink, error)
        }, completed: {
          sendCompleted(sink)
        })
    }
  }
}

public func toVoidSignal<T, E>(signal: Signal<T, E>) -> Signal<(), NoError> {
  return Signal {
    sink in
    signal.observe({
      event in
      switch event {
      case .Next:
        sendNext(sink, ())
      default:
        break
      }
    })
  }
}