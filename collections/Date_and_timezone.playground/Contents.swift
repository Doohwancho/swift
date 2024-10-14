import Foundation
//import SwiftUI
//import UIKit
//import Cocoa


/*
 결론
 Date에 timezone 적용하는거 가능
 Date에 timezone 적용하고 String으로 바꾸는거 가능
 Date에 timezone 적용하고 String으로 바꾼걸 다시 Date로 바꾸는건 불가능. 다시 timezone 없는 UTC +0으로 됨
 
 */

/*
 Date is independent of time zones.
 The time zone only matters
 1. when converting between a Date and a string, or
 2. when converting between a Date and a DateComponents,
 
 and the objects that perform those conversions let you specify a time zone
 Date objects are immutable, representing an invariant time interval relative to an absolute reference date (00:00:00 UTC on 1 January 2001).

 
 documentation: https://developer.apple.com/documentation/foundation/nsdate?language=objc
 
 resource to understand how Date works in swift: https://www.maddysoft.com/articles/dates.html
 */


//let calendar = Calendar.current
//let dateComponent = DateComponents(calendar: calendar)
//print(dateComponent.day)
//print(dateComponent.hour)
//print(dateComponent.minute)

let now: Date = Date()
print(now) //2024-10-14 06:08:45 +0000 (UTC +0 default timezone)
print(type(of: now)) //Date
print(now.description(with: .current)) //Monday, October 14, 2024 at 3:08:45 PM Korean Standard Time(UTC + 9hr Asia/Seoul timezone)
print(type(of: now.description(with: .current))) //String


//Q. how to get Date type current timezone applied time?
let formatter = DateFormatter()
formatter.timeZone = TimeZone.current // Current system timezone (e.g., Asia/Seoul)
formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

let localTimeString = formatter.string(from: now)
print("Local time (formatted):", localTimeString) //Local time (formatted): 2024-10-14 15:08:45 (right time)

if let localTimeDate = formatter.date(from: localTimeString) {
    print("Local time (as Date object):", localTimeDate) //Local time (as Date object): 2024-10-14 06:08:45 +0000 (default time, not right)
} else {
    print("Failed to convert string to Date")
}


// Get the current calendar
let calendar = Calendar.current

// Extract local components (year, month, day, hour, etc.) in the current timezone
let localDateComponents = calendar.dateComponents(in: .current, from: now)

// Print the components in local time
print("Local Date Components:", localDateComponents) //calendar: gregorian (gregorian) locale: en_KR time zone: Asia/Seoul firstWeekday: 1 minDaysInFirstWeek: 1 timeZone: Asia/Seoul era: 1 year: 2024 month: 10 day: 14 hour: 15 minute: 14 second: 36 nanosecond: 803907990 weekday: 2 weekdayOrdinal: 2 quarter: 0 weekOfMonth: 3 weekOfYear: 42 yearForWeekOfYear: 2024 isLeapMonth: false

print(type(of: localDateComponents)) //DateComponents

// Convert components back into a Date object, in the local timezone
if let localDate = calendar.date(from: localDateComponents) {
    print("Local time (as Date object):", localDate) //Local time (as Date object): 2024-10-14 06:14:36 +0000
}

func getCurrentUTCTime() {
    let currentDate = Date()
    let utcCalendar = Calendar.current
//    let utcTimeZone = TimeZone(secondsFromGMT: 32400)! //2024-10-14 06:22:31 +0000
    let utcTimeZone = TimeZone(secondsFromGMT: 0)! //2024-10-14 06:22:31 +0000
    print("getCurrentUTFTime()")
    print(utcCalendar.date(from: utcCalendar.dateComponents(in: utcTimeZone, from: currentDate))!)
}

getCurrentUTCTime() //default time

let seoul = Date()
print(seoul) //default time
var calendar1 = Calendar.current
calendar1.timeZone = TimeZone(identifier: "Asia/Seoul")!

// 시차 계산 - Seoul
let timeDifferenceSeoul = calendar1.timeZone.secondsFromGMT(for: seoul)
print("시차:", timeDifferenceSeoul / 60 / 60, "시간") //9시간
