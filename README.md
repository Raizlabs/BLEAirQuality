# BLEAirQuality

[![Version](https://img.shields.io/cocoapods/v/BLEAirQuality.svg?style=flat)](https://cocoapods.org/pods/BLEAirQuality)
[![License](https://img.shields.io/cocoapods/l/BLEAirQuality.svg?style=flat)](https://cocoapods.org/pods/BLEAirQuality)
[![Platform](https://img.shields.io/cocoapods/p/BLEAirQuality.svg?style=flat)](https://cocoapods.org/pods/BLEAirQuality)

Client library for AQI BLE peripheral: https://github.com/Raizlabs/air_quality_bluetooth_le

BLE Constants: 

```python
AQI_PM_SRVC = '22AF619F-4A1B-4BCB-B481-5B13BFE86E94'
PM_2_5_CHRC = '2A6E'
PM_10_CHRC = '2A6F'
PM_2_5_FMT_DSCP = '2904'
PM_10_FMT_DSCP = '2905'
```

The characteristics support both read and notify, and return little endian IEEE 754 32-bit float values representing PM 2.5 and PM10 concentrations in units of µg/m3. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BLEAirQuality is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BLEAirQuality'
```

## Author

Chris Ballinger, chris.ballinger@raizlabs.com

## License

BLEAirQuality is available under the MIT license. See the LICENSE file for more info.
