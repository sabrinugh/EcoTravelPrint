<h1>Eco-TravelPrint</h1>
<h2>A way to encourage users to keep track of their carbon emissions</h2>
<p>
  Eco-TravelPrint is an iOS-based applicatino implemented in Swift 5 in XCode Storyboard 15. It is a map-based app to allow users to find a navigational route from two given locations, and give an approximate carbon emission value for the journey. The carbon emimission is based on the JSON response of the Google Maps API request, and takes the distance of the journey and calculates the emissions on an average fuel efficiency of different vehicles specific to Europe and Ireland. This is due to the implementation of European green standards for motor vehicles, in particular with light-duty vehicles and public transport such as buses. 
</p>
<p>Although this app was created for an Irish user, it can be modified to suit other countries by adjusting the average carbon emissions based on motoro fuel efficienct of said countries. 
  The app has multiple package dependencies for functionality:
</p>
<li>Google Maps for iOS: https://console.cloud.google.com/marketplace/product/google/maps-ios-backend.googleapis.com</li>
<li>Google Places for iOS: https://developers.google.com/maps/documentation/places/ios-sdk</li>
<li>SwiftyJSON: https://github.com/SwiftyJSON/SwiftyJSON</li>
<li>Realm Database: https://github.com/realm/realm-swift</li>
<p>Although the project has AlamoFire included in its package dependencies, it was not used in the final implementation.</p>

<h3>How does it work?</h3>
<p>Eco-TravelPrint works as an iOS application wherein users can open the app, and input a name location for their current position, and their desired destination. Once this is input, they can select their preferred method of travel: driving, walking, cycling, or via public transit. If none of the four are chosen, then the app default selects driving as the means of travel.</p>
<p>If a user is unsure of the location name in particular, the app home screen features a Google Map where they can scroll and view the surrounding area for their target destination/current location.</p>
<p>Once both places are input, the user can then click the button to search for their navigation route. Simple.</p>
<p>The app should then display a pop-up screen highlighting the route in which they are to take. When time allows, a new unwind seque should be implemented to improve UX rather than manually clearing the view from the screen.</p>

<h2>How to run</h2>
<p>As this program was implemented in Swift 5 XCode 15 and the target deployment version at iOS 17, future iterations may have depreceated some functionality. If not, then the required software is Swift 5 and XCode 15 Storyboard.
When downloading/pulling this app, you must import the following packages and run it on an iOS 17 device. Using XCode's in-built package manager, you can easily import the packages from the following links:
  <li>SwiftyJSON: https://github.com/SwiftyJSON/SwiftyJSON</li>
  <li>Realm Database: https://github.com/realm/realm-swift</li>
  <li>Google Maps for iOS: https://github.com/googlemaps/ios-maps-sdk</li>
  <li>Google Places for iOS: https://github.com/googlemaps/ios-places-sdk</li>
Additionally, the AppDelegate.swift file should be modified to insert your own Google API key, which can be created via the Google Cloud console for your project (in this repo, I have used my own key but limited access to it which is not a good idea for security).
</p>

<h3>Issues</h3>
<p>Unsure if this is a personal issue running on my own device, but you may need to preload the Main.storyboard to ensure all outlets are connected in their corresponding Swift view controllers</p>

<h4>Hardware Used in Project</h4>
<li>Macbook Pro 2020 - memory issues</li>
<li>2TB WD Passport HHD</li>
