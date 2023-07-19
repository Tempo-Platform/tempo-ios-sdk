<h1 align="center">

<img src="assets/tempo-logo.png" width="128"/>
<br/>
TempoSDK
</h1>

TempoSDK is a library containing the code that handles the display of ad content. It talks directly with Tempo backend to request ad content specifics and controls when the web view object is displayed and removed in iOS.

- [Example App](#example-app)
- [Publish to CocoaPods](#publish-to-cocoapods)
- [Try the TempoSDK](#try-the-temposdk)
- [Source Control](#source-control)
    * [Branching](#branching)
    * [Pull Requests](#pull-requests)

## Example App

1. Run `cd Example`
2. Run `pod install`. This installs all the pod dependencies and creates a "TempoSDK.xcworkspace" file.
3. Open the file "Example/TempoSDK.xcworkspace" in XCode
4. Hit Run

## Publish to CocoaPods
1. Create a new release in github with an updated version number.
2. Update the version number in "TempoSDK.podspec" file to match the above github release. 
3. Run `pod trunk push --allow-warnings --verbose`

## Try the TempoSDK

Add the following line to your Podfile:

```ruby
pod 'TempoSDK'
```

## Source Control

### Branching

All changes to the repository must be done on a branch separate to `main`. Once work is finished on a branch it can then be merged into `main` by creating a [pull request](#pull-requests).

Branches are recommended to use the following format:

~~~
intent/title

e.g.
feature/new-ad-type
refactor/ad-module
fix/blank-ad-issue
~~~

The start of the commit message, in this case the word feature indicates the intention of the commit. A full list of commit intentions are listed below.

The last part of the commit message is a brief description of the changes.

**Intentions**
* feature: Adding new functionality to the codebase
* enhancement: Enhancing an existing feature or making it more performant
* refactor: Removing/Restructuring code to better suit architectural constraints, developer productivity or performance
* fix: Fixing a bug
* chore: Any mind-numbing, painful or otherwise distasteful changes to the codebase
* test: Updating or adding tests
* build: Updating the build process
* docs: Updating or adding documentation
* action: Any [GitHub Actions](https://docs.github.com/en/actions) related work (pipeline yaml files, pipeline testing, etc)

### Pull Requests

> Pull requests let you tell others about changes you've pushed to a branch in a repository on GitHub. Once a pull request is opened, you can discuss and review the potential changes with collaborators and add follow-up commits before your changes are merged into the base branch.

[About Pull Requests | GitHub](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)

Before merging our branch into development or master, we **must** create a pull request in the repository.
