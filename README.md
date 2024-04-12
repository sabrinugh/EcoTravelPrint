<h1>Eco-TravelPrint</h1>
<h2>A way to encourage users to keep track of their carbon emissions</h2>
<p>
  Eco-TravelPrint is an iOS-based applicatino implemented in Swift 5 in XCode Storyboard. It is a map-based app to allow users to find a navigational route from two given locations, and give an approximate carbon emission value for the journey. The carbon emimission is based on the JSON response of the Google Maps API request, and takes the distance of the journey and calculates the emissions on an average fuel efficiency of different vehicles specific to Europe and Ireland. This is due to the implementation of European green standards for motor vehicles, in particular with light-duty vehicles and public transport such as buses. 
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
<p>The app should then display a pop-up screen highlighting the route in which they are to take. </p>
