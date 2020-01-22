//
//  ViewModel.swift
//  XKCD
//
//  Created by Yariv on 1/21/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import UIKit

// MARK: - View Model -

final class ComicsViewModel {
    enum Section {
        case main
    }

    typealias ComicsDataSource = UICollectionViewDiffableDataSource<Section, Comic>
    typealias ComicsSnapshot = NSDiffableDataSourceSnapshot<Section, Comic>

    private let service: XKCDServiceProtool
    private(set) var numberOfComics = 0

    init(service: XKCDServiceProtool = XKCDService()) {
        self.service = service
    }

    func setup(collectionView: UICollectionView, completion: @escaping (Result<ComicsDataSource, Error>) -> Void) {
        collectionView.register(ComicCell.self, forCellWithReuseIdentifier: ComicCell.reuseIdentifier)

        service.getLatestComic { result in
            do {
                let comic = try result.get()
                self.numberOfComics = comic.num

                let dataSource = ComicsDataSource(collectionView: collectionView) { (collectionView, indexPath, comic) in
                    collectionView.dequeueReusableCell(type: ComicCell.self, for: indexPath)?.configure(comic)
                }
                var snapshot = ComicsSnapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems([comic])
                dataSource.apply(snapshot, animatingDifferences: false) {
                    completion(.success(dataSource))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Extensions

private extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath) as? T
    }
}

private extension UICollectionViewCell {
    static var reuseIdentifier: String { String(describing: self) }
}
