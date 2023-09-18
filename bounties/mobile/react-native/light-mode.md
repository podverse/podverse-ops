# Add light mode support and automatic theme detection

The foundations for light mode are already in place in the app, as we have a styles file that handles switching between light theme and dark theme, but we eventually stopped maintaining light mode because it was adding significant overhead to our development process, and our resources are already stretched so thin. 

https://github.com/podverse/podverse-rn/blob/develop/src/styles.ts

This task may not be particularly difficult as far as programming goes, but it will be a bit tedious as you'll need to test every screen on both iOS and Android, then confirm all components look good in light mode, and adjust them as needed. I would recommend also searching for the word "color" across all files, as some of the screens may have hard-coded color values that are not in the styles.js file. There is a color pallete file too you can use when choosing colors for light mode.

We'll also need to make sure the native system components, like system alerts and prompts use a sufficiently light/dark color scheme.

I'm not sure if it is possible, but it would be nice if the launch / splash screen would have either a white or black background depending on which theme is active in the app.

Given that this will require changes across many screens, and it is likely some components will be missed in the first release of light mode, we would greatly appreciate if you can make tweaks in a future release as needed to components that were missed.

$500

https://github.com/podverse/podverse-rn/issues/1550
