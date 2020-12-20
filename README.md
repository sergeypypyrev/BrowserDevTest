# General Notes

This app was tested only on macOS 10.15.

Navigation history and installed extension are stored under $TMPDIR. So, they are reset on rebooting computer.

# Custom Build of WebKit

This task did not require changes in WebKit. Everything was done using standard capabilities of WebKit. However, for demo purposes app uses custom build of WebKit. I've made small modification in this build: initializer of WKWebConfiguration prints text "this is WebKit built by Sergey Pypyrev" on stdout.

Here is how to check that app uses custom build of WebKit:

1. Attach dmg by double clicking it.
1. Open Terminal (Launchpad -> Other -> Terminal)
1. Run command /Volumes/BrowserDevTest/BrowserDevTest.app/Contents/MacOS/BrowserDevTest in Terminal.
1. This command launches app with custom WebKit, so, it will print "this is WebKit built by Sergey Pypyrev". The same text is printed when user opens popup.
1. Exit app.
1. Run command /Volumes/BrowserDevTest/BrowserDevTest.app/Contents/MacOS/BrowserDevTest.real in Terminal.
1. This command launches app with system WebKit, so, it will print nothing.

# Technical Solutions

Here is brief description of used technical solutions:

1. topSites API and few other required WebExtensions APIs were implemented using WKUserScript. See file PopupViewController.swift for details.
1. To allow installation of extension on AMO app sets custom user agent. See file WebViewController.swift for details.
1. Files of installed extension are loaded using custom WKURLSchemeHandler. See file ExtensionURLSchemeHandler.swift for details.
1. To implement history of navigation initially I tried to use webView(_:didFinish:) of WKNavigationDelegate. However, for some sites this method is often not called. So, finally I used WKUserScript for this feature. See file BrowserViewController.swift for details.
