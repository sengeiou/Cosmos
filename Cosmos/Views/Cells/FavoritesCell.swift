//
//  FavoritesCell.swift
//  Cosmos
//
//  Created by Samuel Yanez on 10/22/19.
//  Copyright © 2019 Samuel Yanez. All rights reserved.
//

import UIKit

class FavoritesCell: UITableViewCell {

    /// Thumbnail image view
    @IBOutlet private var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.accessibilityIdentifier = FavoritesCellAccessibilityIdentifier.Image.thumbnailImageView
        }
    }
    
    /// Date label
    @IBOutlet private var dateLabel: UILabel! {
        didSet {
            dateLabel.accessibilityIdentifier = FavoritesCellAccessibilityIdentifier.Label.dateLabel
            dateLabel.font = DynamicFont.shared.font(forTextStyle: .footnote)
            dateLabel.adjustsFontForContentSizeCategory = false
        }
    }
    
    /// Title label
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.accessibilityIdentifier = FavoritesCellAccessibilityIdentifier.Label.titleLabel
            titleLabel.font = DynamicFont.shared.font(forTextStyle: .title3)
            titleLabel.adjustsFontForContentSizeCategory = false
        }
    }
    
    /// Explanation label
    @IBOutlet private var explanationLabel: UILabel! {
        didSet {
            explanationLabel.accessibilityIdentifier = FavoritesCellAccessibilityIdentifier.Label.explanationLabel
            explanationLabel.font = DynamicFont.shared.font(forTextStyle: .caption1)
            explanationLabel.adjustsFontForContentSizeCategory = false
            explanationLabel.isAccessibilityElement = false
        }
    }
    
    /// Placeholder image
    static let placeholderImage = UIImage(named: "Missing Image Placeholder")
    
    /// Cell height
    static let height: CGFloat = 140
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.roundCorners(radius: 5)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        thumbnailImageView.af_cancelImageRequest()
    }
    
    func update(with viewModel: ApodViewModel) {
        dateLabel.text = viewModel.date
        titleLabel.text = viewModel.title
        explanationLabel.text = viewModel.explanation
        updateImageView(with: viewModel.thumbnailUrl)
        updateAccessibilityAttributes(with: viewModel)
    }
}

extension FavoritesCell {
    private func updateImageView(with url: URL?) {
        guard let url = url else {
            thumbnailImageView.image = FavoritesCell.placeholderImage
            return
        }
        thumbnailImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.2)) { [weak self] data in
            guard data.response?.statusCode != 404 else {
                self?.thumbnailImageView.image = FavoritesCell.placeholderImage
                return
            }
        }
    }
}

// MARK: - Accesibility

extension FavoritesCell {
    private func updateAccessibilityAttributes(with viewModel: ApodViewModel) {
        isAccessibilityElement = true
        accessibilityLabel = "\(viewModel.preferredDate ?? viewModel.date). \(viewModel.title)"
        accessibilityHint = "Double tap to show more details."
    }
}