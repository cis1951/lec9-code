# Duck Clicker

**Package URL, for quick reference:** https://github.com/evgenyneu/keychain-swift.git

This repo contains the code for **Lecture 9: Data Persistence**.

We'll be building a clicker game, complete with a shop and password protection. Along the way, we'll use a few different data persistence techniques to make sure that game state is saved between launches:
* `UserDefaults` for the number of clicks
* Core Data for purchased shop items
* Keychain for the password

We've implemented most of the game for you, but it's up to you to polish it up with data persistence. Here's a walkthrough of the steps you'll take to do so:

## Step 1: Use `UserDefaults` to store the number of clicks

The number of clicks is stored in `GameView.swift`. To save this using `UserDefaults`, all we need to do is swap out the `@State` property for an `@AppStorage` property, like this:

```swift
struct GameView: View {
    @AppStoraage("clicks") var clicks = 0

    // ...
}
```

And that's it! To test it out, run your game, click the duck a few times, then click **Stop** in Xcode. When you run the game again, the number of clicks should be the same as when you left off.

> [!NOTE]
> It's not enough to just hit the home button - the system will often keep the app running (or suspended) in the background. You need to either hit **Stop** in Xcode or [force quit](https://support.apple.com/guide/iphone/quit-and-reopen-an-app-iph83bfec492/ios) the app to test out most forms of data persistence.

## Step 2: Set up the Core Data model

Now, let's set up Core Data to store the shop items. We'll start by telling Core Data what it should store with a *model file*. Go ahead and create one:
1. Go to **File > New > File...**, or create a new file by right clicking on the left sidebar
2. Scroll down to the **Core Data** section, then choose **Data Model**.
3. Name the file `Model`, then click **Create**.

Let's now create an entity to represent our shop items. Open up the data model, then click **Add Entity** and name it `ShopItem`. Select the new `ShopItem` entity, then under the Attributes section, add these four properties:
* `name` - String
* `price` - Integer 64
* `quantity` - Integer 64
* `clicksPerSecond` - Integer 64

Next, click on each of the 3 integer attributes. On the right panel, uncheck the **Optional** checkbox. This will make sure we don't have to deal with any of these attributes being `nil`.

If you try to compile the project now, you'll get an error because `ShopItem` is duplicated. That's because Core Data generates a `ShopItem` class for us, complete with properties and a conformance to `Identifiable`. This means that we don't need the `ShopItemStub` file anymore - **go ahead and delete it** before moving on.

## Step 3: Set up the Core Data stack

Now, we'll set up a Core Data stack -- that is, a central object we'll use to communicate with Core Data. Since we're using Core Data to store our shop items, we'll put this logic in the `ShopViewModel`. We'll start by adding a `persistentContainer` property to our view model:

```swift
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores { _, error in
        if let error {
            // This is probably not a good idea for an actual production app
            fatalError("Oh no! \(error.localizedDescription)")
        }
    }
    
    return container
}()
```

We'll also need a method we can call to save any changes we've made. Add this method to the `ShopViewModel`:

```swift
func save() {
    // Only save if there are changes
    guard persistentContainer.viewContext.hasChanges else {
        return
    }
    
    do {
        try persistentContainer.viewContext.save()
    } catch {
        print("Oh no, couldn't save! \(error)")
    }
}
```

One final thing: let's add a few initial items to our shop when the app first launches. To do that, we'll first set up a `createShopItem` method, which will create a single shop item if it doesn't already exist:

```swift
func createShopItem(name: String, price: Int, clicksPerSecond: Int) throws {
    let request = ShopItem.fetchRequest()
    request.predicate = NSPredicate(format: "name == %@", name)
    
    let results = try persistentContainer.viewContext.fetch(request)
    guard results.isEmpty else { return }
    
    let item = ShopItem(context: persistentContainer.viewContext)
    item.name = name
    item.price = Int64(price)
    item.clicksPerSecond = Int64(clicksPerSecond)
}
```

Now, we'll make another method called `createInitialShopItems`, which will use the method we just made to create our initial items:

```swift
func createInitialShopItems() {
    do {
        try createShopItem(name: "Finger", price: 10, clicksPerSecond: 1)
        try createShopItem(name: "I am rich", price: 1000000000, clicksPerSecond: 100000000)
        
        save()
    } catch {
        print("Couldn't create shop items: \(error)")
    }
}
```

We've put a few items in there for you to start with, but feel free to add as many as you want!

## Step 4: Integrate Core Data with the shop

It's time to integrate our work with Core Data into the rest of the app. We'll start at the very root of the app -- `DuckClickerApp`. First, we'll tell SwiftUI about our Core Data database by passing it a `managedObjectContext`:

```swift
ContentView()
    .environment(\.managedObjectContext, viewModel.persistentContainer.viewContext)
    .environmentObject(ShopViewModel.shared)
    .environmentObject(PasswordViewModel.shared)
```

Next, we'll make sure that our shop items are created when the app launches. We can do this with `.onAppear`:

```swift
ContentView()
    .environment(\.managedObjectContext, ShopViewModel.shared.persistentContainer.viewContext)
    .environmentObject(ShopViewModel.shared)
    .environmentObject(PasswordViewModel.shared)
    .onAppear {
        ShopViewModel.shared.createInitialShopItems()
    }
```

Lastly, we'll tell *both* `ShopView` and `GameView` to fetch and store shop items from our Core Data database, rather than using the stubs we had before. Both views contain a property that looks like this:

```swift
@State var shopItems: [ShopItem] = []
```

Go ahead and replace it with this:

```swift
@FetchRequest(sortDescriptors: []) var shopItems: FetchedResults<ShopItem>
```

Note that everything else in the views stays the same -- that's because Core Data is doing all the heavy lifting for us! There is, however, one final thing we have to do. In `ShopView`, we need to make it so that when you buy an item, we tell Core Data to save its changes:

```swift
Button {
    item.quantity += 1
    clicks -= Int(item.price)
    shopViewModel.save()
} label: {
    // ...
}
.disabled(clicks < item.price)
.tint(.primary)
```

Go ahead and test it out - the shop should now be working!

## Step 5: Install KeychainSwift

For our last few steps, we'll use a third-party library called [KeychainSwift](https://github.com/evgenyneu/keychain-swift.git) to store the password. To install it, go to **File > Add Package Dependencies...** in the menu bar. Then, in the search bar that appears, paste this URL:

```
https://github.com/evgenyneu/keychain-swift.git
```

Select the `keychain-swift` package, then click **Add Package**. When prompted, make sure that KeychainSwift is being added to the **Duck Clicker** package, then proceed. Xcode should download and add the library automatically to your project!

## Step 6: Use KeychainSwift to store the password

For our final step, we'll fill in `PasswordViewModel` using the library we just installed. First, go to `PasswordViewModel.swift`, then import `KeychainSwift`:

```swift
import SwiftUI
import KeychainSwift
```

Now, let's set up our keychain when `PasswordViewModel` is initialized. We'll also do a brief check to see if the user has a password -- if not, we'll set `isAuthenticated` to false, which will cause our game to display a password screen. Add a new property called `keychain` and fill in the `init()` block, like this:

```swift
let keychain: KeychainSwift

private init() {
    let keychain = KeychainSwift()
    
    self.keychain = keychain
    self.isAuthenticated = keychain.get("password") == nil
}
```

Next, let's implement the `checkPassword` method, which will check the argument it receives with the actual password, and set `isAuthenticated` to true if it matches. We'll also have it return whether the password succeeded in general:

```swift
func checkPassword(password: String) -> Bool {
    if password == keychain.get("password") {
        isAuthenticated = true
        return true
    }
    
    return false
}
```

Finally, fill in `setPassword` to set the password:

```swift
func setPassword(password: String) {
    keychain.set(password, forKey: "password")
}
```

`PasswordViewModel` should be complete! Test it out by opening the app, then setting a password from the key icon on the top. When you kill and relaunch the app, it should prompt you for the password!

> [!TIP]
> If you forget the password, delete the app from your device or simulator, then reinstall.

And that's it! Have fun clicking ducks with data persistence!

## Acknowledgements

Duck image obtained from https://swag.devrant.com