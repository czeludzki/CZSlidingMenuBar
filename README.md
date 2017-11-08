# CZSlidingMenuBar

[![CI Status](http://img.shields.io/travis/czeludzki/CZSlidingMenuBar.svg?style=flat)](https://travis-ci.org/czeludzki/CZSlidingMenuBar)
[![Version](https://img.shields.io/cocoapods/v/CZSlidingMenuBar.svg?style=flat)](http://cocoapods.org/pods/CZSlidingMenuBar)
[![License](https://img.shields.io/cocoapods/l/CZSlidingMenuBar.svg?style=flat)](http://cocoapods.org/pods/CZSlidingMenuBar)
[![Platform](https://img.shields.io/cocoapods/p/CZSlidingMenuBar.svg?style=flat)](http://cocoapods.org/pods/CZSlidingMenuBar)

## Example
设置 `.(UIScrollView *)linkedScrollView` 关联需要联动的 scrollView.  
CZSlidingMenuBar 会实时监听 `.linkedScrollView` 的滑动变化,以更新 CZSlidingMenuBar 的状态.  
但并不会影响到 `.linkedScrollView` 本身 delegate 的设置和使用 !

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CZSlidingMenuBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CZSlidingMenuBar'
```

## Author

czeludzki, czeludzki@gmail.com

## License

CZSlidingMenuBar is available under the MIT license. See the LICENSE file for more info.
