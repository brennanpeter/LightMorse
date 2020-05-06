# LightMorse

This is an ios App designed and tested on ios 13 for encoding and decoding morse code messages with the flashlight and camera.

There is more to morse code than just dots and dashes, it a has a specific rhythm and the different lengths of pauses indicate different things

International Morse code has the following 5 rules:

1.  The length of a dot is one unit
2.  A dash is three units
3.  The space between parts of the same letter is one unit
4.  The space between letters is three units
5.  The space between words in seven units

I was feeling very confident, perhaps even cocky, about the well this was working until I relocated my self to another room in the house. It seems like it works great sometimes and othertimes not so well. 

The App currently scans each frame and totals up a luminance value and compares the current luminance to the luminance of the previous frame.
Then if we detect a sudden increase in luminance we assume the flash turned on and vice versa if the luminance suddenly drops

This actually performed pretty well if the person on the decode side is in a dark room, the torch isn't causing too much lense flare and they don't move the camera around too much

I tested it by encoding on a slightly damaged iPhone 6 SE and decoding on a 2018 iPad and it translates better than I expected *sometimes*.

Sometimes it performs very well but then other times it thinks every letter is a T. My current theory is as the app is used it begins to slow down the device and then the tolerances of the timers begin to get out of wack. 

The only downside to using the iPad to test is it doesn't have a torch so feel like I'm not able to get the full experience of sending a message back a forth.

# Running the App

The user on the encode side should click the encode button on the main menu. Then they should type up a message they want to send.
When they click the send button on the encode page, the app will flash the torch on the device to send the message.
The person on the decode side should point their camera at the encoding phone and press the decode button on the main menu.
The app will immediately start decoding incoming flashes so it might missclassify the first letter if you started decoding late. 
