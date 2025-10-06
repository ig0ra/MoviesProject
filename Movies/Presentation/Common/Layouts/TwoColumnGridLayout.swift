//
//  TwoColumnGridLayout.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

enum TwoColumnGridLayout {
    static func make(
        estimatedItemHeight: CGFloat,
        itemSpacing: CGFloat,
        sectionInterGroupSpacing: CGFloat,
        sectionHorizontalInset: CGFloat,
        footerEstimatedHeight: CGFloat
    ) -> UICollectionViewCompositionalLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .estimated(estimatedItemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemSpacing, bottom: 0, trailing: itemSpacing)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(estimatedItemHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing,
                                                            leading: sectionHorizontalInset,
                                                            bottom: itemSpacing,
                                                            trailing: sectionHorizontalInset)
            section.interGroupSpacing = sectionInterGroupSpacing

            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(footerEstimatedHeight))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                     elementKind: UICollectionView.elementKindSectionFooter,
                                                                     alignment: .bottom)
            section.boundarySupplementaryItems = [footer]
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
