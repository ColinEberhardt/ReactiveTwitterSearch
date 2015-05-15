//
//  Util.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa

struct AssociationKey {
  static var bindingContext: UInt8 = 0
  static var hidden: UInt8 = 1
  static var alpha: UInt8 = 2
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafePointer<Void>, factory: ()->T) -> T {
  var associatedProperty = objc_getAssociatedObject(host, key) as? T
  
  if associatedProperty == nil {
    associatedProperty = factory()
    objc_setAssociatedObject(host, key, associatedProperty, UInt(OBJC_ASSOCIATION_RETAIN))
  }
  return associatedProperty!
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>, setter: T -> (), getter: () -> T) -> MutableProperty<T> {
  return lazyAssociatedProperty(host, key) {
    var property = MutableProperty<T>(getter())
    property.producer
      .start(next: {
        newValue in
        setter(newValue)
      })
    return property
  }
}

extension UIView {
  public var rac_alpha: MutableProperty<CGFloat> {
    return lazyMutableProperty(self, &AssociationKey.alpha, { self.alpha = $0 }, { self.alpha  })
  }
  
  public var rac_hidden: MutableProperty<Bool> {
    return lazyMutableProperty(self, &AssociationKey.hidden, { self.hidden = $0 }, { self.hidden  })
  }
}

extension UILabel {
  public var rac_text: MutableProperty<String> {
    return lazyAssociatedProperty(self, &AssociationKey.bindingContext) {
      var property = MutableProperty<String>(self.text ?? "")
      property.producer
        .start(next: {
          newValue in
          self.text = newValue
        })
      return property
    }
  }
}

extension UIImageView {
  public var rac_image: MutableProperty<UIImage?> {
    return lazyAssociatedProperty(self, &AssociationKey.bindingContext) {
      var property = MutableProperty<UIImage?>(self.image)
      property.producer
        .start(next: {
          newValue in
          self.image = newValue
        })
      return property
    }
  }
}

extension UITextField {
  public var rac_text: MutableProperty<String> {
    return lazyAssociatedProperty(self, &AssociationKey.bindingContext) {
      
      self.addTarget(self, action: "changed", forControlEvents: UIControlEvents.EditingChanged)
      
      var property = MutableProperty<String>(self.text ?? "")
      property.producer
        .start(next: {
          newValue in
          self.text = newValue
        })
      return property
    }
  }
  
  func changed() {
    rac_text.value = self.text
  }
}
