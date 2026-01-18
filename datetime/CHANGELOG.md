# Changelog

All notable changes to the Datetime module will be documented in this file.

## [0.0.1] - 2025-01-18

### Added

- Initial release of the Datetime module with OOP pattern
- `DateTime` class for date/time manipulation
- Static factory methods: `DateTime.create()`, `DateTime.now()`, `DateTime.utcNow()`, `DateTime.today()`
- Static methods: `DateTime.timestamp()`, `DateTime.fromTimestamp()`, `DateTime.fromUnix()`, `DateTime.parse()`, `DateTime.parseIso()`, `DateTime.isLeapYear()`, `DateTime.daysInMonth()`, `DateTime.sleep()`, `DateTime.sleepSeconds()`
- `Duration` class for time intervals with static method `Duration.fromComponents()`
- Parsing: `parse()` with multiple format support
- Formatting: `format()` with strftime-style patterns
- Date components: `year()`, `month()`, `day()`, `hour()`, `minute()`, `second()`, `millisecond()`
- Day of week functions: `weekday()`, `dayOfWeek()`, `dayOfYear()`
- Arithmetic: `addDays()`, `addMonths()`, `addYears()`, `addHours()`, `addMinutes()`, `addSeconds()`
- Comparison: `isBefore()`, `isAfter()`, `equals()`, `diff()`
- Timezone support: `toUtc()`, `toLocal()`, `timezone()`
- ISO format: `toIso()`, `parseIso()`
- Unix timestamp: `toUnix()`, `fromUnix()`
- Convenience constants for common formats
- Cross-platform native implementation (macOS, Linux, Windows)

### Usage

```oxide
use datetime

dt = DateTime.now()
print dt.format("%Y-%m-%d %H:%M:%S")

# Create specific date
birthday = DateTime.create(1990, 5, 15, 0, 0, 0, 0)
print birthday.format("%B %d, %Y")
```
