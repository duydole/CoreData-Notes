/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

class ViewController: UIViewController {
  
  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
  var managedContext: NSManagedObjectContext!
  var currentDog: Dog?
  var walks: [Date] = []
  
  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    /// Tạo request để load thông tin của con chó tên Fido
    let dogName = "Fido"
    let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
    dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name),dogName)
    
    do {
      let results = try managedContext.fetch(dogFetch)
      if results.count > 0 {
        currentDog = results.first
      } else {
        
        /// Nếu chưa có con chó Fido => tạo => insert vào DB
        currentDog = Dog(context: managedContext)
        currentDog?.name = dogName
        try managedContext.save()
      }
    } catch let error as NSError {
      print("Fetch error: \(error) description: \(error.userInfo)")
    }
  }
  
  
  func testFetchRequest() {
    /// 5 cách tạo FetchRequest
    
    /// 1. FetchRequest = ClassToFetch + EntityDescription
    let fetchRequest1 = NSFetchRequest<Dog>()
    let entity = NSEntityDescription.entity(forEntityName: "Dog", in: managedContext)!
    fetchRequest1.entity = entity
    
    /// 2. Sao không có context ta
    let fetchRequest2 = NSFetchRequest<Dog>(entityName: "Dog")
    
    /// 3. Dùng API tự gen ra của XCode
    /// Rút gọn từ cách 2
    let fetchRequest3: NSFetchRequest<Dog> = Dog.fetchRequest()
    
    /// 4. Chưa gặp
    let fetchRequest4 = managedObjectModel.fetchRequestTemplate(forName: "venueFR")
    
    /// 5. Chưa gặp
    let fetchRequest5 = managedObjectModel.fetchRequestFromTemplate(withName: "venueFR", substitutionVariables: ["NAME" : "Vivi Bubble Tea"])
  }
}

// MARK: - IBActions
extension ViewController {
  
  @IBAction func add(_ sender: UIBarButtonItem) {
    
    /// Tạo WALK
    let walk = Walk(context: managedContext)
    walk.date = Date()
    
    /// Insert WALK vào DOG
    currentDog?.addToWalks(walk)
    
    /// Save Walk + Dog
    do {
      try managedContext.save()
      tableView.reloadData()
    }
    catch let error as NSError {
      print("Save error: \(error),description: \(error.userInfo)")
      tableView.reloadData()
    }
  }
}
// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentDog?.walks?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
    guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
          let walkDate = walk.date as Date? else {
      return cell
    }
    
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk,
          editingStyle == .delete else {
      return
    }
    
    
    managedContext.delete(walkToRemove)
    
    do { //3
      try managedContext.save()
      //4
      tableView.deleteRows(at: [indexPath], with: .automatic)
    } catch let error as NSError {
      print("Saving error: \(error),description: \(error.userInfo)")
    }
  }
}
