//
//  CoreDataManager.swift
//  Navigation
//
//  Created by Vadim on 04.08.2022.
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    var postArray: [LikePosts] = []

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: "PostModel", withExtension: "momd") else { fatalError() }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else { fatalError() }
        return managedObjectModel
    }()

    private var persistentStoreURL: NSURL {
        let storeName = "PostModel.sqlite"
        let fileManager = FileManager.default
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectoryURL.appendingPathComponent(storeName) as NSURL
    }

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.persistentStoreURL as URL, options: options)
        } catch {
            print(error.localizedDescription)
        }
        return persistentStoreCoordinator
    }()

    private lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()

    func savePost(index: Int, post: [Post]) {
        guard let favoritePost = NSEntityDescription.insertNewObject(forEntityName: "PostCoreDataModel", into: self.mainManagedObjectContext) as? PostCoreDataModel else { return }
        favoritePost.descript = post[index].description
        favoritePost.image = post[index].image
        favoritePost.title = post[index].title
        favoritePost.likes = Int16(post[index].likes)
        favoritePost.views = Int16(post[index].views)

        do {
            try mainManagedObjectContext.save()
        } catch {
            print("Ошибка сохранения")
        }

    }

    func getPost(callback: () -> ()) {
        CoreDataManager.shared.postArray.removeAll()
        let fetchRequest = PostCoreDataModel.fetchRequest()
        do {
            let posts = try mainManagedObjectContext.fetch(fetchRequest)
            for i in posts {
                let tempPost = LikePosts(title: i.title ?? "",
                                            description: i.descript ?? "",
                                            image: i.image ?? "",
                                            likes: Int(i.likes),
                                            views: Int(i.views))
                CoreDataManager.shared.postArray.append(tempPost)
            }


        } catch {
            print("Ошибка получения")
            fatalError()
        }
        callback()
    }






}
