currently podverse-rn uses AsyncStorage for saving parsed RSS feeds / podcast data locally, but this can cause issues for users who are subscribed to many podcasts, as on Android AsyncStorage is limited to ~10MB.

Instead of saving parsed RSS feeds to AsyncStorage, we should save them to a different location as a static file type, and then retrieve and parse the data from the new location that does not have a storage limit.
