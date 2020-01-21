//
//  ComicsViewController.swift
//  XKCD
//
//  Created by Yariv on 1/20/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import UIKit

final class RootNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let comicsViewController = storyboard?.instantiateViewController(identifier: "ComicsViewController", creator: {
            return ComicsViewController(coder: $0, viewModel: ComicsViewModel())
        })

        guard let viewController = comicsViewController else { return }
        viewControllers = [viewController]
    }
}

// MARK: View Model

extension UICollectionViewCell {
    static var cellIdentifier: String { String(describing: self) }
}

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
        service.getLatestComic { result in
            do {
                self.numberOfComics = try result.map { $0.num }.get()

                let dataSource = ComicsDataSource(collectionView: collectionView) { (collectionView, indexPath, comic) in
                    collectionView.dequeueReusableCell(type: ComicCell.self, for: indexPath)?.configure(comic)
                }
                var snapshot = ComicsSnapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems([try result.get()])
                dataSource.apply(snapshot, animatingDifferences: false) {
                    completion(.success(dataSource))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: View

final class ComicCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var altLabel: UILabel!

    func configure(_ comic: Comic) -> Self {
        titleLabel.text = comic.title
        numberLabel.text = "\(comic.num)"
        //altLabel.text = comic.alt
        return self
    }
}

final class ComicsViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    private let viewModel: ComicsViewModel
    private var numberOfComics = 0

    required init?(coder: NSCoder, viewModel: ComicsViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        self.viewModel = ComicsViewModel()
        super.init(coder: coder)
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


extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withReuseIdentifier: type.cellIdentifier, for: indexPath) as? T
    }
}
