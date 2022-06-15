//
//  AnalyticsController.swift
//  AnalyticsApp
//
//  Created by Evgeny Mitko on 13/06/2022.
//

import Foundation
import UIKit
import BackgroundTasks

internal class AnalyticsController {
    
    
    internal static let shared: AnalyticsController = AnalyticsController(analyticsEventsService: AnalyticsEventsService(),
                                                                          networkService: NetworkService())
    
    private let analyticsEventsService: AnalyticsEventsService
    private let networkService: Networkable
    private let appBundleId: String
    private let systemVersion: String
    private var currentAppState: String = "unknown"
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        
    private var autoStateTrackEnabled: Bool = false

    private var uploadTimer: Timer?
    
    internal init(analyticsEventsService: AnalyticsEventsService, networkService: Networkable) {
        self.analyticsEventsService = analyticsEventsService
        self.networkService = networkService
        self.appBundleId = Bundle.main.bundleIdentifier ?? ""
        self.systemVersion = UIDevice.current.systemVersion
        self.configureAppStateTracking()
        configureBackgroundAnalyticsRequests()
    }
    
    private func configureBackgroundAnalyticsRequests() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: NetworkConst.BGTaskIdentifier, using: nil) { task in
            if let bgAppRefreshTaks = task as? BGAppRefreshTask {
                self.handleBGTask(bgAppRefreshTaks)
            }
        }
    }

    private func handleBGTask(_ task: BGAppRefreshTask) {
        scheduleAnalyticsRefresh()
        Task {
            await uploadAnalyticsIfNeeded()
            task.setTaskCompleted(success: true)
        }
    }
    
    private func scheduleAnalyticsRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: NetworkConst.BGTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: NetworkSettings.eventsBundlingDuration)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch (let error) {
            print("Could not schedule an app refresh: \(error)")
        }
    }
    
    private func startTimer() {
        guard uploadTimer == nil else { return }
        uploadTimer = Timer.scheduledTimer(timeInterval: NetworkSettings.eventsBundlingDuration, target: self, selector: #selector(triggerAnalyticsUpdate), userInfo: nil, repeats: true)
    }
    
    @objc private func triggerAnalyticsUpdate() {
        Task {
            await uploadAnalyticsIfNeeded()
        }
    }
    
    ///Function to immidiatley upload latest analytics events
    internal func uploadAnalyticsIfNeeded() async {
                let events = await self.analyticsEventsService.getLatestEvents()
                if !events.isEmpty {
                    print("Sending Analytics Events:")
                    await sendAnalytics(events: events)
                }
    }
    
    private func sendAnalytics(events: [AppEvent]) async {
        checkAppState()
        let batchUpdate = AnalyticsBatchUpdate(requestDate: Date().timeIntervalSince1970,
                                               bundleID: self.appBundleId,
                                               appState: self.currentAppState,
                                               systemVersion: self.systemVersion,
                                               events: events)
            do {
                let data = try JSONEncoder().encode(batchUpdate)
                try await networkService.sendRequest(data)
            } catch (let error) {
                    print("Error: \(error.localizedDescription)")
                    await analyticsEventsService.cacheEvents(events)
            }
    }
        
    private func checkAppState() {
        //UIApplications calls should happen on the main tread
        DispatchQueue.main.async {
            switch UIApplication.shared.applicationState {
            case .active:
                self.currentAppState = "active"
            case .inactive:
                self.currentAppState = "inactive"
            case .background:
                self.currentAppState = "background"
            @unknown default:
                self.currentAppState = "unknown"
            }
        }
    }
            
    private func configureAppStateTracking() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if autoStateTrackEnabled {
            addNewAppEvent(.stateTransition, eventName: "Transition to background")
        }
        scheduleAnalyticsRefresh()
    }
    
    @objc private func appDidEnterForeground() {
        if autoStateTrackEnabled {
            addNewAppEvent(.stateTransition, eventName: "Transition to foreground")
        }
    }
        
    ///Function to control automatic app state tracking
    internal func setAutoStateTrack(on: Bool) {
        autoStateTrackEnabled = on
    }
    
    ///Function to add new trackable event
    internal func addNewAppEvent(_ eventType: AppEventType, eventName: String) {
        let appEvent = AppEvent(type: eventType, name: eventName, date: Date().timeIntervalSince1970)
        Task {
            await analyticsEventsService.addEvent(appEvent)
        }
        startTimer()
    }
    
    ///Function too get a list of all trackable events that await sending to the server
    internal func getListOfAllEvents() async -> [AppEvent] {
        return await analyticsEventsService.getListOfAllEvents()
    }
    
    
}
