# Duck Clicker

**Package URL, for quick reference:** https://github.com/evgenyneu/keychain-swift.git

This repo contains the code for **Lecture 9: Data Persistence**.

We'll be building a clicker game, complete with a shop and password protection. Along the way, we'll use a few different data persistence techniques to make sure that game state is saved between launches:
* `UserDefaults` for the number of clicks
* SwiftData for purchased shop items
* Keychain for the password

We've implemented most of the game for you, but it's up to you to polish it up with data persistence. Here's a walkthrough of the steps you'll take to do so:

## Step 1: Use `UserDefaults` to store the number of clicks

The number of clicks is stored in `GameView.swift`. To save this using `UserDefaults`, all we need to do is swap out the `@State` property for an `@AppStorage` property, like this:

```swift
struct GameView: View {
    @AppStorage("clicks") var clicks = 0

    // ...
}
```

And that's it! To test it out, run your game, click the duck a few times, then click **Stop** in Xcode. When you run the game again, the number of clicks should be the same as when you left off.

> [!NOTE]
> It's not enough to just hit the home button - the system will often keep the app running (or suspended) in the background. You need to either hit **Stop** in Xcode or [force quit](https://support.apple.com/guide/iphone/quit-and-reopen-an-app-iph83bfec492/ios) the app to test out most forms of data persistence.

## Step 2: Set up the SwiftData model

Now, let's turn our attention to the shop. We'll start by telling SwiftData what it should store with a *model*.

When we create a model, we need to tell SwiftData what properties it should store, along with their types and any special constraints, much like a `CREATE TABLE` command in SQL. Luckily, SwiftData makes this easy for us by letting us define our model with a simple class. We've already done most of the work for you, so all you need to do is go to `ShopItem` and use the `@Model` macro, like this:

```swift
@Model
class ShopItem
```

You might notice that the `id` property is commented with a TODO saying to remove it. That's because SwiftData automatically sets a [persistent identifier](https://developer.apple.com/documentation/swiftdata/persistentmodel/persistentmodelid) for each instance we create, giving us `Identifiable` conformance for free! So, go ahead and remove the `id` property (as well as the `extension` that conforms `ShopItem` to `Identifiable`, if you'd like.)

## Step 3: Set up the model container

Now, we'll set up a model container -- that is, a central object that coordinates storing and retrieving persistent objects. To do this, add a `.modelContainer` modifier in `DuckClickerApp`'s body, as well as each of the `#Preview` blocks:

```swift
ContentView()
    .modelContainer(for: [ShopItem.self])
```

One more thing: let's add a few initial items to our shop when the app first launches. We'll trigger this process as soon as the model container loads when we launch our app. In `DuckClickerApp`, pass in a handler function to the `.modelContainer` modifier -- it'll get called when the container is ready:

```swift
ContentView()
    .modelContainer(for: [ShopItem.self]) { result in
        let container = try! result.get()
        try! container.mainContext.createInitialShopItems()
    }
```

This is all well and good, but we also need to actually implement the logic to create each shop item. We've laid out the structure for you in `ShopItem.swift`, under the `ModelContext` extension. Go ahead and fill `createShopItem` in:

```swift
func createShopItem(name: String, price: Int, clicksPerSecond: Int) throws {
    // See if there's already an item with the name
    let descriptor = FetchDescriptor<ShopItem>(
        predicate: #Predicate { $0.name == name }
    )
    
    let existingItems = try fetch(descriptor)

    // If there is, we exit early
    guard existingItems.isEmpty else {
        return
    }
    
    // Otherwise, we create the item and let the context know about it (which saves it)
    let item = ShopItem(name: name, price: price, clicksPerSecond: clicksPerSecond)
    insert(item)
}
```

At this point, you've set up all the plumbing for the shop. Take some time to look at the items we've put in there for you to start with -- if you'd like to add more, go for it!

## Step 4: Integrate SwiftData with the shop UI

It's time to integrate our work with SwiftData into the rest of the app. We've already started doing this with that `.modelContainer` modifier, but we now need to get the shop UI and the game logic to talk to SwiftData.

We'll start with the `GameView`, which already has an `@State` property that maintains a list of shop items. All we need to do is switch this to `@Query` so that it now reads from SwiftData:
```swift
@Query var shopItems: [SopItem]
```

We'll do the same thing in `ShopView`, but this time, we can tell it to sort by price:
```swift
@Query(sort: \ShopItem.price) var shopItems: [ShopItem]
```

Note that everything else in the views stays the same -- that's because SwiftData is doing all the heavy lifting for us. Go ahead and test it out - the shop should now be working!

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
    self.isAuthenticated = keychain.get(Self.passwordKey) == nil
}
```

Next, let's implement the `checkPassword` method, which will check the argument it receives with the actual password, and set `isAuthenticated` to true if it matches. We'll also have it return whether the password succeeded in general:

```swift
func checkPassword(password: String) -> Bool {
    if password == keychain.get(Self.passwordKey) {
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