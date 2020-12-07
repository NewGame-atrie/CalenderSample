//
//  ViewController.swift
//  CalenderSample
//
//  Created by 北田菜穂 on 2020/12/08.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UIViewController, EKEventEditViewDelegate {
    
    //イベント作成画面用デリゲート
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // EventStoreを初期化
    let eventStore = EKEventStore()
    
    // 時間の取得
    var time = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    
                    self.showalert()
                }
            }
        })
    }
    
    //結果のアラート表示
    func showalert(){
        
//        if ##{
//            let alert = UIAlertController(title:"保存完了",message:"カレンダーに保存されました。", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title:"カレンダーアクセス",message:"カレンダーに保存するためには、\n設定>\nプライバシー>\nカレンダー\nでアクセスを許可して下さい。", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
    }
}
