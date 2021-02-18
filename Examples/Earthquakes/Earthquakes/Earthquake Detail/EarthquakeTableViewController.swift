/*
  EarthquakeTableViewController.swift
  OperationPractice

  Created by Seyed Samad Gholamzadeh on 7/7/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     A static UITableViewController to display details of an earthquake
*/

import UIKit
import MapKit
import AOperation

class EarthquakeTableViewController: UITableViewController {
    // MARK: Properties
    
    var queue: AOperationQueue!
    var earthquake: Earthquake?
    var locationRequest: LocationOperation?
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    @IBOutlet var depthLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    //MARK: ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default all labels if there's no earthquake.
        guard let earthquake = earthquake else {
            nameLabel.text = ""
            magnitudeLabel.text = ""
            depthLabel.text = ""
            timeLabel.text = ""
            distanceLabel.text = ""
            
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
        map.region = MKCoordinateRegion(center: earthquake.coordinate, span: span)

        let annotation = MKPointAnnotation()
        annotation.coordinate = earthquake.coordinate
        map.addAnnotation(annotation)
        
        nameLabel.text = earthquake.name
        magnitudeLabel.text = Earthquake.magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude))
        depthLabel.text = Earthquake.depthFormatter.string(fromMeters: earthquake.depth)
        timeLabel.text = Earthquake.timestampFormatter.string(from: earthquake.timestamp)
        
		
        /*
             We can use a `LocationOperation` to retrieve the user's current locatioin.
             Once we have the location, we can compute how far they currently are
             from the epicenter of the earthquake.
         
             if this operation fails (ie, we are denied access to their location),
             then the text in the `UILabel` will remain as what it is defined to
             be in the storyboard.
        */
		let locationOperation = LocationOperation(accuracy: kCLLocationAccuracyKilometer).didFinish({ (result) in
			switch result {
			case .success(let location):
				if let earthquakeLocation = self.earthquake?.location {
					let distance = location.distance(from: earthquakeLocation)
					self.distanceLabel.text = Earthquake.distanceFormatter.string(fromMeters: distance)
				}
			default:
				break
			}
			self.locationRequest = nil

			})
		.add(to: queue)
        
        locationRequest = locationOperation
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // If the LocationOperation is still going on then cancel it.
        locationRequest?.cancel()
    }
    
	@IBAction func shareEarthquake(_ sender: UIBarButtonItem) {
		guard let earthquake = earthquake else { return }
		guard let url = URL(string: earthquake.webLink) else { return }
		
		let location = earthquake.location
		
		let items = [url, location] as [Any]
		
		/*
		We could present the share sheet manually, but by putting it inside
		an `Operation`, we can make it mutually exclusive with other operations
		that modify the view controller hierarchy.
		*/
		AOperationBlock { (continuation: @escaping () -> Void) in
			DispatchQueue.main.async {
				let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
				
				shareSheet.popoverPresentationController?.barButtonItem = sender
				shareSheet.completionWithItemsHandler = { (_, _, _, _) in
					// End the operation when the share sheet completes.
					continuation()
				}
				
				self.present(shareSheet, animated: true, completion: nil)
			}
		}
		
		/*
		Indicates that this operation modifies the View Controller hierarchy
		and is thus mutually exclusive.
		*/
		.conditions(MutuallyExclusive<UIViewController>())
		.add(to: queue)
	}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            // The user has tapped the "More Information" button.
            if let link = earthquake?.webLink, let url = URL(string: link) {
                //If we have a link, present the "More Information" dialog.
                let moreInformation = MoreInformationOperation(URL: url)
                
                queue?.addOperation(moreInformation)
            }
            else {
                // No link; present an alert.
                let alert = AlertOperation()
                alert.title = "No Information"
                alert.message = "No other information is available for this earthquake"
                queue?.addOperation(alert)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EarthquakeTableViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let earthquake = earthquake else { return nil }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        view = view ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        guard let pin = view else { return nil }
        
        switch earthquake.magnitude {
        case 0..<3 : pin.pinTintColor = UIColor.gray
        case 3..<4: pin.pinTintColor = UIColor.blue
        case 4..<5: pin.pinTintColor = UIColor.orange
        default: pin.pinTintColor = UIColor.red
        }
        
        pin.isEnabled = false
        
        return pin
    }
}
