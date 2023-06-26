# Android Auto app

[Github issue #1054](https://github.com/podverse/podverse-rn/issues/1054)

Android Auto is our most popular feature request.

## Requisites

React Native

Android

Java

Kotlin

## Bridge

While working on the Apple CarPlay app, we ran into issues with keeping a bridge active and connected between the phone and the auto device. CarPlay worked fine, until we locked the phone screen, then the connection ended. I forget the solution we implemented for it...but it involves a CarScene. I'm not sure if we ever truly fixed it because the Github issue is still open [#1650](https://github.com/podverse/podverse-rn/issues/1650).

## Bridge + Media Player

Podverse uses two different React Native player libraries for audio and video playback. Ideally the Android App will play both file types (both played as audio only?). If we do not have issues with a React Native to Android Auto bridge, then we should be able to use the existing player class function, which automatically handle audio or video playback.

## Navigation

- Podcasts
    - List all of the user's subscribed podcasts. On tap of a podcast, load the 
- Queue
    - Display the user's queue. On tap, the item should begin playing and be removed from the queue.
- History
    - Display the user's history. On tap, the item should begin playing.
- Now Playing (Player)
    - Tap to display the Now Playing screen. 

## Load podcast and episode data

- Load all subscribed podcasts for user. First show a loading spinner / table cell, then load the subscribed podcast data from local storage, then make a request to the Podverse API for the latest podcast data for that user, then reload the screen. Display the podcast artwork and podcast title in each table cell. On tap of a cell, load the Podcast screen, with a list of all the episodes of the podcast in reverse chronological order. On tap of an episode table cell, play the episode.

## Queue

- Load the user's queue. On tap of a queue item, start playing the item, then reload the queue screen with the updated queue items.

## History

- Load the user's history. On tap of a history item, start playing the item, then reload the history screen with the updated history items (maybe we don't need to reload?).

## Player controls

- Play/Pause - on press, save the current playback position to server
- Time Jumps - back 10 seconds, forward 30 seconds
- Previous/Skip - if there is a chapter ahead of the current playback position, then skip to the next chapter, or go back to the previous chapter. If already on the first chapter, then go to the beginning of the episode at position 0 (we don't currently support going back to the previous track). If there are not more than 1 chapter (if there is only one chapter we ignore it), then pressing the skip button starts playing the next item in the player queue.

## Background processes

- Background interval handler - there is a playback increment (1 second) handler in a JS file that handles a variety of things like chapter info changes, clip end-time listening, saving the current playback position to server once per minute, and value-for-value streaming. The same functionality in this interval should run during player progress in Android Auto. Hopefully the bridge between the phone and Android Auto will allow the existing React Native handler to be called.

## i18n / internationalization

- The app currently has i18n support. The text strings displayed to Android Auto uses should use the same language files as the phone app. Our translations are crowdsourced thanks to [contributors to our Weblate](https://hosted.weblate.org/projects/podverse/).
