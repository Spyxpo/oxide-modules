/*
 * Oxide DateTime Module - Native Implementation
 * Cross-platform date and time functions for Oxide applications.
 *
 * Compile:
 *   macOS:   clang -shared -o liboxide_datetime.dylib oxide_datetime.c
 *   Linux:   gcc -shared -fPIC -o liboxide_datetime.so oxide_datetime.c
 *   Windows: cl /LD oxide_datetime.c /Fe:oxide_datetime.dll
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef _WIN32
    #define OXIDE_EXPORT __declspec(dllexport)
    #include <windows.h>
    #include <sysinfoapi.h>
#else
    #define OXIDE_EXPORT
    #include <sys/time.h>
    #include <unistd.h>
#endif

/* =============================================================================
 * Timestamp Functions
 * ============================================================================= */

/* Get current timestamp in milliseconds since epoch */
OXIDE_EXPORT long long datetime_timestamp(void) {
#ifdef _WIN32
    FILETIME ft;
    ULARGE_INTEGER uli;
    GetSystemTimeAsFileTime(&ft);
    uli.LowPart = ft.dwLowDateTime;
    uli.HighPart = ft.dwHighDateTime;
    /* Convert from 100-nanosecond intervals since 1601 to milliseconds since 1970 */
    return (long long)((uli.QuadPart - 116444736000000000ULL) / 10000);
#else
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (long long)tv.tv_sec * 1000 + tv.tv_usec / 1000;
#endif
}

/* =============================================================================
 * Local Time Functions
 * ============================================================================= */

/* Get current local year */
OXIDE_EXPORT long long datetime_now_year(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_year + 1900;
}

/* Get current local month (1-12) */
OXIDE_EXPORT long long datetime_now_month(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_mon + 1;
}

/* Get current local day (1-31) */
OXIDE_EXPORT long long datetime_now_day(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_mday;
}

/* Get current local hour (0-23) */
OXIDE_EXPORT long long datetime_now_hour(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_hour;
}

/* Get current local minute (0-59) */
OXIDE_EXPORT long long datetime_now_minute(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_min;
}

/* Get current local second (0-59) */
OXIDE_EXPORT long long datetime_now_second(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_sec;
}

/* Get current millisecond (0-999) */
OXIDE_EXPORT long long datetime_now_millisecond(void) {
#ifdef _WIN32
    SYSTEMTIME st;
    GetLocalTime(&st);
    return st.wMilliseconds;
#else
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_usec / 1000;
#endif
}

/* Get current local weekday (0=Sunday, 6=Saturday) */
OXIDE_EXPORT long long datetime_now_weekday(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_wday;
}

/* Get current day of year (1-366) */
OXIDE_EXPORT long long datetime_now_yearday(void) {
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    return tm->tm_yday + 1;
}

/* =============================================================================
 * UTC Time Functions
 * ============================================================================= */

/* Get current UTC year */
OXIDE_EXPORT long long datetime_utc_year(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_year + 1900;
}

/* Get current UTC month (1-12) */
OXIDE_EXPORT long long datetime_utc_month(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_mon + 1;
}

/* Get current UTC day (1-31) */
OXIDE_EXPORT long long datetime_utc_day(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_mday;
}

/* Get current UTC hour (0-23) */
OXIDE_EXPORT long long datetime_utc_hour(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_hour;
}

/* Get current UTC minute (0-59) */
OXIDE_EXPORT long long datetime_utc_minute(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_min;
}

/* Get current UTC second (0-59) */
OXIDE_EXPORT long long datetime_utc_second(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_sec;
}

/* Get current UTC weekday (0=Sunday, 6=Saturday) */
OXIDE_EXPORT long long datetime_utc_weekday(void) {
    time_t t = time(NULL);
    struct tm* tm = gmtime(&t);
    return tm->tm_wday;
}

/* =============================================================================
 * Timezone Functions
 * ============================================================================= */

/* Get timezone offset in seconds from UTC */
OXIDE_EXPORT long long datetime_timezone_offset(void) {
#ifdef _WIN32
    TIME_ZONE_INFORMATION tzi;
    DWORD result = GetTimeZoneInformation(&tzi);
    long long bias = tzi.Bias;
    if (result == TIME_ZONE_ID_DAYLIGHT) {
        bias += tzi.DaylightBias;
    } else if (result == TIME_ZONE_ID_STANDARD) {
        bias += tzi.StandardBias;
    }
    /* Bias is in minutes, convert to seconds, and negate (Windows uses positive = west of UTC) */
    return -bias * 60;
#else
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    #ifdef __APPLE__
        return tm->tm_gmtoff;
    #else
        /* Linux */
        return tm->tm_gmtoff;
    #endif
#endif
}

static char timezone_buffer[64] = {0};

/* Get timezone name */
OXIDE_EXPORT const char* datetime_timezone_name(void) {
#ifdef _WIN32
    TIME_ZONE_INFORMATION tzi;
    DWORD result = GetTimeZoneInformation(&tzi);
    if (result == TIME_ZONE_ID_DAYLIGHT) {
        wcstombs(timezone_buffer, tzi.DaylightName, sizeof(timezone_buffer) - 1);
    } else {
        wcstombs(timezone_buffer, tzi.StandardName, sizeof(timezone_buffer) - 1);
    }
    return timezone_buffer;
#else
    time_t t = time(NULL);
    struct tm* tm = localtime(&t);
    strncpy(timezone_buffer, tm->tm_zone ? tm->tm_zone : "UTC", sizeof(timezone_buffer) - 1);
    return timezone_buffer;
#endif
}

/* =============================================================================
 * Timestamp to Components Functions
 * ============================================================================= */

/* Convert timestamp (ms) to year */
OXIDE_EXPORT long long datetime_ts_to_year(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_year + 1900;
}

/* Convert timestamp (ms) to month (1-12) */
OXIDE_EXPORT long long datetime_ts_to_month(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_mon + 1;
}

/* Convert timestamp (ms) to day (1-31) */
OXIDE_EXPORT long long datetime_ts_to_day(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_mday;
}

/* Convert timestamp (ms) to hour (0-23) */
OXIDE_EXPORT long long datetime_ts_to_hour(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_hour;
}

/* Convert timestamp (ms) to minute (0-59) */
OXIDE_EXPORT long long datetime_ts_to_minute(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_min;
}

/* Convert timestamp (ms) to second (0-59) */
OXIDE_EXPORT long long datetime_ts_to_second(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_sec;
}

/* Convert timestamp (ms) to weekday (0=Sunday, 6=Saturday) */
OXIDE_EXPORT long long datetime_ts_to_weekday(long long ts) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    return tm->tm_wday;
}

/* =============================================================================
 * Components to Timestamp Functions
 * ============================================================================= */

/* Convert date/time components to Unix timestamp (seconds) */
OXIDE_EXPORT long long datetime_components_to_ts(long long year, long long month, long long day,
                                                  long long hour, long long minute, long long second) {
    struct tm tm = {0};
    tm.tm_year = (int)(year - 1900);
    tm.tm_mon = (int)(month - 1);
    tm.tm_mday = (int)day;
    tm.tm_hour = (int)hour;
    tm.tm_min = (int)minute;
    tm.tm_sec = (int)second;
    tm.tm_isdst = -1;  /* Let the system determine DST */

    time_t t = mktime(&tm);
    return (long long)t;
}

/* =============================================================================
 * Sleep Functions
 * ============================================================================= */

/* Sleep for specified milliseconds */
OXIDE_EXPORT void datetime_sleep_ms(long long ms) {
#ifdef _WIN32
    Sleep((DWORD)ms);
#else
    usleep((useconds_t)(ms * 1000));
#endif
}

/* =============================================================================
 * Utility Functions
 * ============================================================================= */

/* Check if year is leap year */
OXIDE_EXPORT long long datetime_is_leap_year(long long year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

/* Get days in month */
OXIDE_EXPORT long long datetime_days_in_month(long long year, long long month) {
    static const int days[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if (month == 2 && datetime_is_leap_year(year)) {
        return 29;
    }
    if (month >= 1 && month <= 12) {
        return days[month];
    }
    return 0;
}

/* Get day of year (1-366) */
OXIDE_EXPORT long long datetime_day_of_year(long long year, long long month, long long day) {
    static const int days[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    long long total = 0;
    for (int i = 1; i < month; i++) {
        total += days[i];
        if (i == 2 && datetime_is_leap_year(year)) {
            total += 1;
        }
    }
    return total + day;
}

/* Get week of year (1-53) */
OXIDE_EXPORT long long datetime_week_of_year(long long year, long long month, long long day) {
    long long doy = datetime_day_of_year(year, month, day);
    return (doy + 6) / 7;
}

/* =============================================================================
 * Formatting Functions (optional native implementation)
 * ============================================================================= */

static char format_buffer[256] = {0};

/* Format timestamp to string using strftime format */
OXIDE_EXPORT const char* datetime_format(long long ts, const char* format) {
    time_t t = (time_t)(ts / 1000);
    struct tm* tm = localtime(&t);
    strftime(format_buffer, sizeof(format_buffer), format, tm);
    return format_buffer;
}

/* Format timestamp to ISO 8601 string */
OXIDE_EXPORT const char* datetime_to_iso(long long ts) {
    time_t t = (time_t)(ts / 1000);
    long long ms = ts % 1000;
    struct tm* tm = gmtime(&t);
    snprintf(format_buffer, sizeof(format_buffer),
             "%04d-%02d-%02dT%02d:%02d:%02d.%03lldZ",
             tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
             tm->tm_hour, tm->tm_min, tm->tm_sec, ms);
    return format_buffer;
}
