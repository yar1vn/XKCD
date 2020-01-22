//
//  ViewModel.swift
//  XKCD
//
//  Created by Yariv on 1/21/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import UIKit

// MARK: - View Model -

final class ComicsViewModel: NSObject {
    private let service: XKCDServiceProtool
    private(set) var maximumNumberOfComics = 0
    private var comics: [Comic] = []

    init(service: XKCDServiceProtool = XKCDService()) {
        self.service = service
    }

    func setup(collectionView: UICollectionView, completion: @escaping (Result<Void, Error>) -> Void) {
        collectionView.dataSource = self
        collectionView.register(ComicCell.self, forCellWithReuseIdentifier: ComicCell.reuseIdentifier)

        service.getLatestComic { [weak self] result in
            guard let self = self else { return }

            do {
                let comic = try result.get()
                self.maximumNumberOfComics = comic.num // latest comic num is the max
                self.comics = [comic]
                
                DispatchQueue.main.async {
                    collectionView.reloadData()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension ComicsViewModel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comic = self.comics[indexPath.row]
        return collectionView.dequeueReusableCell(type: ComicCell.self, for: indexPath)?.configure(comic) ?? UICollectionViewCell()
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
