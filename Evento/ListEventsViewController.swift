//
//  ListEventsViewController.swift
//  Evento
//
//  Created by Aleksey Bykhun on 11.01.2018.
//  Copyright © 2018 Aleksey Bykhun. All rights reserved.
//

import UIKit
import FacebookCore
import UserNotifications
import SafariServices
import BrightFutures

class ListEventsViewController: UIViewController {
    static let cellIdentifier = "EventTableViewCell"
    
    
    var loadingFuture: Future<[Event], NSError>? = nil
    var _connection: SocialConnection! = GraphConnector()
    func getConnection() -> SocialConnection {
        return _connection as SocialConnection
    }
   
    var events: [Event] = [] {
        didSet {
            normalEvents = events.filter{ !$0.pinned }
            pinnedEvents = events.filter{ $0.pinned }
        }
    }
    
    private var _pinned: [Event] = []
    
    func setData(events: [Event]) {
        self.events = events.map{ event in
            var eventCopy = event
            
            if _pinned.contains(where: { $0.id == eventCopy.id }) {
                eventCopy.pinned = true
            }
            
            return eventCopy
        }
    }
    
    var normalEvents: [Event] = []
    var pinnedEvents: [Event] = []
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var notificationCenter: UNUserNotificationCenter = .current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        notificationCenter.delegate = self
        
        setupRefreshControl()
        loadData()
        
        registerForPushNotifications {
            granted in
            print("Notification permission granted: \(granted)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        tableView.addSubview(refreshControl)
    }
    
    
}

extension ListEventsViewController: UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications(completion: @escaping (_ granted: Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            guard granted else { return }
            self.getNotificationSettings()
            print("Permission granted: \(granted)")
            
            completion(granted)
        }
    }
    
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            print("Status: OK")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    
    func buildNotificationContent(body: String, title: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title != "" ? title : "EVENTO"
        content.body = body
        content.sound = .default()
        return content
    }
    
    func buildNotificationTrigger(at date: Date) -> UNNotificationTrigger {
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        return trigger
    }
    
    func buildNotificationIdentifier(from title: String) -> String {
        let titleStripWhiteSpace = title.trimmingCharacters(in: CharacterSet.whitespaces)
        let identifier = "EventLocalNotificationWithTitle" + titleStripWhiteSpace
        print("notification identifier: \(identifier)")

        return identifier
    }
    
    func registerNotification(body: String, title: String,
                              date: Date) {
        
        let content = buildNotificationContent(body: body, title: title)
        let trigger = buildNotificationTrigger(at: date)
        let identifier = buildNotificationIdentifier(from: title)
        let nr = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add (nr) { error in
            if error != nil {
                print( "error " + String(describing: error) )
            }
        }
        
    }
    
    func registerNotification(for event: Event) {
        if (event.date > Date()) {
            registerNotification(
                body: event.getText(),
                title: event.name,
                date: event.date)
        
            registerNotification(
                body: event.name,
                title: "I will remind you \(event.getDateString()):",
                date: Date(timeIntervalSinceNow: 1))
        } else {
            registerNotification(
                body: "If you hurry, you can get there before it finishes! \(event.getLocation())",
                title: "Event started \(event.getDateString())!",
                date: Date(timeIntervalSinceNow: 1))
        }
        
    }
}

extension ListEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        
        if let url = URL(string: event.linkAddress) {
            openLink(url: url)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openLink(url: URL) {
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    @objc func pinEvent(sender: UIButton) {
        let eventID = sender.tag
        let eventIndex = events.index{ $0.id == eventID }
        
        guard let index = eventIndex else {
            return
        }
        
        let event = setPinned(at: index)
        registerNotification(for: event)
        
        tableView.reloadData()
    }
}

extension ListEventsViewController: UITableViewDataSource {
    func setPinned(at index: Int) -> Event {
        events[index].pinned = true
        
        let event = events[index]
        
        _pinned += [event]
        return event
    }
    
    @objc func loadData() {
        loadingFuture = nil
        
        let connection = getConnection()
        let events = connection.loadEvents()
        
        events.onSuccess { [weak self] events in
            print(events)
            
            self?.setData(events: events)
            self?.tableView?.reloadData()
        }
        events.onFailure { (error) in
            print("error loading events: \(error)")
        }
        
        events.onComplete { [weak self] event in
            self?.refreshControl.endRefreshing()
        }
        
        loadingFuture = events
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pinnedEvents.count
        } else {
            return normalEvents.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListEventsViewController.cellIdentifier, for: indexPath) as? EventTableViewCell else {
                fatalError("The dequeued cell is not an instance of EventTableViewCell.")
        }
        
        let event = (indexPath.section == 0)
            ? pinnedEvents[indexPath.row]
            : normalEvents[indexPath.row]
        
        event.pictureCached?.onSuccess {
            image in cell.picture.image = image
        }
        
        if event.pinned {
            cell.pinButton.isHidden = true
        } else {
            cell.pinButton.isHidden = false
            cell.pinButton.addTarget(self, action: #selector(pinEvent), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? EventTableViewCell else {
            fatalError("The dequeued cell is not an instance of EventTableViewCell.")
        }
        
        let event = (indexPath.section == 0)
            ? pinnedEvents[indexPath.row]
            : normalEvents[indexPath.row]
        
        print("\n\n event \n" + String(describing: event))
        cell.setData(from: event)
        
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? EventTableViewCell else {
            fatalError("The dequeued cell is not an instance of EventTableViewCell.")
        }
        
        cell.picture.image = nil
        cell.backgroundColor = .white
        cell.pinButton.isHidden = false
        
    }
}
