//
//  ComicsView.swift
//  XKCD
//
//  Created by Yariv on 1/20/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import UIKit

// MARK: - View -

// MARK: ViewController

final class ComicsViewController: UIViewController {
    private let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) in
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalWidth(0.2))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    })
    private let collectionView: UICollectionView
    private let viewModel: ComicsViewModel
    private var numberOfComics = 0

    // DI + Segue
    required init?(coder: NSCoder, viewModel: ComicsViewModel) {
        self.viewModel = viewModel
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ComicsViewModel()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }

    override func loadView() {
        view = collectionView
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.setup(collectionView: collectionView) { result in
            do {
                _ = try result.get()
            } catch {
                print(error)
            }
        }
    }
}

// MARK: Cell

final class ComicCell: UICollectionViewCell {
    let stackView = UIStackView()
    let titleLabel = UILabel()
    let numberLabel = UILabel()
    let altLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        [titleLabel, numberLabel].forEach(stackView.addArrangedSubview(_:))
    }

    func configure(_ comic: Comic) -> Self {
        contentView.backgroundColor = .lightGray

        titleLabel.text = comic.title
        numberLabel.text = "\(comic.num)"
        //altLabel.text = comic.alt
        return self
    }
}
