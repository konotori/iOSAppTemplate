import SwiftUI

@main
struct iOSAppTemplateApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
