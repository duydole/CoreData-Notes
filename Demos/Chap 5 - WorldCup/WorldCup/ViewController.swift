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
  fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
  var coreDataStack: CoreDataStack!
  
  
  lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
    
    /// Tạo fetchRequest
    /// Note: Phải có sortDescriptor nếu không sẽ crash
    let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
    let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
    let nameSort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
    
    let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
    fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort] /// sort theo Section => trùng section thì sort theo Score => trùng score thì sort theo Name
    
    /// Wrap fetchRequest lại thành <NSFetchedResultsController>
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: coreDataStack.managedContext, /// để vô trong dùng trigger lệnh fetch
                                                              sectionNameKeyPath: #keyPath(Team.qualifyingZone),	/// key của Section => Để controller group lại
                                                              cacheName: "worldCup")
    fetchedResultsController.delegate = self
    
    return fetchedResultsController
  }()
  
  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try fetchedResultsController.performFetch()
    } catch let error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      addButton.isEnabled = true
    }
  }
}

// MARK: - Internal

extension ViewController {
  
  func configure(cell: UITableViewCell, for indexPath: IndexPath) {
    guard let cell = cell as? TeamCell else {
      return
    }
    
    let team = fetchedResultsController.object(at: indexPath)
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"
    if let imageName = team.imageName {
      cell.flagImageView.image = UIImage(named: imageName)
    }
    else {
      cell.flagImageView.image = nil
    }
  }
  
  @IBAction func addTeam(_ sender: Any) {
    let alertController = UIAlertController(title: "Secret Team",
                                            message: "Add a new team",
                                            preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Team Name"
    }
    alertController.addTextField { textField in
      textField.placeholder = "Qualifying Zone"
    }
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) {[unowned self] action in
      guard
        let nameTextField = alertController.textFields?.first,
        let zoneTextField = alertController.textFields?.last
      else {
        return
      }
      
      /// Create newTeam
      let newTeam = Team(context: self.coreDataStack.managedContext)
      newTeam.teamName = nameTextField.text
      newTeam.qualifyingZone = zoneTextField.text
      newTeam.imageName = "wenderland-flag"
      
      /// Save
      self.coreDataStack.saveContext()
    }
    alertController.addAction(saveAction)
    alertController.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel))
    present(alertController, animated: true)
  }
  
  
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = fetchedResultsController.sections?[section] else {
      return 0
      
    }
    return sectionInfo.numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
    configure(cell: cell, for: indexPath)
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections?[section]
    return sectionInfo?.name
  }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    /// Get object and update
    let team = fetchedResultsController.object(at: indexPath)
    team.wins = team.wins + 1
    
    /// Save
    coreDataStack.saveContext()
    
    /// Update UI
    //tableView.reloadData()
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ViewController: NSFetchedResultsControllerDelegate {

	/// Did Change Content
  func controllerDidChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.endUpdates()
  }
  
  /// Will Change Content
  func controllerWillChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  /// Notifiy object changed (insert/delete/update/move items)
  func controller(_ controller:NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .update:
      let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
      configure(cell: cell, for: indexPath!)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    }
  }
  
  /// Notify section changed (insert/delete/move section)
  func controller(_ controller:NSFetchedResultsController<NSFetchRequestResult>,
                  didChange sectionInfo: NSFetchedResultsSectionInfo,
                  atSectionIndex sectionIndex: Int,
                  for type: NSFetchedResultsChangeType) {
    let indexSet = IndexSet(integer: sectionIndex)
    switch type {
    case .insert:
      tableView.insertSections(indexSet, with: .automatic)
    case .delete:
      tableView.deleteSections(indexSet, with: .automatic)
    default: break
    }
  }
}
