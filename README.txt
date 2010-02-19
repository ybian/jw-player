The JW Player is free for non-commerical use.  To buy a license for commercial use, please visit 
https://www.longtailvideo.com/players/order.

To build the JW Player, you will need the following software:

 * Flex SDK 3.3: http://opensource.adobe.com/wiki/display/flexsdk/Downloads
 * Ant 1.7.0: http://ant.apache.org/bindownload.cgi
 * FlexUnit 4: http://opensource.adobe.com/wiki/display/flexunit/FlexUnit (for testing the player)

To compile with Flex and Ant, enter the following command:

ant -buildfile build\build.xml

If the build is successful, player.swf will appear in the "bin-release" folder.

Alternately, if you're using Flex Builder or Flash Builder, you may use the following method to build the player:

1. Create a new Actionscript project (you can give it any name except "Player").
2. Under "Project Contents", select the checkout tree (the folder where this README file lives).
3. If using Flex Builder 3, click the "Next" button, then type "src" into the "Main Source Folder" field.
4. Click the "Finish" button
5. Right-click on your new project, and select "Properties"
6. Under the "ActionScript Compiler" tab, click the radio button that reads "Use a specific version", and make sure it reads "10.0.0" (the default in Flex Builder 3 is "9.0.124")
7. Click the "OK" button.
8. Alter your main application class to inherit from com.longtailvideo.jwplayer.player.Player (i.e. public class MyPlayer extends Player { ... )
9. Under the "Project" menu, choose "Export Release Build".
10. The player will be compiled as bin-release/{Your Project Name}.swf.