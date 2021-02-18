# TweetSeeker
## About
**TweetSeeker** is a simple app that fetches and shows tweets for the given twitter username.

## How to run

1. Create an account in [Twitter developer website](https://developer.twitter.com) and save the **APIKey** and **APISecretKey** that twitter gives in developer pannel in a safe place.
2. Run the app, select one of **Select a Version** viewcontroller rows.
3. Type a username on navigationbar textfield.
4. Inset the **APIKey** and **APISecretKey** you got in step **1** into the **Registeration** viewController and tap on **register** button.
5. **Registeration** viewController will be dismiss and tweets for entered username will appears.

## How it works

### Auhtorization
Receiving tweets for the given twitter username needs an authorization key.
So a condition is defined with a dependentOperation to check availablity of authorization key and request user to authorize app if authorization key is not available.

This conditon is added to the operation that needs authorization key to execute.
So this operation will not execute ever until user authorizes the app.

### Fetching Tweets
This step is implemented in two ways:

###  Using just AOperation

Operations are used to set delay on the queries come from user to avoid unecessary fetching, delivering text to fetch operation, fetching json data, Handling server errors and status codes, decoding received json data, and updating collection view 

### Using AOperation with Combine

Combine's functions are used to set a publisher on username textfield, set a delay on received text to avoid unecessary fetching and updating collection view.
Other works are handled by operations.

## ViewControllers

### RegisterationViewController
A viewController for requesting twitter Api key and Api Secret from user

### TweetsCollectionViewController
a collection view controller implemented to show fetched tweets using just operation

### TweetsModernCollectionViewController
a collection view controller implemented to show fetched tweets using operation and combine

## Operations and Conditions

### AuthorizationAvailableCondition
A condition that used to check and request for twitter authorization.
This condition uses **CheckAuthorizationOperation** as its dependentOperation.

### CheckAuthorizationOperation
An operation for checking twitter authorization status.

### RequestAuthorizationOperation
An operation that handles requesting twitter authorization

### StoringAuthorizationInfoOperation
An operation that gets authorization key as receivedValue and stors it in memory and published status of authoriaztion availability as result.

### ResultableServicesTaskOperation
A wrraper operation used to fetch json data of given URLRequest and decode it to a model of given type as result of operation.

### AuthorizedResultableServicesTaskOperation
A wrapper operation that added authorization key on **HTTPHeaderFields** of given URLRequest, and pass it to **ResultableServicesTaskOperation**.

### JSONDecoderOperation
An operation used to decode received data to the given type model

### ServicesErrorHandleOperation
An operation used to check if received HTTPURLResponse statusCode is in a valid domain or not

### FetchUserTimeLineOperation
A wrapper operation to create a URLRequest for fetching the given twitter username tweets.

### ImageFetchOperation
A wrapper operation that gets an image url and results image

### ImageGeneratorOperation
A simple operation that gets result of a URLSessionDataTaskOperation and results an image from the received data or fails if received value is failure.
