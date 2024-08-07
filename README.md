# Quotes

## A SwiftUI app that allows users to record their thoughts on a quote daily. Each day a new quote is displayed via the [Zen Quotes API](https://zenquotes.io/). 

### Features
- The app displays a new quote every day via the API in the 'Home' tab. The user can then choose to share this quote with other apps or reflect on the quote and save their thoughts/feelings.
- Quotes which have been reflected upon will be shown in the 'Saved' tab. The user is then able to view, edit or delete any of them.
- In the 'Settings' tab the user can configure a local notification to remind them to open the app each day to see a new quote (assuming the user has granted permission to receive notifications).

### Technical details
- This app was written in Swift 5.9, on Xcode 15.4.
- Almost entirely SwiftUI. UIKit was used for the UIActivityViewController on iPad.
- The deployment target is iOS 17.5.
- MVVM, Core Data and Swift concurrency.
- The network code uses Swift concurrency, and there is dependency injection for loose coupling and testability.
- Persistence is achieved via Core Data. I was looking for an approach which separated Core Data from the rest of the app as much as possible, which ruled out using @FetchRequest in my app's views. For this purpose I wanted to try out Donny Wals' approach of using ObservableObject, the @Published property wrapper and NSFetchedResultsController. You can read his article on it [here](https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/).
- iPhone and iPad are both supported.
- The app includes code to support different size classes, portrait and landscape orientation, and light and dark mode.

### Currently working on
- Adding unit tests.

### Coming soon
- Improve the accessibility experience.

### Screenshots (showing light and dark mode on iPhone)

<img src="https://github.com/steven-hill/Quotes/blob/f808d4faa373cb53aba8c062e2b12756165d853c/Simulator%20screenshots/Home%20screen%20(iPhone%20-%20light%20mode).png" width="275" height="575" alt="Home screen in light mode on iPhone"> 
<img src="https://github.com/steven-hill/Quotes/blob/f808d4faa373cb53aba8c062e2b12756165d853c/Simulator%20screenshots/Home%20screen%20(iPhone%20-%20dark%20mode).png" width="275" height="575" alt="Home screen in dark mode on iPhone">
<img src="https://github.com/steven-hill/Quotes/blob/f808d4faa373cb53aba8c062e2b12756165d853c/Simulator%20screenshots/Reflection%20sheet%20(iPhone%20-%20light%20mode).png" width="275" height="575" alt="Reflection sheet in light mode on iPhone">
<img src="https://github.com/steven-hill/Quotes/blob/f9e6502cf6d6d5b77af6650291f3ff285fc19ed5/Saved%20screen%20(iPhone%20-%20dark%20mode).png" width="275" height="575" alt="Saved screen in dark mode on iPhone">
<img src="https://github.com/steven-hill/Quotes/blob/f9e6502cf6d6d5b77af6650291f3ff285fc19ed5/Settings%20sceen%20(iPhone%20-%20light%20mode).png" width="275" height="575" alt="Settings screen in light mode on iPhone">
