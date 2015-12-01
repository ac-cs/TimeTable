//
//  ViewControllerTableDetail.swift
//  TimeTable
//
//  Created by Mason on 2015-11-24.
//  Copyright © 2015 Mason. All rights reserved.
//

import UIKit

class ViewControllerTableDetail: UIViewController {
    var toPass :Course?
    var currDate :NSDate?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseTiming: UILabel!
    @IBOutlet weak var courseCode: UILabel!
    @IBOutlet weak var courseExtra: UILabel!

    @IBAction func remindMeBtnPress(sender: UIButton) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.stringFromDate(currDate!)
        let dateFormatterTwo = NSDateFormatter()
        dateFormatterTwo.dateFormat = "h:mm a MM/dd/yy"
        let date = dateFormatterTwo.dateFromString((toPass?.startTime)! + " " + dateString)
        let notifyDate = date!.dateByAddingTimeInterval(-60*3)
        appDelegate.sendPushNotification(toPass!, nextClassTime: notifyDate)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // fill in course info
        courseName.text = toPass?.courseName
        courseTiming.text = (toPass?.startTime)! + " - " + (toPass?.endTime)!
        courseCode.text = toPass?.courseID
        courseExtra.text = "Room " + (toPass?.roomID)! + " with " + (toPass?.facultyFirst)! + " " + (toPass?.facultyLast)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}