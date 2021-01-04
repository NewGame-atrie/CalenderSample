//
//  ViewController.swift
//  CalenderSample
//
//  Created by 北田菜穂 on 2020/12/08.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UIViewController {
    
    // EventStoreを初期化
    let eventStore = EKEventStore()
    
    // 時間の取得
    var time = Date()
    
    lazy var table : UITableView = {
//        let displayWidth: CGFloat = self.view.frame.width
//        let displayHeight: CGFloat = self.view.frame.height
        
        let tv = UITableView(frame: self.view.bounds)
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
     var events : [EKEvent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Calender Events"
//        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        
        self.view.addSubview(self.table)
        
        let btn = UIButton(frame: CGRect(x: 0, y: 100, width: 150, height: 50))
        btn.setTitle("New Event", for: .normal)
        btn.addTarget(self, action: #selector(onPressBtnNew(_:)), for: .touchUpInside)
        btn.backgroundColor = .gray
        self.view.addSubview(btn)
        btn.center = self.view.center
        
        self.loadEvents()
    }
    
    @objc func onPressBtnNew(_ sender :Any){
        self.showNewEvent()
    }
    //カレンダーイベントの取得
    func loadEvents(){
        
        //clear stoed events
        self.events = []
        
        let calendar = Calendar.current
        
        var oneDateAgoCompoents = DateComponents()
        oneDateAgoCompoents.day = -1
        let to = calendar.date(byAdding: oneDateAgoCompoents, to: Date())
        
        var oneYearAgoCompoents = DateComponents()
        oneYearAgoCompoents.year = -1
        let from = calendar.date(byAdding: oneYearAgoCompoents, to: Date())
        
        var predicate : NSPredicate? = nil
        if let to = to , let from = from {
            predicate = eventStore.predicateForEvents(withStart: from, end: to, calendars: nil)
        }
        
        if let predicate = predicate {
            let events : [EKEvent] = eventStore.events(matching: predicate)
            
            for event in events {
                print("\(event.startDate) \(event.title)")
                self.events.append(event)
            }
        }
        
        self.events.sort(by: { (a,b) in
            let compare = a.startDate.compare(b.startDate)
            if compare == ComparisonResult.orderedDescending {
                return true
            }
            return false
        })
        self.table.reloadData()
        
    }
    
    func showNewEvent(){
        //iOSカレンダーへのアクセスを許可or拒否
        //許可の場合、イベント作成画面になる
        eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
            DispatchQueue.main.async {
                if granted && error == nil {
                    let event = EKEvent(eventStore: self.eventStore)
                    event.startDate = self.time
                    event.endDate = self.time
                    
                    let eventController = EKEventEditViewController()
                    eventController.event = event
                    eventController.eventStore = self.eventStore
                    eventController.editViewDelegate = self
                    self.present(eventController, animated: true, completion: nil)
                }
            }
        })
    }
    
    func showEditEvent(_ event : EKEvent){
        let eventController = EKEventEditViewController()
        eventController.event = event
        eventController.eventStore = self.eventStore
        eventController.editViewDelegate = self
        self.present(eventController, animated: true, completion: nil)
    }
}

extension ViewController : EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction){
        print("called:\(action)")
        
        switch action {
        case .canceled:
            break
        case .deleted:
            break
        case .saved:
            break
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
        
        if case .saved = action {
            let alert = UIAlertController(title:"保存完了",message:"カレンダーに保存されました。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.loadEvents()
        }
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let event = self.events[indexPath.row]
        self.showEditEvent(event)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let event = self.events[indexPath.row]
        
        if let title = event.title {
            cell.textLabel?.text = "\(title)"
        }
        
        if let date = event.startDate {
            cell.detailTextLabel?.text = "\(date)"
        }
        
        return cell
    }
    
    
}
