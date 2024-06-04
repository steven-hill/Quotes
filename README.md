# Quotes

## A SwiftUI app that allows users to record their thoughts on a quote daily. Each day a new quote is displayed via the [Zen Quotes API](https://zenquotes.io/). 

- This app was written in Swift 5.9, on Xcode 15.2.
- The deployment target is iOS 17.2.
- The app displays a new quote every day via the API in the 'Home' tab. The user can then choose to share this quote with other apps or reflect on the quote and save their thoughts/feelings.
- Quotes which have been reflected upon will be shown in the 'Saved' tab. The user is then able to view, edit or delete their reflection.
- In 'Settings' the user can configure a local notification to remind them to open the app each day to see a new quote (assuming the user has granted permission to receive notifications).
- The network code uses Swift concurrency.
- Persistence is achieved via Core Data. I was looking for an approach which separated Core Data from the rest of the app as much as possible, which ruled out using @FetchRequest in my app's views. For this purpose I wanted to try out Donny Wals' approach of using ObservableObject, the @Published property wrapper and NSFetchResultsController. You can read his article on it [here](https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/).
- The app includes some adaptations for different size classes and UI guidelines for iPad.
- Light and dark modes are supported.
