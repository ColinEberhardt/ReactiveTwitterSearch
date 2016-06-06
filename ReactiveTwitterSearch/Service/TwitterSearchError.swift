//
//  TwitterSearchError.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 12/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import Foundation

// Twitter Search specific errors
enum TwitterInstantError: ErrorType {
	case AccessDenied, NoTwitterAccounts, InvalidResponse
}
