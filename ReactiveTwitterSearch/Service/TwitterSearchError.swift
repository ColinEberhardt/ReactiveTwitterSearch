//
//  TwitterSearchError.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 12/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation

// an enumeration that is used for generating NSError codes
enum TwitterInstantError: Int {
  case AccessDenied = 0,
    NoTwitterAccounts,
    InvalidResponse,
    NoError
  
  func toError() -> NSError {
    return NSError(domain:"TwitterSearch", code: self.rawValue, userInfo: nil)
  }
}