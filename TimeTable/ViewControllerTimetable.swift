//
//  ViewControllerTimetable.swift
//  TimeTable
//
//  Created by Mason on 2015-11-24.
//  Copyright © 2015 Mason. All rights reserved.
//

import UIKit
import Alamofire

class ViewControllerTimetable: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var timeTableData = [Course]()
    let textCellIdentifier = "ClassCell"
    var studentBarcode :String = ""
    var selectedCourse :Course?
    var url :String = "thing here"
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dateValChanged(sender: AnyObject) {
        sendHttpRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        studentBarcode = appDelegate.getBarcode()!
        sendHttpRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    TIMETABLE STUFF
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeTableData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = timeTableData[row].startTime + " - " + timeTableData[row].endTime + " " + timeTableData[row].courseName
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        
        selectedCourse = timeTableData[row]
        print(selectedCourse)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("tableDetailView") as! ViewControllerTableDetail
        vc.toPass = selectedCourse
        vc.currDate = datePicker.date
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func sendHttpRequest() {
        let realDate = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.stringFromDate(realDate)
        Alamofire.request(.GET, url+"=\(studentBarcode)&date=\(dateString)")
            .responseJSON{ response in
                print("got response")
                if let JSON = response.result.value as? [[String: AnyObject]] {
                    self.timeTableData = []
                    self.tableView.reloadData()
                    for course in JSON {
                        let resultCourseID = course["COURSE_ID"] as! String
                        let resultCourseSection = course["COURSE_SECTION"] as! String
                        let resultStartTime = course["COURSE_START_TIME"] as! String
                        let resultEndTime = course["COURSE_END_TIME"] as! String
                        let resultCourseName = course["COURSE_NAME"] as! String
                        let resultRoomID = course["ROOM_NAME"] as! String
                        let resultFacultyFirst = course["FACULTY_FIRST"] as! String
                        let resultFacultyLast = course["FACULTY_LAST"] as! String
                        let tempCourse = Course(courseID: resultCourseID, courseSection: resultCourseSection, startTime: resultStartTime, endTime: resultEndTime, courseName: resultCourseName, roomID: resultRoomID, facultyFirst: resultFacultyFirst, facultyLast: resultFacultyLast)
                        self.timeTableData.append(tempCourse)
                    }
                    self.tableView.reloadData()
                    print(self.timeTableData)
                } else {
                    
                }
        }
    }
}