import PlaygroundSupport
import SwiftUI

/*
    ---
    TODO
 
    12시 자정 넘겼을 때 Date() 날짜가 잘 바뀌는지 다시 확인해보기
 
    ---
    problem:
    
    Date() is UTC+0, but in Asia/Seoul Timezone, its UTC+9hr
 
    at 00:01:00 midnight,
    although date has changed to next day,
    Date() still points to yesterday,
    because it's UTC+0
    
 
    ---
    Date() is weird
 
    Date()로 선언하면 디버그 모드에서는 타임존 적용해서 뜸
    근데 print(Date()) 하면 UTC+0 으로 뜸
    그래서 GMT+9hr 만듬 더해줘서 print(Date()+ 9hr_in_seoncds) 하면 서울 타임존 적용해서 잘 뜸
    근데 debug mode에서 Date()+ 9hr_in_seoncds 를 보면 값이 정상시간 + 9시 해서 내일을 가르킴 ?!
 
    문제 원인: 
    print할 때 swift 내부적으로 쓰는 dateformmater에는 timezone 적용이 없음.
    근데 debugger mode에서 Date()를 나타낼 때 dateformatter에는 timezone이 적용되있음.
    
    해결책:
    Date()를 읽을 땐, DateFormatter 객체 만들어서 timezone 적용하고, 얘를 통해 Date -> string 변환해야 한다.
 
    ```.swift
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    print("Formatted Seoul time:", formatter.string(from: Date()))
    ```
 
    결론:
    CalendarView에서 오늘 selectedDay 선택할 때, Date()가 UTC 고려 안되서 print되서, 9시간 더해줘야하나? 라고 오해했는데,
    저건 print될 때만 UTC+0으로 나타나는거였다.
    내부적으로 Date()할 땐 선언한 시간 기준으로 되는 듯 하다.
    따라서 isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? dateInSeoulTimezone()), 에서, dateInSeoulTimeZone() 쓰는게 아니라 원래 쓰던대로 Date() 쓰면 될 듯?
 */

struct ViewDimensions {
    struct Calendar {
        let size: CGSize
    }
    
    static let calendar = Calendar(size: CGSize(width: 350, height: 400))
}

struct CalendarWithDailyTimeView: View {
    @Binding var currentDate: Date
    @State private var selectedDate: Date?
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        calendar.firstWeekday = 2 // 2 represents Monday
        return calendar
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    private let weekdaySymbols: [String] = {
        let symbols = Calendar.current.shortWeekdaySymbols
        return symbols.rotated(by: symbols.firstIndex(of: "Mon") ?? 0)
    }()
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(31)), count: 7), spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                ForEach(days(), id: \.self) { date in
                    DayView(date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate ?? Date()),
                            accumulatedSeconds: 0)
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
        .frame(width: ViewDimensions.calendar.size.width, height: ViewDimensions.calendar.size.height)
        .background(Color(white:0.983))
    }
    
//    private func dateInSeoulTimezone() -> Date {
//        let seoulTimezone = TimeZone(identifier: "Asia/Seoul")!
//        let now = Date()
//        let seoulOffset = seoulTimezone.secondsFromGMT(for: now)
//        
//        print(now)
//        print(now.addingTimeInterval(TimeInterval(seoulOffset))) //중요! - 실제 Date 객체상에는 현재시간+9hr 이라 내일임. 단지 string으로 변환할 때만 현재시간처럼 보이는 것
//        
//        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//        
//        print(formatter.string(from: now)) //이건 정상시간으로 표시됨
//        print("----------------------------")
//        
////        Date().addingTimeInterval(TimeInterval(TimeZone(identifier: "Asia/Seoul").secondsFromGMT()))
//        
//        return now.addingTimeInterval(TimeInterval(seoulOffset)) //Date type, correct time with UTC + 9hr applied
//    }
//    
    private func days() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        let dateInterval = calendar.dateInterval(of: .weekOfMonth, for: monthStart)!
        var startDate = dateInterval.start
        
        // Adjust start date if it's not a Monday
        if calendar.component(.weekday, from: startDate) != 2 {
            startDate = calendar.date(bySetting: .weekday, value: 2, of: startDate)!
        }
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate < monthEnd || dates.count % 7 != 0 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            
//            // Create a DateComponents object in the Seoul timezone
//            var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
//            components.timeZone = TimeZone(identifier: "Asia/Seoul")
//            
//            // Create the date using these components to ensure it's in the Seoul timezone
//            if let seoulDate = calendar.date(from: components) {
//                dates.append(seoulDate)
//            }
            
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
//        print(dates)
//        print(dates[15])
//        print(dateInSeoulTimezone())
//        print(calendar.isDate(dates[15], inSameDayAs: dateInSeoulTimezone()))
//        print(calendar.startOfDay(for: dateInSeoulTimezone())) //24-10-14 15:00 로 맞춰지네? 00:00이 아니라?
//        print(Date()) //이건 24-10-14 07:43 임 ;;
//        calendar.isDate(date, inSameDayAs: selectedDate ?? dateInSeoulTimezone()),
        
        return dates
    }
    
    func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
    
//    private func accumulatedTimeForDate(_ date: Date) -> Int {
//        let dateString = dateFormatter.string(from: date)
//        if calendar.isDateInToday(date) {
//            return accumulatedTimeModel.todayAccumulatedTime
//        }
//        return accumulatedTimeModel.getDailyAccumulatedTimes()[dateString] ?? 0
//    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let accumulatedSeconds: Int
    
//    private let calendar = Calendar.current
//
//    
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d"
//        return formatter
//    }()
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        calendar.firstWeekday = 2 // 2 represents Monday
        return calendar
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var colorIntensity: Double {
        if(accumulatedSeconds == 0) {
            return 0
        }
        let hours = Double(accumulatedSeconds) / 3600 + 0.1 //1분이라도 했으면 mark green
        return min(hours / 6, 1.0) // 6 hours as maximum intensity
    }
    
    private var formattedTime: String {
        let hours = accumulatedSeconds / 3600
        let minutes = (accumulatedSeconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 14, weight: .medium))
                Text(formattedTime)
                    .font(.system(size: 10))
            }
            .frame(width: 33, height: 40)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(colorIntensity))
                    if isToday {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                    }
                }
            )
            .foregroundColor(isSelected ? .blue : .primary)
            
            if accumulatedSeconds > 0 {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(2)
                    .background(Circle().fill(Color.white))
                    .offset(x: -1.5, y: 2)
            }
        }
    }
}

extension Calendar {
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [Date]()
        dates.append(dateInterval.start)
        
        enumerateDates(startingAfter: dateInterval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < dateInterval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}
extension Array {
    func rotated(by amount: Int) -> [Element] {
        guard !isEmpty else { return self }
        let amount = amount % count
        return Array(self[amount...] + self[..<amount])
    }
}


struct ContentView: View {
    @State private var currentDate = Date()
//    @State private var currentDate: Date = {
//        let seoulCalendar = Calendar.current
//        seoulCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
//        return seoulCalendar.startOfDay(for: Date.nowInSeoul())
//    }()
    
//    @State private var currentDate: Date = {
//        var seoulCalendar = Calendar.current
//        seoulCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
//        return seoulCalendar.startOfDay(for: Date.nowInSeoul())
//    }()
    
//    private let calendar: Calendar = {
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
//        calendar.firstWeekday = 2 // 2 represents Monday
//        return calendar
//    }()
    
    var body: some View {
        CalendarWithDailyTimeView(currentDate: $currentDate)
    }
}

let contentView = ContentView()
PlaygroundPage.current.setLiveView(contentView)
