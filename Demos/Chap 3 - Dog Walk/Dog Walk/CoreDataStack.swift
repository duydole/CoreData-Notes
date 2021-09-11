//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Duy Đỗ on 04/09/2021.
//  Copyright © 2021 Razeware. All rights reserved.
//

import Foundation
import CoreData

/// Thằng này giống như wrapper của <NSPersistentContainer>
/// Chỉ public <ManagedContext> thôi, 3 thằng còn lại không public
class CoreDataStack {
  
  // MARK: Private
  
  /// modelName phải trùng với tên file .xcdatamodeld
  /// Nếu không sẽ báo lỗi khi load
  /// "Failed to load model named Dog Walk2"
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  /// Container of CoreData stack
  private lazy var persistentContainer: NSPersistentContainer = {
    
    /// Tạo persistentContainer with modelName
    let container = NSPersistentContainer(name: self.modelName)
  
    /// loadPersistentStore
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  /// managedContext
  lazy var managedContext: NSManagedObjectContext = {
    return self.persistentContainer.viewContext
  }()
  
  /// Save context when has changes
  public func saveContext () {
    guard managedContext.hasChanges else { return }
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Unresolved error \(error), \(error.userInfo)")
    }
  }
}
