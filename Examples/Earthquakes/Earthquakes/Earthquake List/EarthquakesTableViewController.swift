/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The code in this file loads the data store, updates the model, and displays data in the UI.
 */

import UIKit
import CoreData
import CloudKit
import AOperation

class EarthquakesTableViewController: UITableViewController {
    // MARK: Properties
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    let queue = AOperationQueue()
    
    // MARK: View Controller
    
	override func viewDidLoad() {
		super.viewDidLoad()
		LoadModelOperation()
			.retryOnFailure({ [unowned self] (numberOrRetries, error, retry) in
				let alert = AlertOperation()
				
				alert.title = "Unable to load database"
				
				alert.message = "An error occurred while loading the database. \(error.localizedDescription). Please try again later."
				
				// No custom action for this button.
				alert.addAction("Retry Later", style: .cancel) { _ in
					retry(false)
				}
				
				alert.addAction("Retry Now") { alertOperation in
					retry(true)
				}
				alert.add(to: self.queue)
				
			})
		.didFinish { (result) in
			switch result {
			case let .success(context):
				// Now that we have a context, build our `FetchedResultsController`.
				DispatchQueue.main.async {
					let request = NSFetchRequest<NSFetchRequestResult>(entityName: Earthquake.entityName)
					
					request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
					
					request.fetchLimit = 100
					
					let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
					
					self.fetchedResultsController = controller
					
					self.updateUI()
				}
				
			default:
				break
			}
		}
		.add(to: queue)
	}
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let indexPath = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]
        let numberOfOgjects =  section?.numberOfObjects
        return numberOfOgjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "earthquakeCell", for: indexPath) as! EarthquakeTableViewCell
        
        if let earthquake = fetchedResultsController?.object(at: indexPath) as? Earthquake {
            cell.configure(earthquake)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
         Instead of performing the segue directly, we can wrap it in a `BlockOperation`.
         This allows us to attach conditions to the operation. For example, you
         could make it so that you could only perform the segue if the network
         is reachable and you have access to the user's Photos library.
         
         If you decide to use this pattern in your apps, choose conditions that
         are sensible and do not place onerous requirements on the user.
         
         It's also worth noting that the Observer attached to the `BlockOperation`
         will cause the tableview row to be deselected automatically if the
         `Operation` fails.
         
         You may choose to add your own observer to introspect the errors reported
         as the operation finishes. Doing so would allow you to present a message
         to the user about why you were unable to perform the requested action.
         */
        
        AOperationBlock {
            self.performSegue(withIdentifier: "showEarthquake", sender: nil)
        }
        .conditions(MutuallyExclusive<UIViewController>())
		.didFinish { (result) in
            /*
             If the operation errored (ex: a condition failed) then the segue
             isn't going to happen. We shouldn't leave the row selected.
             */
			if result.error == nil {
                DispatchQueue.main.async {
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        }
		.add(to: queue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationVC = segue.destination as? UINavigationController,
            let detailVC = navigationVC.viewControllers.first as? EarthquakeTableViewController else {
                return
        }
        detailVC.queue = queue
        
        if let indexPath = tableView.indexPathForSelectedRow {
            detailVC.earthquake = fetchedResultsController?.object(at: indexPath) as? Earthquake
        }
    }
    
    @IBAction func startRefreshing(_ sender: UIRefreshControl) {
        getEarthquakes()
    }
    
    fileprivate func getEarthquakes(_ userInitiated: Bool = true) {
        if let context = fetchedResultsController?.managedObjectContext {

			GetEarthquakesOperation(context: context)
				.didFinish { (_) in
					self.refreshControl?.endRefreshing()
					self.updateUI()
				}.add(to: queue)
			
        }
        else {
            /*
             We don't have a context to operate on, so wait a bit and just make
             the refresh control end.
             */
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    fileprivate func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
        
        tableView.reloadData()
    }
    
}

