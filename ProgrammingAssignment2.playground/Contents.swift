
import Foundation

typealias NSUInteger = UInt64;
// https://developer.apple.com/documentation/objectivec/nsuinteger
//typedef unsigned long NSUInteger;

let MAX_VAL_HOUR: NSUInteger = 24;
let MAX_VAL_MIN_SEC: NSUInteger = 60;
let MIN_VAL: NSUInteger = 0;

enum ValidationError: LocalizedError {
    case hours(val: NSUInteger)
    case minutes(val: NSUInteger)
    case seconds(val: NSUInteger)
    
    var errorDescription: String? {
        let format = "%d is incorrect format for ";
        switch self {
        case let .hours(val):
            return String(format: format + "hours", val);
        case let .minutes(val):
            return String(format: format + "minutes", val);
        case let .seconds(val):
            return String(format: format + "seconds", val);
        }
    }
}
// Oleksandr Korienev -> TimeOK
class TimeOK {
    var hours: NSUInteger;
    var minutes: NSUInteger;
    var seconds: NSUInteger;
    
    init() {
        hours = 0;
        minutes = 0;
        seconds = 0;
    }
    
    init(hours: NSUInteger, minutes: NSUInteger, seconds: NSUInteger) throws {
        if !(MIN_VAL ..< MAX_VAL_HOUR).contains(hours) {
            throw ValidationError.hours(val: hours);
        }
        if !(MIN_VAL ..< MAX_VAL_MIN_SEC).contains(minutes) {
            throw ValidationError.minutes(val: minutes);
        }
        if !(MIN_VAL ..< MAX_VAL_MIN_SEC).contains(seconds) {
            throw ValidationError.seconds(val: seconds);
        }
        self.hours = hours;
        self.minutes = minutes;
        self.seconds = seconds;
    }
    
    init(date: NSDate) {
        let calendar = Calendar.current;
        let comp = calendar.dateComponents([.hour, .minute, .second], from: date as Date);
        
        let hours = comp.hour
        if (hours != nil) {
            self.hours = NSUInteger(hours!);
        } else {
            self.hours = 0;
        }
        
        let minutes = comp.minute;
        if (minutes != nil) {
            self.minutes = NSUInteger(minutes!);
        } else {
            self.minutes = 0;
        }
        
        let seconds = comp.second;
        if (seconds != nil) {
            self.seconds = NSUInteger(seconds!);
        } else {
            self.seconds = 0;
        }
        
    }
    
    func repr() -> String {
        let format = "%d:%d:%d ";
        let am = "AM";
        let pm = "PM";
        if (hours == 0) {
            return String(format: format + am, hours + 12, minutes, seconds);
        }
        if ((1..<12).contains(hours)){
            return String(format: format + am, hours, minutes, seconds);
        }
        if (hours == 12) {
            return String(format: format + pm, hours, minutes, seconds);
        }
        return String(format: format + pm, hours - 12, minutes, seconds);
    }
    
    func add(other: TimeOK) -> TimeOK {
        var overflow: NSUInteger;
        var sum: NSUInteger;
        
        sum = self.seconds + other.seconds;
        let seconds = sum % MAX_VAL_MIN_SEC;
        overflow = sum / MAX_VAL_MIN_SEC;
        
        sum = self.minutes + other.minutes + overflow;
        let minutes = sum % MAX_VAL_MIN_SEC;
        overflow = sum / MAX_VAL_MIN_SEC;
        
        sum = self.hours + other.hours + overflow;
        let hours = sum % MAX_VAL_HOUR;
        
        do {
            return try TimeOK(hours: hours, minutes: minutes, seconds: seconds);
        } catch {
            return TimeOK();
        }
    }
    
    func sub(other: TimeOK) -> TimeOK {
        var overflow: NSUInteger;
        var dif: NSUInteger;
        
        if (other.seconds > seconds) {
            dif = MAX_VAL_MIN_SEC + seconds - other.seconds;
            overflow = 1;
        } else {
            dif = seconds - other.seconds;
            overflow = 0;
        }
        let seconds = dif;
        
        if (other.minutes + overflow > minutes) {
            dif = MAX_VAL_MIN_SEC + minutes - other.minutes - overflow;
            overflow = 1;
        } else {
            dif = minutes - other.minutes - overflow;
            overflow = 0;
        }
        let minutes = dif;
        
        if (other.hours + overflow > hours) {
            dif = MAX_VAL_HOUR + hours - other.hours - overflow;
            overflow = 1;
        } else {
            dif = hours - other.hours - overflow;
        }
        let hours = dif;
        
        do {
            return try TimeOK(hours: hours, minutes: minutes, seconds: seconds);
        } catch {
            return TimeOK();
        }
    }
    
    class func add(left: TimeOK, right: TimeOK) -> TimeOK {
        return left.add(other: right);
    }
    
    class func sub(left: TimeOK, right: TimeOK) -> TimeOK {
        return left.sub(other: right);
    }
}

let a = TimeOK();
print("A is ", a.repr())
do {
    let b = try TimeOK(hours: 23, minutes: 59, seconds: 59);
    print("B is ", b.repr())
} catch {
    print(error);
}

do {
    let _ = try TimeOK(hours: 25, minutes: 60, seconds: 60);
} catch {
    print(error.localizedDescription);
}

do {
    let _ = try TimeOK(hours: 23, minutes: 60, seconds: 60);
} catch {
    print(error.localizedDescription);
}

do {
    let _ = try TimeOK(hours: 23, minutes: 59, seconds: 60);
} catch {
    print(error.localizedDescription);
}

let c = TimeOK(date: NSDate());
print("C is ", c.repr());

var left = TimeOK();
do {
    left = try TimeOK(hours: 23, minutes: 59, seconds: 59);
} catch {
    print(error.localizedDescription);
}
print("left is ", left.repr())

var right = TimeOK();
do {
    right = try TimeOK(hours: 12, minutes: 0, seconds: 1)
} catch {
    print(error.localizedDescription);
}
print("right is ", right.repr())

var sum = left.add(other: right)
print("sum is ", sum.repr())
var dif = left.sub(other: right)
print("dif is ", dif.repr())
print("")

do {
    left = try TimeOK(hours: 0, minutes: 0, seconds: 0);
} catch {
    print(error.localizedDescription);
}
print("left is ", left.repr())

do {
    right = try TimeOK(hours: 0, minutes: 0, seconds: 1)
} catch {
    print(error.localizedDescription);
}
print("right is ", right.repr())

sum = left.add(other: right)
print("sum is ", sum.repr())
dif = left.sub(other: right)
print("dif is ", dif.repr())

print("sum with classmethod", TimeOK.add(left: left, right: right).repr());
print("dif with classmethod", TimeOK.sub(left: left, right: right).repr());
