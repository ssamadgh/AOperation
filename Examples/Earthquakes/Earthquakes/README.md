# Earthquakes

## About
**Earthquakes** is a simple app that shows last earthquakes of the world

## How to Run
Run the application and pull to refresh the tableview.

## How it works
### EarthquakesTableViewController
1. The app first checks availability of coredata and shows an alert to user if the availability failed. The app retries this task if user selects try again button.
2. Then by pulling to refresh tableview the app fetches earthquake data, parses and stores them to the Core Data and reloads tableview using **FetchedResultsController**.

### EarthquakeTableViewController

The app uses **LocationCondition** to check users location requesting is available and gets user location using **LocationOperation** to show distance of the user's location to the place of the earthquake.

The app used **MutuallyExclusive<UIViewController>()** for showing alerts and viewcontrollers to prevent from multiple presentation of them at the same time.
