//
//  FavoritesViewController.swift
//  Cosmos
//
//  Created by Samuel Yanez on 10/22/19.
//  Copyright © 2019 Samuel Yanez. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = dataSource
            tableView.delegate = self
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        }
    }
    
    /// Ativity indicator
     @IBOutlet var activityIndicatorView: UIView! {
         didSet {
             activityIndicatorView.isHidden = false
         }
     }
    
    /// Error view
     @IBOutlet var errorView: UIView! {
         didSet {
             errorView.isAccessibilityElement = true
             errorView.accessibilityLabel = FavoritesViewStrings.errorMessage.localized
             errorView.accessibilityTraits = .button
             errorView.accessibilityHint = "Tap to load the view one more time."
         }
     }
    
    /// Error label
    @IBOutlet var errorLabel: UILabel! {
        didSet {
            errorLabel.font = DynamicFont.shared.font(forTextStyle: .body)
            errorLabel.adjustsFontForContentSizeCategory = true
            errorLabel.text = FavoritesViewStrings.errorMessage.localized
        }
    }
    
    /// API Client
    lazy var client =  Configuration.isUITest ? MockClient() : CosmosClient()
    
    /// Data Source
    lazy var dataSource: FavoritesDataSource = {
        FavoritesDataSource(tableView: tableView)
    }()
    
    /// Favorites manager
    private lazy var favoritesManager: FavoritesManaging = {
        UserDefaultsFavoritesManager()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = FavoritesViewStrings.title.localized
        
        favoritesManager.getFavorites { [weak self] dates in
            self?.fetch(favorites: dates) {
                self?.activityIndicatorView.isHidden = true
            }
        }
    }
    
    // MARK: Table View
    
    @objc func handleRefreshControl() {
        favoritesManager.getFavorites { [weak self] dates in
            self?.fetch(favorites: dates) {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
     }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let apod = dataSource.element(at: selectedIndexPath)
                if let detailViewController = segue.destination as? DetailViewController {
                    detailViewController.viewModel = APODViewModel(apod: apod)
                }
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    // MARK: Networking
    
    func fetch(favorites: [Date], completion: (() -> Void)? = nil) {
        client.fetch(dates: favorites) { [weak self] result in
            switch result {
            case .failure:
                self?.tableView.isHidden = true
                self?.errorView.isHidden = false
            case .success(let apods):
                self?.dataSource.set(withCollection: apods)
                self?.tableView.isHidden = false
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
            completion?()
        }
    }
    
    @IBAction func didTapOnRefreshButton(_ sender: Any) {
        errorView.isHidden = true
        activityIndicatorView.isHidden = false
        favoritesManager.getFavorites { [weak self] dates in
            self?.fetch(favorites: dates) {
                self?.activityIndicatorView.isHidden = true
            }
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: -120), animated: true)
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        FavoritesCell.height
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .destructive, title: FavoritesViewStrings.remove.localized, handler: { _, _, completionHandler  in
            // TODO: Consider developing a notification system for changes to the favorites manager
            self.favoritesManager.removeFromFavorites(self.dataSource.element(at: indexPath).date)
            self.dataSource.removeElement(at: indexPath)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        })
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}
