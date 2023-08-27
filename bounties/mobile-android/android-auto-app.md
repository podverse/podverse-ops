# Android Auto app

**CURRENTLY ASSIGNED TO @lovegaoshi**

[Github issue #1054](https://github.com/podverse/podverse-rn/issues/1054)

> Android Auto is our most popular feature request. We are offering $1,200 on completion after we can confirm that it works on Android Auto Capable vehicles in production.

## Requisites

- React Native (Javascript)
- Android (Java/Kotlin)

## Acceptance Criteria

### App Launch
    - Starting Podverse directly from Android Auto should display a list of the users subscribed podcasts.
    - Android Auto Podverse App should continue to work even when the phone is locked.

### Navigation

    The Android Auto App should consist of 3 Tabs.
    1. Podcast
        - A list of the user's subscribed podcasts
        - Selecting a Podcast should drill down to a Podcasts Episode List in reverse chronological order
        - Selecting an Episode should navigate the user to a Player Screen and start playing th episode from the last saved position. If no such position exists, it should just start from the beginning.
        - Display the podcast artwork and podcast title in each episode cell.
    2. Queue
        - A list of the user's queued episodes
        -  Selecting an Episode should navigate the user to a Player Screen and start playing th episode from the last saved position. If no such position exists, it should just start from the beginning.
    3. History
        - A list of played episodes regardless of completion status
        - Selecting an Episode should navigate the user to a Player Screen and start playing th episode from the last saved position. If no such position exists, it should just start from the beginning.

    The user should have a way to always go to the player screen from anywhere within the Android Auto Podverse App

### Player Screen
    - Play/Pause Action
    - Forward/Backwards Action
    - Skip/Restart Track Action
    - Images and Track Title need to changing between Chapters *(if chapters exist)
    - When player is dismissed, the history and queue ui needs to be updated to reflect latest history and queue state.


## Developer Notes

- The Android Auto App should only handle UI display. All player control functionality exists on the javascript side and should be ported in corresponding native functions to be called on user interaction with the Android Auto UI. 
See:\
https://github.com/podverse/podverse-rn/blob/develop/src/lib/carplay/PVCarPlay.ts\
https://github.com/podverse/podverse-rn/blob/develop/src/lib/carplay/PVCarPlay.android.ts\
https://github.com/podverse/podverse-rn/blob/develop/src/lib/carplay/helpers.ts

- The user should not need to start Podverse on their phone for the app to start up in Android Auto. We've ran into thread issues with the UI on the iOS CarPlay where the Android Auto App wouldn't load content until the phone app was launched too. This was resolved in iOS with some native changes specific to the launch process.


## i18n / internationalization

- The app currently has i18n support. The text strings displayed to Android Auto uses should use the same language files as the phone app. Our translations are crowdsourced thanks to [contributors to our Weblate](https://hosted.weblate.org/projects/podverse/).
