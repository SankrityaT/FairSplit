import Foundation

extension Sequence where Iterator.Element == Expense {
    func groupedByDate() -> [Date: [Expense]] {
        var groupedDict: [Date: [Expense]] = [:]
        
        for element in self {
            let date = Calendar.current.startOfDay(for: element.date)
            if var array = groupedDict[date] {
                array.append(element)
                groupedDict[date] = array
            } else {
                groupedDict[date] = [element]
            }
        }
        
        return groupedDict
    }
}
