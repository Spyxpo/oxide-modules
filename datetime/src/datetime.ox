# =============================================================================
#  Oxide DateTime Module
#  Cross-platform date and time handling for Oxide applications.
#
#  Compile the native library:
#    macOS:   clang -shared -o liboxide_datetime.dylib oxide_datetime.c
#    Linux:   gcc -shared -fPIC -o liboxide_datetime.so oxide_datetime.c
#    Windows: cl /LD oxide_datetime.c /Fe:oxide_datetime.dll
#
#  Usage:
#    use datetime
#
#    dt = DateTime.now()
#    print dt.format("%Y-%m-%d %H:%M:%S")
# =============================================================================

# Link the native datetime library
link "./modules/datetime/liboxide_datetime.dylib"

# -----------------------------------------------------------------------------
# Native FFI Functions
# -----------------------------------------------------------------------------

# Get current timestamp in milliseconds since epoch
native func _timestamp() from "datetime_timestamp"

# Get current time components (returns packed struct)
native func _now_year() from "datetime_now_year"
native func _now_month() from "datetime_now_month"
native func _now_day() from "datetime_now_day"
native func _now_hour() from "datetime_now_hour"
native func _now_minute() from "datetime_now_minute"
native func _now_second() from "datetime_now_second"
native func _now_millisecond() from "datetime_now_millisecond"
native func _now_weekday() from "datetime_now_weekday"
native func _now_yearday() from "datetime_now_yearday"

# UTC time components
native func _utc_year() from "datetime_utc_year"
native func _utc_month() from "datetime_utc_month"
native func _utc_day() from "datetime_utc_day"
native func _utc_hour() from "datetime_utc_hour"
native func _utc_minute() from "datetime_utc_minute"
native func _utc_second() from "datetime_utc_second"
native func _utc_weekday() from "datetime_utc_weekday"

# Get timezone offset in seconds
native func _timezone_offset() from "datetime_timezone_offset"

# Get timezone name
native func _timezone_name() from "datetime_timezone_name"

# Convert timestamp to components
native func _ts_to_year(ts) from "datetime_ts_to_year"
native func _ts_to_month(ts) from "datetime_ts_to_month"
native func _ts_to_day(ts) from "datetime_ts_to_day"
native func _ts_to_hour(ts) from "datetime_ts_to_hour"
native func _ts_to_minute(ts) from "datetime_ts_to_minute"
native func _ts_to_second(ts) from "datetime_ts_to_second"
native func _ts_to_weekday(ts) from "datetime_ts_to_weekday"

# Convert components to timestamp
native func _components_to_ts(year, month, day, hour, minute, second) from "datetime_components_to_ts"

# Sleep for milliseconds
native func _sleep_ms(ms) from "datetime_sleep_ms"

# -----------------------------------------------------------------------------
# Format Constants
# -----------------------------------------------------------------------------

FORMAT_DATE = "%Y-%m-%d"
FORMAT_TIME = "%H:%M:%S"
FORMAT_DATETIME = "%Y-%m-%d %H:%M:%S"
FORMAT_ISO = "%Y-%m-%dT%H:%M:%S"
FORMAT_SHORT = "%m/%d/%Y"
FORMAT_LONG = "%B %d, %Y"

# Day names
DAYS_FULL = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
DAYS_SHORT = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

# Month names
MONTHS_FULL = ["", "January", "February", "March", "April", "May", "June",
               "July", "August", "September", "October", "November", "December"]
MONTHS_SHORT = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

# -----------------------------------------------------------------------------
# Duration Class
# -----------------------------------------------------------------------------

class Duration
    func init(milliseconds)
        if milliseconds == None
            milliseconds = 0
        endif
        self._ms = milliseconds
    endfunc

    # Create from components
    func fromComponents(days, hours, minutes, seconds, milliseconds)
        if days == None
            days = 0
        endif
        if hours == None
            hours = 0
        endif
        if minutes == None
            minutes = 0
        endif
        if seconds == None
            seconds = 0
        endif
        if milliseconds == None
            milliseconds = 0
        endif
        self._ms = (days * 86400000) + (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + milliseconds
        return self
    endfunc

    # Get total milliseconds
    func milliseconds()
        return self._ms
    endfunc

    # Get total seconds
    func seconds()
        return self._ms / 1000
    endfunc

    # Get total minutes
    func minutes()
        return self._ms / 60000
    endfunc

    # Get total hours
    func hours()
        return self._ms / 3600000
    endfunc

    # Get total days
    func days()
        return self._ms / 86400000
    endfunc

    # Get component days (not total)
    func daysPart()
        return floor(self._ms / 86400000)
    endfunc

    # Get component hours (0-23)
    func hoursPart()
        return floor((self._ms % 86400000) / 3600000)
    endfunc

    # Get component minutes (0-59)
    func minutesPart()
        return floor((self._ms % 3600000) / 60000)
    endfunc

    # Get component seconds (0-59)
    func secondsPart()
        return floor((self._ms % 60000) / 1000)
    endfunc

    # Human readable string
    func humanize()
        ms = abs(self._ms)
        if ms < 1000
            return str(ms) + " milliseconds"
        endif
        if ms < 60000
            s = floor(ms / 1000)
            return str(s) + " second" + (s == 1 ? "" : "s")
        endif
        if ms < 3600000
            m = floor(ms / 60000)
            return str(m) + " minute" + (m == 1 ? "" : "s")
        endif
        if ms < 86400000
            h = floor(ms / 3600000)
            return str(h) + " hour" + (h == 1 ? "" : "s")
        endif
        d = floor(ms / 86400000)
        return str(d) + " day" + (d == 1 ? "" : "s")
    endfunc

    # String representation
    func toString()
        return self.humanize()
    endfunc

    # Add another duration
    func add(other)
        return new Duration(self._ms + other._ms)
    endfunc

    # Subtract another duration
    func subtract(other)
        return new Duration(self._ms - other._ms)
    endfunc

    # Negate
    func negate()
        return new Duration(-self._ms)
    endfunc

    # Check if negative
    func isNegative()
        return self._ms < 0
    endfunc

    # -------------------------------------------------------------------------
    # Static Methods (called as Duration.methodName())
    # -------------------------------------------------------------------------

    # Create duration from components
    static func fromComponents(days, hours, minutes, seconds, milliseconds)
        if days == None
            days = 0
        endif
        if hours == None
            hours = 0
        endif
        if minutes == None
            minutes = 0
        endif
        if seconds == None
            seconds = 0
        endif
        if milliseconds == None
            milliseconds = 0
        endif
        ms = (days * 86400000) + (hours * 3600000) + (minutes * 60000) + (seconds * 1000) + milliseconds
        return new Duration(ms)
    endfunc
endclass

# -----------------------------------------------------------------------------
# DateTime Class
# -----------------------------------------------------------------------------

class DateTime
    func init(year, month, day, hour, minute, second, millisecond)
        if year == None
            # Initialize from current time
            self._year = _now_year()
            self._month = _now_month()
            self._day = _now_day()
            self._hour = _now_hour()
            self._minute = _now_minute()
            self._second = _now_second()
            self._millisecond = _now_millisecond()
        else
            self._year = year
            self._month = month
            if day == None
                day = 1
            endif
            self._day = day
            if hour == None
                hour = 0
            endif
            self._hour = hour
            if minute == None
                minute = 0
            endif
            self._minute = minute
            if second == None
                second = 0
            endif
            self._second = second
            if millisecond == None
                millisecond = 0
            endif
            self._millisecond = millisecond
        endif
        self._tz = None
    endfunc

    # Create from timestamp
    func fromTimestamp(ts)
        self._year = _ts_to_year(ts)
        self._month = _ts_to_month(ts)
        self._day = _ts_to_day(ts)
        self._hour = _ts_to_hour(ts)
        self._minute = _ts_to_minute(ts)
        self._second = _ts_to_second(ts)
        self._millisecond = ts % 1000
        return self
    endfunc

    # Get year
    func year()
        return self._year
    endfunc

    # Get month (1-12)
    func month()
        return self._month
    endfunc

    # Get day (1-31)
    func day()
        return self._day
    endfunc

    # Get hour (0-23)
    func hour()
        return self._hour
    endfunc

    # Get minute (0-59)
    func minute()
        return self._minute
    endfunc

    # Get second (0-59)
    func second()
        return self._second
    endfunc

    # Get millisecond (0-999)
    func millisecond()
        return self._millisecond
    endfunc

    # Get weekday (0=Sunday, 6=Saturday)
    func weekday()
        # Zeller's congruence for Gregorian calendar
        y = self._year
        m = self._month
        d = self._day
        if m < 3
            m = m + 12
            y = y - 1
        endif
        k = y % 100
        j = floor(y / 100)
        h = (d + floor((13 * (m + 1)) / 5) + k + floor(k / 4) + floor(j / 4) - 2 * j) % 7
        # Convert from Zeller (0=Saturday) to standard (0=Sunday)
        return ((h + 6) % 7)
    endfunc

    # Get day of week name
    func dayOfWeek()
        return DAYS_FULL[self.weekday()]
    endfunc

    # Get short day name
    func dayOfWeekShort()
        return DAYS_SHORT[self.weekday()]
    endfunc

    # Get month name
    func monthName()
        return MONTHS_FULL[self._month]
    endfunc

    # Get short month name
    func monthNameShort()
        return MONTHS_SHORT[self._month]
    endfunc

    # Get day of year (1-366)
    func dayOfYear()
        daysInMonths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        if self.isLeapYear()
            daysInMonths[2] = 29
        endif
        total = 0
        for i in range(1, self._month)
            total = total + daysInMonths[i]
        endfor
        return total + self._day
    endfunc

    # Get week of year
    func weekOfYear()
        return ceil(self.dayOfYear() / 7)
    endfunc

    # Get quarter (1-4)
    func quarter()
        return ceil(self._month / 3)
    endfunc

    # Check if leap year
    func isLeapYear()
        y = self._year
        return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)
    endfunc

    # Check if weekend
    func isWeekend()
        wd = self.weekday()
        return wd == 0 or wd == 6
    endfunc

    # Check if today
    func isToday()
        return self._year == _now_year() and self._month == _now_month() and self._day == _now_day()
    endfunc

    # Get timestamp in milliseconds
    func toTimestamp()
        ts = _components_to_ts(self._year, self._month, self._day, self._hour, self._minute, self._second)
        return ts * 1000 + self._millisecond
    endfunc

    # Get Unix timestamp in seconds
    func toUnix()
        return _components_to_ts(self._year, self._month, self._day, self._hour, self._minute, self._second)
    endfunc

    # Format to string
    func format(pattern)
        if pattern == None
            pattern = FORMAT_DATETIME
        endif

        result = pattern

        # Year
        result = replace(result, "%Y", str(self._year))
        result = replace(result, "%y", padLeft(str(self._year % 100), 2, "0"))

        # Month
        result = replace(result, "%m", padLeft(str(self._month), 2, "0"))
        result = replace(result, "%B", MONTHS_FULL[self._month])
        result = replace(result, "%b", MONTHS_SHORT[self._month])

        # Day
        result = replace(result, "%d", padLeft(str(self._day), 2, "0"))
        result = replace(result, "%e", str(self._day))
        result = replace(result, "%j", padLeft(str(self.dayOfYear()), 3, "0"))

        # Weekday
        result = replace(result, "%A", DAYS_FULL[self.weekday()])
        result = replace(result, "%a", DAYS_SHORT[self.weekday()])
        result = replace(result, "%w", str(self.weekday()))

        # Time
        result = replace(result, "%H", padLeft(str(self._hour), 2, "0"))
        result = replace(result, "%I", padLeft(str((self._hour % 12) == 0 ? 12 : (self._hour % 12)), 2, "0"))
        result = replace(result, "%M", padLeft(str(self._minute), 2, "0"))
        result = replace(result, "%S", padLeft(str(self._second), 2, "0"))
        result = replace(result, "%f", padLeft(str(self._millisecond), 3, "0"))
        result = replace(result, "%p", self._hour < 12 ? "AM" : "PM")

        # Timezone
        result = replace(result, "%Z", self.timezone())

        return result
    endfunc

    # Format as ISO 8601
    func toIso()
        return self.format("%Y-%m-%dT%H:%M:%S") + "." + padLeft(str(self._millisecond), 3, "0") + "Z"
    endfunc

    # Get timezone name
    func timezone()
        if self._tz != None
            return self._tz
        endif
        return _timezone_name()
    endfunc

    # Get UTC offset in hours
    func utcOffset()
        return _timezone_offset() / 3600
    endfunc

    # Convert to UTC
    func toUtc()
        offset = _timezone_offset() * 1000
        ts = self.toTimestamp() - offset
        dt = new DateTime()
        dt.fromTimestamp(ts)
        dt._tz = "UTC"
        return dt
    endfunc

    # Convert to local time
    func toLocal()
        if self._tz != "UTC"
            return self
        endif
        offset = _timezone_offset() * 1000
        ts = self.toTimestamp() + offset
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Add days
    func addDays(n)
        ts = self.toTimestamp() + (n * 86400000)
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Add months
    func addMonths(n)
        newMonth = self._month + n
        newYear = self._year

        while newMonth > 12
            newMonth = newMonth - 12
            newYear = newYear + 1
        endwhile

        while newMonth < 1
            newMonth = newMonth + 12
            newYear = newYear - 1
        endwhile

        # Adjust day if needed
        maxDay = daysInMonth(newYear, newMonth)
        newDay = min(self._day, maxDay)

        return new DateTime(newYear, newMonth, newDay, self._hour, self._minute, self._second, self._millisecond)
    endfunc

    # Add years
    func addYears(n)
        return self.addMonths(n * 12)
    endfunc

    # Add hours
    func addHours(n)
        ts = self.toTimestamp() + (n * 3600000)
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Add minutes
    func addMinutes(n)
        ts = self.toTimestamp() + (n * 60000)
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Add seconds
    func addSeconds(n)
        ts = self.toTimestamp() + (n * 1000)
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Add milliseconds
    func addMilliseconds(n)
        ts = self.toTimestamp() + n
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Add duration
    func add(duration)
        ts = self.toTimestamp() + duration.milliseconds()
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Subtract duration
    func subtract(duration)
        ts = self.toTimestamp() - duration.milliseconds()
        dt = new DateTime()
        dt.fromTimestamp(ts)
        return dt
    endfunc

    # Check if before another datetime
    func isBefore(other)
        return self.toTimestamp() < other.toTimestamp()
    endfunc

    # Check if after another datetime
    func isAfter(other)
        return self.toTimestamp() > other.toTimestamp()
    endfunc

    # Check if equal to another datetime
    func equals(other)
        return self.toTimestamp() == other.toTimestamp()
    endfunc

    # Check if between two datetimes
    func isBetween(start, end)
        ts = self.toTimestamp()
        return ts >= start.toTimestamp() and ts <= end.toTimestamp()
    endfunc

    # Get difference as Duration
    func diff(other)
        diff = self.toTimestamp() - other.toTimestamp()
        return new Duration(diff)
    endfunc

    # Relative time string (e.g., "2 hours ago")
    func fromNow()
        diff = _timestamp() - self.toTimestamp()
        absDiff = abs(diff)
        past = diff > 0

        suffix = past ? " ago" : ""
        prefix = past ? "" : "in "

        if absDiff < 1000
            return "just now"
        endif
        if absDiff < 60000
            s = floor(absDiff / 1000)
            return prefix + str(s) + " second" + (s == 1 ? "" : "s") + suffix
        endif
        if absDiff < 3600000
            m = floor(absDiff / 60000)
            return prefix + str(m) + " minute" + (m == 1 ? "" : "s") + suffix
        endif
        if absDiff < 86400000
            h = floor(absDiff / 3600000)
            return prefix + str(h) + " hour" + (h == 1 ? "" : "s") + suffix
        endif
        if absDiff < 2592000000
            d = floor(absDiff / 86400000)
            return prefix + str(d) + " day" + (d == 1 ? "" : "s") + suffix
        endif
        if absDiff < 31536000000
            months = floor(absDiff / 2592000000)
            return prefix + str(months) + " month" + (months == 1 ? "" : "s") + suffix
        endif
        years = floor(absDiff / 31536000000)
        return prefix + str(years) + " year" + (years == 1 ? "" : "s") + suffix
    endfunc

    # Start of day
    func startOfDay()
        return new DateTime(self._year, self._month, self._day, 0, 0, 0, 0)
    endfunc

    # End of day
    func endOfDay()
        return new DateTime(self._year, self._month, self._day, 23, 59, 59, 999)
    endfunc

    # Start of month
    func startOfMonth()
        return new DateTime(self._year, self._month, 1, 0, 0, 0, 0)
    endfunc

    # End of month
    func endOfMonth()
        lastDay = daysInMonth(self._year, self._month)
        return new DateTime(self._year, self._month, lastDay, 23, 59, 59, 999)
    endfunc

    # Start of year
    func startOfYear()
        return new DateTime(self._year, 1, 1, 0, 0, 0, 0)
    endfunc

    # End of year
    func endOfYear()
        return new DateTime(self._year, 12, 31, 23, 59, 59, 999)
    endfunc

    # Clone this datetime
    func clone()
        return new DateTime(self._year, self._month, self._day, self._hour, self._minute, self._second, self._millisecond)
    endfunc

    # String representation
    func toString()
        return self.format(FORMAT_DATETIME)
    endfunc

    # -------------------------------------------------------------------------
    # Static Methods (called as DateTime.methodName())
    # -------------------------------------------------------------------------

    # Create a new DateTime instance (factory method)
    static func create(year, month, day, hour, minute, second, millisecond)
        return new DateTime(year, month, day, hour, minute, second, millisecond)
    endfunc

    # Get current local datetime
    static func now()
        return new DateTime()
    endfunc

    # Get current UTC datetime
    static func utcNow()
        dt = new DateTime()
        dt._year = _utc_year()
        dt._month = _utc_month()
        dt._day = _utc_day()
        dt._hour = _utc_hour()
        dt._minute = _utc_minute()
        dt._second = _utc_second()
        dt._millisecond = 0
        dt._tz = "UTC"
        return dt
    endfunc

    # Get today at midnight
    static func today()
        dt = new DateTime()
        dt._hour = 0
        dt._minute = 0
        dt._second = 0
        dt._millisecond = 0
        return dt
    endfunc

    # Get current timestamp in milliseconds
    static func timestamp()
        return _timestamp()
    endfunc

    # Create datetime from timestamp (milliseconds)
    static func fromTimestamp(ts)
        dt = new DateTime()
        dt._year = _ts_to_year(ts)
        dt._month = _ts_to_month(ts)
        dt._day = _ts_to_day(ts)
        dt._hour = _ts_to_hour(ts)
        dt._minute = _ts_to_minute(ts)
        dt._second = _ts_to_second(ts)
        dt._millisecond = ts % 1000
        return dt
    endfunc

    # Create datetime from Unix timestamp (seconds)
    static func fromUnix(unix)
        return DateTime.fromTimestamp(unix * 1000)
    endfunc

    # Parse datetime from string
    static func parse(str, format)
        dt = new DateTime(1970, 1, 1, 0, 0, 0, 0)

        if format == None
            format = FORMAT_DATETIME
        endif

        # Try to parse ISO format first
        if contains(str, "T") and (contains(str, "Z") or contains(str, "+") or contains(str, "-"))
            return DateTime.parseIso(str)
        endif

        # Parse based on format
        i = 0
        fi = 0

        while fi < len(format) and i < len(str)
            if format[fi] == "%"
                fi = fi + 1
                spec = format[fi]

                if spec == "Y"
                    dt._year = parseInt(slice(str, i, i + 4))
                    i = i + 4
                elif spec == "y"
                    year2 = parseInt(slice(str, i, i + 2))
                    dt._year = year2 >= 70 ? 1900 + year2 : 2000 + year2
                    i = i + 2
                elif spec == "m"
                    dt._month = parseInt(slice(str, i, i + 2))
                    i = i + 2
                elif spec == "d"
                    dt._day = parseInt(slice(str, i, i + 2))
                    i = i + 2
                elif spec == "H"
                    dt._hour = parseInt(slice(str, i, i + 2))
                    i = i + 2
                elif spec == "M"
                    dt._minute = parseInt(slice(str, i, i + 2))
                    i = i + 2
                elif spec == "S"
                    dt._second = parseInt(slice(str, i, i + 2))
                    i = i + 2
                endif
                fi = fi + 1
            else
                # Skip literal characters
                i = i + 1
                fi = fi + 1
            endif
        endwhile

        return dt
    endfunc

    # Parse ISO 8601 datetime string
    static func parseIso(str)
        # Format: YYYY-MM-DDTHH:MM:SS.sssZ or YYYY-MM-DDTHH:MM:SS.sss+HH:MM
        dt = new DateTime(1970, 1, 1, 0, 0, 0, 0)

        # Remove 'Z' suffix
        str = replace(str, "Z", "")

        # Split date and time
        parts = split(str, "T")
        datePart = parts[0]

        # Parse date
        dateParts = split(datePart, "-")
        dt._year = parseInt(dateParts[0])
        dt._month = parseInt(dateParts[1])
        dt._day = parseInt(dateParts[2])

        # Parse time if present
        if len(parts) > 1
            timePart = parts[1]

            # Check for timezone offset
            if contains(timePart, "+")
                timeParts = split(timePart, "+")
                timePart = timeParts[0]
            elif contains(timePart, "-")
                # Could be negative offset - need to handle carefully
                lastDash = _lastIndexOf(timePart, "-")
                if lastDash > 5
                    timePart = slice(timePart, 0, lastDash)
                endif
            endif

            # Parse time components
            timeComponents = split(timePart, ":")
            dt._hour = parseInt(timeComponents[0])
            if len(timeComponents) > 1
                dt._minute = parseInt(timeComponents[1])
            endif
            if len(timeComponents) > 2
                secondPart = timeComponents[2]
                # Handle milliseconds
                if contains(secondPart, ".")
                    secParts = split(secondPart, ".")
                    dt._second = parseInt(secParts[0])
                    dt._millisecond = parseInt(secParts[1])
                else
                    dt._second = parseInt(secondPart)
                endif
            endif
        endif

        return dt
    endfunc

    # Check if year is leap year
    static func isLeapYear(year)
        return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)
    endfunc

    # Get days in month
    static func daysInMonth(year, month)
        days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        if month == 2 and DateTime.isLeapYear(year)
            return 29
        endif
        return days[month]
    endfunc

    # Sleep for specified duration
    static func sleep(duration)
        if type(duration) == "number"
            _sleep_ms(duration)
        else
            _sleep_ms(duration.milliseconds())
        endif
    endfunc

    # Sleep for seconds
    static func sleepSeconds(seconds)
        _sleep_ms(seconds * 1000)
    endfunc
endclass

# -----------------------------------------------------------------------------
# Module Functions
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# DateTime Class Static Methods (Module-level functions that delegate to class)
# -----------------------------------------------------------------------------

# Get current local datetime
func now()
    return DateTime.now()
endfunc

# Get current UTC datetime
func utcNow()
    return DateTime.utcNow()
endfunc

# Get today at midnight
func today()
    return DateTime.today()
endfunc

# Get current timestamp in milliseconds
func timestamp()
    return DateTime.timestamp()
endfunc

# Create datetime from timestamp (milliseconds)
func fromTimestamp(ts)
    return DateTime.fromTimestamp(ts)
endfunc

# Create datetime from Unix timestamp (seconds)
func fromUnix(unix)
    return DateTime.fromUnix(unix)
endfunc

# Parse datetime from string
func parse(str, format)
    return DateTime.parse(str, format)
endfunc

# Parse ISO 8601 datetime string
func parseIso(str)
    return DateTime.parseIso(str)
endfunc

# Check if year is leap year
func isLeapYear(year)
    return DateTime.isLeapYear(year)
endfunc

# Get days in month
func daysInMonth(year, month)
    return DateTime.daysInMonth(year, month)
endfunc

# Sleep for specified duration
func sleep(duration)
    DateTime.sleep(duration)
endfunc

# Sleep for seconds
func sleepSeconds(seconds)
    DateTime.sleepSeconds(seconds)
endfunc

# Create duration from components
func duration(days, hours, minutes, seconds, milliseconds)
    return Duration.fromComponents(days, hours, minutes, seconds, milliseconds)
endfunc

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Pad string on left
func padLeft(str, length, char)
    while len(str) < length
        str = char + str
    endwhile
    return str
endfunc

# Pad string on right
func padRight(str, length, char)
    while len(str) < length
        str = str + char
    endwhile
    return str
endfunc

# Floor function
func floor(n)
    return int(n)
endfunc

# Ceiling function
func ceil(n)
    i = int(n)
    if n > i
        return i + 1
    endif
    return i
endfunc

# Absolute value
func abs(n)
    if n < 0
        return -n
    endif
    return n
endfunc

# Minimum of two values
func min(a, b)
    if a < b
        return a
    endif
    return b
endfunc

# Maximum of two values
func max(a, b)
    if a > b
        return a
    endif
    return b
endfunc

# Last index of substring
func _lastIndexOf(str, substr)
    lastPos = -1
    pos = 0
    while True
        idx = indexOf(slice(str, pos, len(str)), substr)
        if idx < 0
            break
        endif
        lastPos = pos + idx
        pos = lastPos + 1
    endwhile
    return lastPos
endfunc

print "DateTime module loaded (v0.0.1)"
