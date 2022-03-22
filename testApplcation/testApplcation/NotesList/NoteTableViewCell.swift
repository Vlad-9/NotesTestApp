//
//  NoteTableViewCell.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//

import UIKit

struct CellModel {
    var title: String?
    var text: NSAttributedString?
    var date: Date
    var image: UIImage?
}

class NoteTableViewCell: UITableViewCell {

    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 15)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12, weight: .light)
        dateLabel.textColor = .systemGray
        dateLabel.setContentHuggingPriority(.defaultHigh , for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh , for: .horizontal)

        descriptionLabel.textColor = .systemGray
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .light)
        descriptionLabel.setContentHuggingPriority(.defaultLow , for: .horizontal)
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow , for: .horizontal)

        NSLayoutConstraint.activate([
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -8),
            descriptionLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: CellModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        if model.text?.string == "" {
            self.descriptionLabel.text = "Нет описания"
            self.titleLabel.text = model.title
        }
        else if model.title == "" {
            self.titleLabel.text = model.text?.string
            self.descriptionLabel.text = ""

        } else { 
            self.titleLabel.text = model.title!
            self.descriptionLabel.text = model.text?.string
        }

        let view = UIImageView(image: model.image?.resized(to: CGSize(width: 40.0, height: 40.0)))

        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        self.accessoryView = view
        self.dateLabel.text = dateFormatter.string(from: model.date)

        }
}
