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
	@IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var executionTimeTextField: UILabel!
	@IBOutlet weak var tweetsTable: UITableView!

	private var bindingHelper: TableViewBindingHelper<TweetViewModel>!

	var viewModel: TwitterSearchViewModel = {
		let searchService = TwitterSearchService()
		return TwitterSearchViewModel(searchService: searchService)
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		viewModel.searchText <~ searchTextField.rac_textSignal().toSignalProducer().assumeNoErrors().map { text in text as! String }

		DynamicProperty(object: searchActivityIndicator, keyPath: "hidden") <~ viewModel.isSearching.producer.map { !$0 }
		DynamicProperty(object: executionTimeTextField, keyPath: "text") <~ viewModel.queryExecutionTime
		DynamicProperty(object: tweetsTable, keyPath: "alpha") <~ viewModel.loadingAlpha

		bindingHelper = TableViewBindingHelper(tableView: tweetsTable, sourceSignal: viewModel.tweets.producer, nibName: "TweetCell", selectionCommand: nil)
	}
}
