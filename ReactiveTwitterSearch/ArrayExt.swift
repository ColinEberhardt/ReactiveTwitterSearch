//
//  ArrayExt.swift
//  ReactiveTwitterSearch
//
//  Created by Patrick Reynolds on 5/7/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

import Foundation

extension Array {

    // See Swiftz: https://github.com/typelift/Swiftz/blob/master/Swiftz/ArrayExt.swift#L214
    /// Safely indexes into an array by converting out of bounds errors to nils.
    public func safeIndex(i : Int) -> Element? {
        if i < self.count && i >= 0 {
            return self[i]
        } else {
            return nil
        }
    }
}