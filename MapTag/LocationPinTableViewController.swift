//
//  LocationPinTableViewController.swift
//  MapTag
//
//  Created by Petar Lemajic on 10/24/18.
//  Copyright © 2018 Petar Lemajic. All rights reserved.
//

import UIKit
import MapKit

class LocationPinTableViewController: UITableViewController {
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    var resultSearchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultSearchController = UISearchController(searchResultsController: self)
        resultSearchController.searchResultsUpdater = self
    }
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
            (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
    
}

extension LocationPinTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
    
}

extension LocationPinTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        return cell
    }
    
}

extension LocationPinTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
}
