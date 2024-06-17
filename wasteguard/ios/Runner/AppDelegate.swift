import UIKit
import Flutter
import workmanager
import BackgroundTasks


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
    //UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)

  }

  func handleAppRefresh(task: BGAppRefreshTask) {
       // Schedule a new refresh task
       scheduleAppRefresh()

       // Perform the work associated with the task.
       print("Workmanager: background refresh task fired!")
       let queue = OperationQueue()
       queue.maxConcurrentOperationCount = 1

       // Create an operation that performs the actual work
       let operation = BlockOperation {
           // Your background task logic goes here
       }

       // Set the task's expiration handler
       task.expirationHandler = {
           // Handle the expiration of the task here.
           queue.cancelAllOperations()
       }

       // Submit the task to the operation queue
       queue.addOperation(operation)
   }

  // Schedule the background task
  func scheduleAppRefresh() {
      let request = BGAppRefreshTaskRequest(identifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh")
      request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now

      do {
          try BGTaskScheduler.shared.submit(request)
      } catch {
          print("Could not schedule app refresh: \(error)")
      }
  }
}


