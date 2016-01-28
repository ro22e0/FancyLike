//
//  PublicationTableViewController.swift
//  FancyLike
//
//  Created by Ronaël Bajazet on 09/01/2016.
//  Copyright © 2016 Ro22e0. All rights reserved.
//

import UIKit

class PublicationTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    let downloader = MyDownloader(configuration: .defaultSessionConfiguration())
    lazy var publications = [Publication]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the reflesh control action
        refreshControl?.addTarget(self, action: "doRefresh:", forControlEvents: .ValueChanged)
        
        // Set ViewCell AutoLayout
        self.tableView.estimatedRowHeight = 600
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Load the sample publications data
        initializePublications()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Return data from file
    func getDataJsonFromFile(name: String) -> NSData {
        // Get file path
        let path = NSBundle.mainBundle().pathForResource(name, ofType: "json")!
        
        // Try to get data from reading file
        do {
            let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            return jsonData
        }
        catch {
            print("Get Json failed: \((error as NSError).localizedDescription)")
        }
        return NSData();
    }
    
    func checkInternet() {
        // Check network reachability
        let infos = Network.isReachable()
        if !infos.status {
            // Showing UIAlert
            let errorAlert = UIAlertView(title: "Error", message: infos.error, delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    func initializePublications() {
        self.checkInternet()
        self.loadPublications()
    }
    
    // Load the sample publication data
    func loadPublications() {
        // Try to get json from NSData
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(getDataJsonFromFile("data_test_ios"),
                options: NSJSONReadingOptions.MutableContainers) as? NSArray
            // Parse the json and create publications
            for data in jsonResult! {
                if let url = data["url"] as? String {
                    if let title = data["title"] as? String {
                        var description = data["description"] as? String
                        if description == nil {
                            description = ""
                        }
                        if let pub = Publication(imageUrl: url, title: title, description: description!) {
                            publications += [pub]
                          //  self.tableView.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Fetch failed: \((error as NSError).localizedDescription)")
        }
    }
    
    func loadImage(pub: Publication) {
        if pub.Task == nil {
            pub.Task = self.downloader.download(pub.ImageUrl) {
                (weak url) -> () in
                pub.Task = nil
                if url == nil {
                    return
                }
                let data = NSData(contentsOfURL: url)!
                let im = UIImage(data:data)
                pub.Image = im
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        } else {
            pub.Task.resume()
        }
    }
    
    // Display/Hide reload image button
    func errorOnLoadingImage(cell: PublicationTableViewCell, indexPath: NSIndexPath) {
        cell.reloadButton.tag = indexPath.row
        cell.reloadButton.enabled = true
        cell.reloadButton.hidden = false;
        cell.reloadButton.addTarget(self, action: "reloadImage:", forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return publications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Fetches the appropriate publication for the data source layout.
        let cell = tableView.dequeueReusableCellWithIdentifier("PublicationTableViewCell",
            forIndexPath: indexPath) as! PublicationTableViewCell
        
        let publication = publications[indexPath.row]
        
        // Configure the cell...
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        
        if let im = publication.Image {
            cell.imagePubView.image = im
        } else {
            if publication.Task == nil {
                cell.imageView!.image = nil
                publication.Task = self.downloader.download(publication.ImageUrl) {
//                    [weak self]
                    url in
//                    publication.Task = nil
                    if url == nil {
                        self.errorOnLoadingImage(cell, indexPath: indexPath)
                        return
                    }
                    let data = NSData(contentsOfURL: url)!
                    let im = UIImage(data:data)
                    publication.Image = im
                    cell.reloadButton.enabled = false
                    cell.reloadButton.hidden = true
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
                }
            }
        }
        
        cell.imagePubView.image = publication.Image
        cell.titlePubLabel.text = publication.Title
        cell.descriptionPubLabel.text = publication.Description
        cell.likeLabel.text = ""
        if (publication.Like > 0) {
            cell.likeLabel.text = String(publication.Like) + NSLocalizedString(" like", comment: "likelbl")
        }
        
        // Adding action like to the Like button
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: "addLike:", forControlEvents: .TouchUpInside)
        
        // Check image loading error
//        checkErrorOnLoadingImage(cell, indexPath: indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let publication = self.publications[indexPath.row]
        if let task = publication.Task {
            if task.state == .Running {
                task.cancel()
                publication.Task = nil
            }
        }
    }
    
    //    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        let cell = tableView.dequeueReusableCellWithIdentifier("PublicationTableViewCell",
    //            forIndexPath: indexPath) as! PublicationTableViewCell
    //        let v = cell.contentView
    //        let size = v.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    //        return size.height
    //    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Selectors
    
    func addLike(sender: UIButton) {
        publications[sender.tag].Like += 1
        self.tableView.reloadData()
    }
    
    func doRefresh(sender: AnyObject) {
        self.checkInternet()
        for pub in self.publications {
            self.loadImage(pub)
        }
            self.refreshControl?.endRefreshing()
    }
    
    func reloadImage(sender: UIButton) {
        self.checkInternet()
        let pub = self.publications[sender.tag]
        self.loadImage(pub)
    }
}