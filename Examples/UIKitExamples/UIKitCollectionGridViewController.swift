import UIKit
import SwiftUI
import PhaseShift

/// A UIKit-only example demonstrating frame-based modal presentation.
///
/// Displays a collection grid with 3 columns and 10 rows, presenting modals when items are tapped.
final class UIKitCollectionGridViewController: UIViewController {
    
    private enum Constants {
        static let itemsPerRow = 3
        static let numberOfRows = 10
        static let totalItems = itemsPerRow * numberOfRows
        static let itemSpacing: CGFloat = 16
        static let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    private var collectionView: UICollectionView!
    private var itemFrames: [Int: CGRect] = [:]
    private var selectedItemIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Collection"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.itemSpacing
        layout.minimumLineSpacing = Constants.itemSpacing
        layout.sectionInset = Constants.sectionInsets
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionGridCell.self, forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func presentModal(for index: Int) {
        guard let frame = itemFrames[index] else {
            return
        }
        
        selectedItemIndex = index
        
        let contentView = UIKitModalContentView(itemIndex: index)
        
        PhaseShiftPresentation.present(
            from: self,
            sourceFrame: frame,
            content: contentView
        )
    }
}

extension UIKitCollectionGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.totalItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionGridCell
        cell.configure(index: indexPath.item)
        return cell
    }
}

extension UIKitCollectionGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            updateFrame(for: cell, at: indexPath.item)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.presentModal(for: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateFrame(for: cell, at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        itemFrames.removeValue(forKey: indexPath.item)
    }
    
    private func updateFrame(for cell: UICollectionViewCell, at index: Int) {
        itemFrames[index] = cell.frameInWindow()
    }
}

extension UIKitCollectionGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = Constants.itemSpacing * CGFloat(Constants.itemsPerRow - 1)
        let totalInsets = Constants.sectionInsets.left + Constants.sectionInsets.right
        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let itemWidth = availableWidth / CGFloat(Constants.itemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

/// Collection view cell for grid items.
private final class CollectionGridCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(index: Int) {
        label.text = "\(index + 1)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
}

struct UIKitCollectionGridViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIKitCollectionGridViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
