# Quotes

## A SwiftUI app that allows users to record their thoughts on a quote daily. Each day a new quote is displayed via the [Zen Quotes API](https://zenquotes.io/). 

### ⚙️ Features
- The app displays a new quote every day via the API in the 'Home' tab. The user can then choose to share this quote with other apps or reflect on the quote and save their thoughts/feelings.
- Quotes which have been reflected upon will appear in the 'Saved' tab. The user can scroll through the list of their saved quotes or search by author or quote content. Each quote's reflection can be viewed or edited from here. Each quote can be deleted from the menu button or by swipe action.
- In the 'Settings' tab the user can change their notifications and appearance settings. The notification reminds them to open the app each day to see a new quote (assuming the user has granted permission to receive notifications). The user can switch between light, dark and system appearance.

### 🔍 Technical details
Overview:
  - This app is almost entirely SwiftUI. UIKit was used for the UIActivityViewController on iPad.
  - The deployment target is iOS 17.5+ and iPadOS 17.5+.
  - MVVM, Core Data and Swift concurrency.
  - iPhone and iPad are both supported.
  - The app supports different size classes, portrait and landscape orientation, and light, dark or system appearance.
  - XCTest is used for testing.

Networking:   
  - The network code uses Swift concurrency, and there is dependency injection for loose coupling and testability.
  - The network response is cached using NSCache.
  - Caching will avoid exceeding the API usage limit of 5 requests per 30 second period (among other benefits to the user experience and app performance).
  - I looked at various caching solutions such as NSCache, URLCache, and in-memory caching and persistent caching. An in-memory NSCache suits my case as I want the cache to be emptied when the app is terminated / the current session ends because a new quote is delivered daily by the API.

Persistence:
- Persistence of saved quotes is achieved via Core Data.
- I was looking for an approach which separated Core Data from the rest of the app as much as possible, which ruled out using @FetchRequest in my app's views. For this purpose I wanted to try out Donny Wals' approach of using ObservableObject, the @Published property wrapper and NSFetchedResultsController. You can read his article on it [here](https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/).
- The user's appearance setting is persisted by UserDefaults, and the user can change the appearance in the app's settings.
- If the user sets a new time for notifications that time will be saved to UserDefaults. 
  
Accessibility:
- There is support for VoiceOver and Dynamic Type.

### 🚧 Currently working on
- Improving the testability of the app.
- Adding to and improving the unit tests.
- Using Instruments to optimise app performance.

### 📲 Getting started
1. Clone the repo.
2. Open `Quotes.xcodeproj`.
3. Build and run.

### 📱 Screenshots

<p align="center">
  <img src="Simulator screenshots/Home screen - light mode.png" width="250"/>
  <img src="Simulator screenshots/Reflection screen - light mode.png" width="250" hspace="10"/>
  <br/>
  <img src="Simulator screenshots/Saved screen - light mode.png" width="250"/>
  <img src="Simulator screenshots/Settings screen - light mode.png" width="250" hspace="10"/>
</p>
