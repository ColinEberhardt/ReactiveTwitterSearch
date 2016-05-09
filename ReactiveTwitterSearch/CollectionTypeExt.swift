//
//  CollectionTypeExt.swift
//  ReactiveTwitterSearch
//
//  Created by Patrick Reynolds on 5/9/16.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

import Foundation

extension CollectionType where Generator.Element: Updateable {
    public func update() {
        for element in self {
            element.update()
        }
    }
}
