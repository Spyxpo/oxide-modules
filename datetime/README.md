# DateTime Module for Oxide

Cross-platform date and time module for Oxide. Parse, format, and manipulate dates and times with ease.

## Overview

The datetime module provides a comprehensive API for working with dates and times in Oxide applications. It offers class-based static methods for cleaner, more organized code.

## Installation

```bash
oxide install datetime
```

## Quick Start

```oxide
use datetime

# Get current date/time using static methods
dt = DateTime.now()
print dt.format("%Y-%m-%d %H:%M:%S")

# Parse a date string
birthday = DateTime.parse("1990-05-15", "%Y-%m-%d")
print birthday.year()  # 1990

# Date arithmetic
tomorrow = DateTime.today().addDays(1)
nextWeek = DateTime.today().addDays(7)
```

## Usage Examples

### Current Date and Time

```oxide
use datetime

# Current local time
current = DateTime.now()
print "Now: " + current.format("%Y-%m-%d %H:%M:%S")

# Current UTC time
utc = DateTime.utcNow()
print "UTC: " + utc.toIso()

# Today's date (midnight)
date = DateTime.today()
print "Today: " + date.format("%Y-%m-%d")
```

### Creating DateTime Objects

```oxide
use datetime

# From components
dt = new DateTime(2024, 12, 25, 10, 30, 0)
print dt.format("%B %d, %Y")  # December 25, 2024

# From timestamp (milliseconds)
dt = DateTime.fromTimestamp(1703505600000)

# From Unix timestamp (seconds)
dt = DateTime.fromUnix(1703505600)

# From ISO string
dt = DateTime.parseIso("2024-12-25T10:30:00Z")

# From custom format
dt = DateTime.parse("25/12/2024", "%d/%m/%Y")
```

### Formatting Dates

```oxide
use datetime

dt = DateTime.now()

# Common formats
print dt.format("%Y-%m-%d")        # 2024-01-17
print dt.format("%d/%m/%Y")        # 17/01/2024
print dt.format("%B %d, %Y")       # January 17, 2024
print dt.format("%H:%M:%S")        # 14:30:45
print dt.format("%I:%M %p")        # 02:30 PM
print dt.format("%A, %B %d")       # Wednesday, January 17

# ISO format
print dt.toIso()                   # 2024-01-17T14:30:45.000Z

# Predefined formats
print dt.format(FORMAT_DATE)       # 2024-01-17
print dt.format(FORMAT_TIME)       # 14:30:45
print dt.format(FORMAT_DATETIME)   # 2024-01-17 14:30:45
```

### Format Specifiers

| Specifier | Description | Example |
|-----------|-------------|---------|
| `%Y` | 4-digit year | 2024 |
| `%y` | 2-digit year | 24 |
| `%m` | Month (01-12) | 01 |
| `%d` | Day (01-31) | 17 |
| `%H` | Hour 24h (00-23) | 14 |
| `%I` | Hour 12h (01-12) | 02 |
| `%M` | Minute (00-59) | 30 |
| `%S` | Second (00-59) | 45 |
| `%f` | Milliseconds | 123 |
| `%p` | AM/PM | PM |
| `%A` | Full weekday | Wednesday |
| `%a` | Short weekday | Wed |
| `%B` | Full month | January |
| `%b` | Short month | Jan |
| `%j` | Day of year | 017 |
| `%w` | Weekday (0-6) | 3 |
| `%Z` | Timezone | UTC |

### Accessing Components

```oxide
use datetime

dt = DateTime.now()

# Date components
print dt.year()         # 2024
print dt.month()        # 1
print dt.day()          # 17
print dt.hour()         # 14
print dt.minute()       # 30
print dt.second()       # 45
print dt.millisecond()  # 123

# Week/Day info
print dt.weekday()      # 3 (Wednesday, 0=Sunday)
print dt.dayOfWeek()    # "Wednesday"
print dt.dayOfYear()    # 17
print dt.weekOfYear()   # 3

# Is checks
print dt.isLeapYear()   # True/False
print dt.isWeekend()    # True/False
print dt.isToday()      # True/False
```

### Date Arithmetic

```oxide
use datetime

dt = DateTime.now()

# Add time
tomorrow = dt.addDays(1)
nextWeek = dt.addDays(7)
nextMonth = dt.addMonths(1)
nextYear = dt.addYears(1)

# Add time components
later = dt.addHours(3)
later = dt.addMinutes(30)
later = dt.addSeconds(45)

# Subtract (use negative values)
yesterday = dt.addDays(-1)
lastWeek = dt.addDays(-7)
lastMonth = dt.addMonths(-1)

# Start/End of periods
startOfDay = dt.startOfDay()
endOfDay = dt.endOfDay()
startOfMonth = dt.startOfMonth()
endOfMonth = dt.endOfMonth()
startOfYear = dt.startOfYear()
```

### Comparing Dates

```oxide
use datetime

date1 = DateTime.parse("2024-01-15", "%Y-%m-%d")
date2 = DateTime.parse("2024-01-20", "%Y-%m-%d")

# Comparisons
print date1.isBefore(date2)   # True
print date1.isAfter(date2)    # False
print date1.equals(date2)     # False

# Difference
diff = date1.diff(date2)
print diff.days               # -5
print diff.hours              # -120
print diff.totalSeconds       # -432000

# Between check
middle = DateTime.parse("2024-01-17", "%Y-%m-%d")
print middle.isBetween(date1, date2)  # True
```

### Duration

```oxide
use datetime

# Create duration using static method
dur = Duration.fromComponents(5, 3, 30, 0, 0)  # 5 days, 3 hours, 30 minutes

# From difference
start = DateTime.parse("2024-01-01", "%Y-%m-%d")
end = DateTime.parse("2024-01-10", "%Y-%m-%d")
dur = start.diff(end)

# Access components
print dur.days()        # 9
print dur.hours()       # 216
print dur.minutes()     # 12960
print dur.seconds()     # 777600

# Human readable
print dur.humanize()  # "9 days"

# Arithmetic with duration
future = DateTime.now().add(dur)
```

### Timezone Support

```oxide
use datetime

dt = DateTime.now()

# Convert to UTC
utc = dt.toUtc()

# Convert to local
local = dt.toLocal()

# Get timezone info
print dt.timezone()       # "America/New_York"
print dt.utcOffset()      # -5 (hours)

# Create with specific timezone
dt = new DateTime(2024, 1, 17, 12, 0, 0, "Europe/London")
```

### Unix Timestamps

```oxide
use datetime

# Current Unix timestamp
ts = DateTime.timestamp()
print ts  # 1705505445123 (milliseconds)

# Unix timestamp in seconds
unix = DateTime.now().toUnix()
print unix  # 1705505445

# From Unix timestamp
dt = DateTime.fromUnix(1705505445)
dt = DateTime.fromTimestamp(1705505445123)
```

### Relative Time

```oxide
use datetime

dt = DateTime.now().addHours(-2)
print dt.fromNow()      # "2 hours ago"

dt = DateTime.now().addDays(3)
print dt.fromNow()      # "in 3 days"

dt = DateTime.now().addMinutes(-5)
print dt.fromNow()      # "5 minutes ago"
```

### Calendar Operations

```oxide
use datetime

dt = DateTime.now()

# Days in month
print DateTime.daysInMonth(2024, 2)  # 29 (leap year)
print DateTime.daysInMonth(2023, 2)  # 28

# Is leap year
print DateTime.isLeapYear(2024)      # True
print DateTime.isLeapYear(2023)      # False

# Week number
print dt.weekOfYear()       # 3

# Quarter
print dt.quarter()          # 1
```

## API Reference

### DateTime Static Methods

| Method | Description |
|--------|-------------|
| `DateTime.now()` | Current local datetime |
| `DateTime.utcNow()` | Current UTC datetime |
| `DateTime.today()` | Today at midnight |
| `DateTime.timestamp()` | Current timestamp in ms |
| `DateTime.parse(str, format)` | Parse string to DateTime |
| `DateTime.parseIso(str)` | Parse ISO 8601 string |
| `DateTime.fromTimestamp(ms)` | Create from milliseconds |
| `DateTime.fromUnix(seconds)` | Create from Unix timestamp |
| `DateTime.isLeapYear(year)` | Check if year is leap |
| `DateTime.daysInMonth(year, month)` | Days in month |
| `DateTime.sleep(duration)` | Sleep for duration |
| `DateTime.sleepSeconds(seconds)` | Sleep for seconds |

### Duration Static Methods

| Method | Description |
|--------|-------------|
| `Duration.fromComponents(days, hours, mins, secs, ms)` | Create duration from components |

### DateTime Class

#### Constructor
```oxide
new DateTime(year, month, day, hour, minute, second, timezone)
```

#### Properties
| Method | Description |
|--------|-------------|
| `year()` | Get year |
| `month()` | Get month (1-12) |
| `day()` | Get day (1-31) |
| `hour()` | Get hour (0-23) |
| `minute()` | Get minute (0-59) |
| `second()` | Get second (0-59) |
| `millisecond()` | Get milliseconds |
| `weekday()` | Get weekday (0-6) |
| `dayOfWeek()` | Get weekday name |
| `dayOfYear()` | Get day of year |
| `weekOfYear()` | Get week number |
| `quarter()` | Get quarter (1-4) |

#### Formatting
| Method | Description |
|--------|-------------|
| `format(pattern)` | Format to string |
| `toIso()` | Format as ISO 8601 |
| `toUnix()` | Get Unix timestamp |
| `toTimestamp()` | Get timestamp (ms) |

#### Arithmetic
| Method | Description |
|--------|-------------|
| `addDays(n)` | Add/subtract days |
| `addMonths(n)` | Add/subtract months |
| `addYears(n)` | Add/subtract years |
| `addHours(n)` | Add/subtract hours |
| `addMinutes(n)` | Add/subtract minutes |
| `addSeconds(n)` | Add/subtract seconds |
| `add(duration)` | Add duration |

#### Comparison
| Method | Description |
|--------|-------------|
| `isBefore(other)` | Check if before |
| `isAfter(other)` | Check if after |
| `equals(other)` | Check if equal |
| `diff(other)` | Get difference as Duration |
| `isBetween(start, end)` | Check if between |

#### Periods
| Method | Description |
|--------|-------------|
| `startOfDay()` | Start of day (00:00:00) |
| `endOfDay()` | End of day (23:59:59) |
| `startOfMonth()` | First day of month |
| `endOfMonth()` | Last day of month |
| `startOfYear()` | First day of year |

#### Timezone
| Method | Description |
|--------|-------------|
| `toUtc()` | Convert to UTC |
| `toLocal()` | Convert to local |
| `timezone()` | Get timezone name |
| `utcOffset()` | Get UTC offset (hours) |

### Duration Class

| Method | Description |
|--------|-------------|
| `days` | Total days |
| `hours` | Total hours |
| `minutes` | Total minutes |
| `seconds` | Total seconds |
| `milliseconds` | Total milliseconds |
| `humanize()` | Human readable string |

### Format Constants

| Constant | Pattern |
|----------|---------|
| `FORMAT_DATE` | `%Y-%m-%d` |
| `FORMAT_TIME` | `%H:%M:%S` |
| `FORMAT_DATETIME` | `%Y-%m-%d %H:%M:%S` |
| `FORMAT_ISO` | ISO 8601 |
| `FORMAT_RFC2822` | RFC 2822 |

## Building the Native Library

If you need to compile the native library yourself:

### macOS
```bash
cd ~/.oxide/modules/datetime/src
clang -shared -o ../liboxide_datetime.dylib oxide_datetime.c
```

### Linux
```bash
cd ~/.oxide/modules/datetime/src
gcc -shared -fPIC -o ../liboxide_datetime.so oxide_datetime.c
```

### Windows
```bash
cl /LD oxide_datetime.c /Fe:oxide_datetime.dll
```

## License

MIT License

## Author

Oxide Team
