//
//  ViewController.swift
//  ReactiveTwitterSearch
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TwitterSearchViewController: UIViewController {

  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var searchAcitivyIndicator: UIActivityIndicatorView!
  @IBOutlet weak var executionTimeTextField: UILabel!
  @IBOutlet weak var tweetsTable: UITableView!
  
  private var bindingHelper: TableViewBindingHelper<TweetViewModel>!
  
  var viewModel: TwitterSearchViewModel = {
    let searchService = TwitterSearchService()
    return TwitterSearchViewModel(searchService: searchService)
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.searchText <~ searchTextField.rac_text
    searchAcitivyIndicator.rac_hidden <~ viewModel.isSearching.producer.map { !$0 }
    executionTimeTextField.rac_text  <~ viewModel.queryExecutionTime
    tweetsTable.rac_alpha <~ viewModel.isSearching.producer.map { $0 ? CGFloat(0.5) : CGFloat(1.0) }
    
    bindingHelper = TableViewBindingHelper(tableView: tweetsTable, sourceSignal: viewModel.tweets.producer, nibName: "TweetCell", selectionCommand: nil)
  }

  

}

