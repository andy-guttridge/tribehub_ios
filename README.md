# TribeHub iOS

A native iOS app for the TribeHub family organiser, built using Swift and UIKit.
TribeHub iOS uses the [tribehub_drf](https://github.com/andy-guttridge/tribehub_drf) REST API for its backend.

# Future features
## High priority

- It was not possible to fully implement username and password autofill on the login view, due to requiring a paid Apple developer account to be able to use ['Associated Domains'](https://developer.apple.com/documentation/xcode/supporting-associated-domains). This would be a priority feature for a commerical version of the app.
- It is not currently possible to edit or delete a calendar event from the search results view, because Apple's searchController API presents a searchResultsController modally, which means the Edit button navigationItem is not shown. Implementing this feature would require some additional customisation of the search functionality, which was not possible due to time restrictions, but would be prioritised for a commercial version of the app.

## Credits
- Ideas for managing network requests using protocols from https://matteomanferdini.com/network-requests-rest-apis-ios-swift/
- Ideas for using model controllers to manage persistent data from https://code.tutsplus.com/tutorials/the-right-way-to-share-state-between-swift-view-controllers--cms-28474
- Article on how to use combine to observe changes to properties in a UIKit app from https://www.swiftbysundell.com/articles/published-properties-in-swift/
- Code for adding a loading spinner view adapted from https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening
- The technique for obtaining every day of a month from a Calender object is from https://www.hackingwithswift.com/example-code/uikit/how-to-use-uiactivityindicatorview-to-show-a-spinner-when-work-is-happening
- Code to create an image from a string is from https://stackoverflow.com/questions/51100121/how-to-generate-an-uiimage-from-custom-text-in-swift
** Do we still need imageFromString()? **
- The technique to extend UIImageView to make a rounded image is from https://stackoverflow.com/questions/28074679/how-to-set-image-in-circle-in-swift
- Code to make a grey scale copy of an image is from https://stackoverflow.com/questions/35959378/how-can-i-temporarily-grey-out-my-uiimage-in-swift
- Code to resize an image is from https://stackoverflow.com/questions/31966885/resize-uiimage-to-200x200pt-px
- The technique for using a custom dateDecodingStrategy with a DateFormatter matching the API's date format is from https://stackoverflow.com/questions/50847139/error-decoding-date-with-swift
