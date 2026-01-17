# Changelog

All notable changes to the Datetime module will be documented in this file.

## [0.0.1] - 2025-01-17

### Added

- Initial release of the Datetime module
- `DateTime` class for date/time manipulation
- Core functions: `now()`, `today()`, `utcNow()`
- Timestamp functions: `timestamp()`, `fromTimestamp()`
- Parsing: `parse()` with multiple format support
- Formatting: `format()` with strftime-style patterns
- Date components: `year()`, `month()`, `day()`, `hour()`, `minute()`, `second()`, `millisecond()`
- Day of week functions: `weekday()`, `dayOfWeek()`, `dayOfYear()`
- Arithmetic: `addDays()`, `addMonths()`, `addYears()`, `addHours()`, `addMinutes()`, `addSeconds()`
- Comparison: `isBefore()`, `isAfter()`, `equals()`, `diff()`
- Timezone support: `toUtc()`, `toLocal()`, `timezone()`
- ISO format: `toIso()`, `parseIso()`
- Unix timestamp: `toUnix()`, `fromUnix()`
- Duration class for time intervals
- Convenience constants for common formats
- Cross-platform native implementation (macOS, Linux, Windows)
