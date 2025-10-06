//
//  DefaultFavoritesStore.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation
import CoreData

actor DefaultFavoritesStore: FavoritesStore {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func favoriteIds() async -> Set<Int> {
        let container = await MainActor.run { coreDataStack.persistentContainer }
        let context = container.newBackgroundContext()
        return await withCheckedContinuation { continuation in
            context.perform {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEntity")
                request.resultType = .dictionaryResultType
                request.propertiesToFetch = ["id"]
                do {
                    let results = try context.fetch(request) as? [[String: Any]] ?? []
                    let ids = Set(results.compactMap { ($0["id"] as? NSNumber)?.intValue })
                    continuation.resume(returning: ids)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    func isFavorite(id: Int) async -> Bool {
        let container = await MainActor.run { coreDataStack.persistentContainer }
        let context = container.newBackgroundContext()
        return await withCheckedContinuation { continuation in
            context.perform {
                let request = NSFetchRequest<NSManagedObject>(entityName: "FavoriteEntity")
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %lld", Int64(id))
                do {
                    let exists = try context.count(for: request) > 0
                    continuation.resume(returning: exists)
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    func add(id: Int) async {
        let container = await MainActor.run { coreDataStack.persistentContainer }
        let context = container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "FavoriteEntity")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %lld", Int64(id))
            do {
                let exists = try context.count(for: request) > 0
                if !exists {
                    let entity = NSEntityDescription.insertNewObject(forEntityName: "FavoriteEntity", into: context)
                    entity.setValue(Int64(id), forKey: "id")
                    entity.setValue(Date(), forKey: "createdAt")
                    try context.save()
                    NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
                }
            } catch {
            }
        }
    }

    func remove(id: Int) async {
        let container = await MainActor.run { coreDataStack.persistentContainer }
        let context = container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "FavoriteEntity")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "id == %lld", Int64(id))
            do {
                if let obj = try context.fetch(request).first {
                    context.delete(obj)
                    try context.save()
                    NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
                }
            } catch {
            }
        }
    }
}
