#include "calendarconverter.h"

#include <QObject>

int gregorian_months_start[12]      = {0,31,59,90,120,151,181,212,243,273,304,334};
int gregorian_leap_months_start[12] = {0,31,60,91,121,152,182,213,244,274,305,335};

int jalali_months_start[12]      = {0,31,62,93,124,155,186,216,246,276,306,336};
int jalali_leap_months_start[12] = {0,31,62,93,124,155,186,216,246,276,306,336};

int hijri_months_start[12]      = {0,30,59,89,118,148,177,207,236,266,295,325};
int hijri_leap_months_start[12] = {0,30,59,89,118,148,177,207,236,266,295,325};
int hijri_leap_years[11] = {2,5,7,10,13,16,18,21,24,26,29};

class CalendarConverterPrivate
{
public:
    CalendarConverter::CalendarTypes calendar;
};

CalendarConverter::CalendarConverter()
{
    p = new CalendarConverterPrivate;
    p->calendar = CalendarConverter::Gregorian;
}

void CalendarConverter::setCalendar(CalendarConverter::CalendarTypes t)
{
    p->calendar = t;
}

CalendarConverter::CalendarTypes CalendarConverter::calendar() const
{
    return p->calendar;
}

QString CalendarConverter::paperString(const QDateTime &dt)
{
    const DateProperty & dp = getDate(dt.date());
    QString res = QString("%1, %2 %3 %4, %5").arg(dayName(dp.day_of_week)).arg(dp.day).arg(monthName(dp.month)).arg(dp.year).arg(dt.time().toString("hh:mm"));
    return res;
}

QString CalendarConverter::historyString(const QDate &d)
{
    const DateProperty & dp = getDate(d);
    QString res = QString("%1 %2 %3 - %4").arg(dp.year).arg(monthName(dp.month)).arg(dp.day).arg(dayName(dp.day_of_week));
    return res;
}

QString CalendarConverter::numberString(const QDate &d)
{
    const DateProperty & dp = getDate(d);
    QString res = QString("%1 %2 %3 - %4").arg(dp.year).arg(dp.month).arg(dp.day).arg(dayName(dp.day_of_week));
    return res;
}

DateProperty CalendarConverter::getDate(const QDate &d)
{
    DateProperty res;
    switch( static_cast<int>(p->calendar) )
    {
    case CalendarConverter::Gregorian:
        res = toDateGregorian( fromDateGregorian(d.year(),d.month(),d.day()) );
        break;
    case CalendarConverter::Jalali:
        res = toDateJalali( fromDateGregorian(d.year(),d.month(),d.day()) );
        break;
    case CalendarConverter::Hijri:
        res = toDateHijri( fromDateGregorian(d.year(),d.month(),d.day()) );
        break;
    }

    return res;
}

QString CalendarConverter::dayName(int d)
{
    QString res;
    switch( static_cast<int>(p->calendar) )
    {
    case CalendarConverter::Gregorian:
        res = dayNameGregorian(d);
        break;
    case CalendarConverter::Jalali:
        res = dayNameJalali(d);
        break;
    case CalendarConverter::Hijri:
        res = dayNameHijri(d);
        break;
    }

    return res;
}

QString CalendarConverter::monthName(int m)
{
    QString res;
    switch( static_cast<int>(p->calendar) )
    {
    case CalendarConverter::Gregorian:
        res = monthNamesGregorian(m);
        break;
    case CalendarConverter::Jalali:
        res = monthNamesJalali(m);
        break;
    case CalendarConverter::Hijri:
        res = monthNamesHijri(m);
        break;
    }

    return res;
}

bool CalendarConverter::isLeapGregorian( qint64 year )
{
    return (year%4==0 && year%100!=0) || year%400==0;
}

QString CalendarConverter::monthNamesGregorian(int m)
{
    switch( m )
    {
    case 1:
        return QObject::tr("January");
        break;
    case 2:
        return QObject::tr("February");
        break;
    case 3:
        return QObject::tr("March");
        break;
    case 4:
        return QObject::tr("April");
        break;
    case 5:
        return QObject::tr("May");
        break;
    case 6:
        return QObject::tr("June");
        break;
    case 7:
        return QObject::tr("July");
        break;
    case 8:
        return QObject::tr("August");
        break;
    case 9:
        return QObject::tr("September");
        break;
    case 10:
        return QObject::tr("October");
        break;
    case 11:
        return QObject::tr("November");
        break;
    case 12:
        return QObject::tr("December");
        break;
    }

    return QString();
}

QString CalendarConverter::dayNameGregorian(int d)
{
    switch( d )
    {
    case 1:
        return QObject::tr("Sunday");
        break;
    case 2:
        return QObject::tr("Monday");
        break;
    case 3:
        return QObject::tr("Tuesday");
        break;
    case 4:
        return QObject::tr("Wednesday");
        break;
    case 5:
        return QObject::tr("Thuresday");
        break;
    case 6:
        return QObject::tr("Friday");
        break;
    case 7:
        return QObject::tr("Saturday");
        break;
    }

    return QString();
}

qint64 CalendarConverter::fromDateGregorian( qint64 year , int month , int day )
{
    bool leap = isLeapGregorian( year );

    month--;
    day--;

    qint64 leap_pad = (year/4) - (year/100) + (year/400);
    qint64 year_days = year*365 + leap_pad;

    qint16 month_days = (leap)? gregorian_leap_months_start[month] : gregorian_months_start[month];
    qint64 abs_days   = year_days + month_days + day;
    if( year < 0 && !leap )
        abs_days--;

    return abs_days + 0;
}

DateProperty CalendarConverter::toDateGregorian( qint64 days_from_gregorian_zero )
{
    days_from_gregorian_zero -= 0;

    qint64 day     = days_from_gregorian_zero;
    qint64 year    = 0;
    qint16 month   = 0;

    year += day/146097 * 400;
    day   = day%146097;

    if( days_from_gregorian_zero < 0 && day != 0 )
    {
        year -= 400;
        day   = 146097 + day;
    }

    if( day < 36524*3 )
    {
        year += day/36524 * 100;
        day   = day%36524;
    }
    else
    {
        year += 400-100;
        day   = day - 36524*3;
    }

    if( day < 1461*24 )
    {
        year += day/1461 * 4;
        day   = day%1461;
    }
    else
    {
        year += 100-4;
        day   = day - 1461*24;
    }

    if( day < 365*3 )
    {
        year += day/365 * 1;
        day   = day%365;
    }
    else
    {
        year += 4-1;
        day   = day - 365*3;
    }

    day++;

    bool leap = isLeapGregorian(year);
    for( int i=11 ; i>=0 ; i-- )
    {
        qint16 month_day = (leap)? gregorian_leap_months_start[i] : gregorian_months_start[i] ;
        if( day > month_day )
        {
            month = i;
            day  -= month_day;
            break;
        }
    }

    month++;

    DateProperty property;
        property.day = day;
        property.month = month;
        property.year = year;
        property.day_of_week = (days_from_gregorian_zero) % 7;

    if( property.day_of_week < 0 )
        property.day_of_week = 6 + property.day_of_week;
    property.day_of_week++;

    return property;
}

bool CalendarConverter::isLeapJalali( qint64 year )
{
    return (year%4==0 && year%100!=0) || year%400==0;
}

QString CalendarConverter::monthNamesJalali(int m)
{
    switch( m )
    {
    case 1:
        return QObject::tr("Farvardin");
        break;
    case 2:
        return QObject::tr("Ordibehesht");
        break;
    case 3:
        return QObject::tr("Khordad");
        break;
    case 4:
        return QObject::tr("Tir");
        break;
    case 5:
        return QObject::tr("Mordad");
        break;
    case 6:
        return QObject::tr("Shahrivar");
        break;
    case 7:
        return QObject::tr("Mehr");
        break;
    case 8:
        return QObject::tr("Abaan");
        break;
    case 9:
        return QObject::tr("Aazar");
        break;
    case 10:
        return QObject::tr("Dey");
        break;
    case 11:
        return QObject::tr("Bahman");
        break;
    case 12:
        return QObject::tr("Esfand");
        break;
    }

    return QString();
}

QString CalendarConverter::dayNameJalali(int d)
{
    switch( d )
    {
    case 1:
        return QObject::tr("Shanbe");
        break;
    case 2:
        return QObject::tr("1Shanbe");
        break;
    case 3:
        return QObject::tr("2Shanbe");
        break;
    case 4:
        return QObject::tr("3Shanbe");
        break;
    case 5:
        return QObject::tr("4Shanbe");
        break;
    case 6:
        return QObject::tr("5Shanbe");
        break;
    case 7:
        return QObject::tr("Jome");
        break;
    }

    return QString();
}

qint64 CalendarConverter::fromDateJalali( qint64 year , int month , int day )
{
    bool leap = isLeapJalali( year );

    month--;
    day--;

    qint64 leap_pad = (year/4) - (year/100) + (year/400);
    qint64 year_days = year*365 + leap_pad;

    qint16 month_days = (leap)? jalali_leap_months_start[month] : jalali_months_start[month];
    qint64 abs_days   = year_days + month_days + day;
    if( year < 0 && !leap )
        abs_days--;

    return abs_days + 226894;
}

DateProperty CalendarConverter::toDateJalali( qint64 days_from_jalali_zero )
{
    days_from_jalali_zero -= 226894;

    qint64 day     = days_from_jalali_zero;
    qint64 year    = 0;
    qint16 month   = 0;

    year += day/146097 * 400;
    day   = day%146097;

    if( days_from_jalali_zero < 0 && day != 0 )
    {
        year -= 400;
        day   = 146097 + day;
    }

    if( day < 36524*3 )
    {
        year += day/36524 * 100;
        day   = day%36524;
    }
    else
    {
        year += 400-100;
        day   = day - 36524*3;
    }

    if( day < 1461*24 )
    {
        year += day/1461 * 4;
        day   = day%1461;
    }
    else
    {
        year += 100-4;
        day   = day - 1461*24;
    }

    if( day < 365*3 )
    {
        year += day/365 * 1;
        day   = day%365;
    }
    else
    {
        year += 4-1;
        day   = day - 365*3;
    }

    day++;

    bool leap = isLeapJalali(year);
    for( int i=11 ; i>=0 ; i-- )
    {
        qint16 month_day = (leap)? jalali_leap_months_start[i] : jalali_months_start[i] ;
        if( day > month_day )
        {
            month = i;
            day  -= month_day;
            break;
        }
    }

    month++;

    DateProperty property;
        property.day = day;
        property.month = month;
        property.year = year;
        property.day_of_week = (days_from_jalali_zero-3) % 7;

    if( property.day_of_week < 0 )
        property.day_of_week = 6 + property.day_of_week;
    property.day_of_week++;

    return property;
}

int CalendarConverter::leapIndexHijri( qint64 year )
{
    qint8 r = year%30;
    for( int i=0 ; i<11 ; i++ )
        if( r == hijri_leap_years[i] )
            return i;

    return -1;
}

QString CalendarConverter::monthNamesHijri( int m )
{
    switch( m )
    {
    case 1:
        return QObject::tr("Moharram");
        break;
    case 2:
        return QObject::tr("Safar");
        break;
    case 3:
        return QObject::tr("Rabiol Avval");
        break;
    case 4:
        return QObject::tr("Rabio Sani");
        break;
    case 5:
        return QObject::tr("Jamadiol Aval");
        break;
    case 6:
        return QObject::tr("Jamadio Sani");
        break;
    case 7:
        return QObject::tr("Rajab");
        break;
    case 8:
        return QObject::tr("Shaban");
        break;
    case 9:
        return QObject::tr("Ramadan");
        break;
    case 10:
        return QObject::tr("Shaval");
        break;
    case 11:
        return QObject::tr("Zighade");
        break;
    case 12:
        return QObject::tr("Zihaje");
        break;
    }

    return QString();
}

QString CalendarConverter::dayNameHijri(int d)
{
    switch( d )
    {
    case 1:
        return QObject::tr("Saturday");
        break;
    case 2:
        return QObject::tr("Sunday");
        break;
    case 3:
        return QObject::tr("Monday");
        break;
    case 4:
        return QObject::tr("Tuesday");
        break;
    case 5:
        return QObject::tr("Wednesday");
        break;
    case 6:
        return QObject::tr("Thuresday");
        break;
    case 7:
        return QObject::tr("Friday");
        break;
    }

    return QString();
}

qint64 CalendarConverter::leapsNumberHijri( qint64 year )
{
    qint8 r = year%30;
    for( int i=0 ; i<11 ; i++ )
        if( r <= hijri_leap_years[i] )
            return 11 * (year/30) + i + (r==hijri_leap_years[i]);

    return 0;
}

qint64 CalendarConverter::fromDateHijri( qint64 year , int month , int day )
{
    int leap_index = leapIndexHijri( year );
    bool leap = leap_index != -1;

    month--;
    day--;

    qint64 leap_pad = leapsNumberHijri(year);

    qint64 year_days = year*354 + leap_pad;

    qint16 month_days = (leap)? hijri_leap_months_start[month] : hijri_months_start[month];
    qint64 abs_days   = year_days + month_days + day;
    if( year < 0 && !leap )
        abs_days-=11;
    if( year >= 0 && leap )
        abs_days--;

    return abs_days+227026;
}

DateProperty CalendarConverter::toDateHijri( qint64 days_from_hijri_zero )
{
    days_from_hijri_zero -= 227026;

    qint64 day     = days_from_hijri_zero;
    qint64 year    = 0;
    qint16 month   = 0;

    year += day/10631 * 30;
    day   = day%10631;

    if( days_from_hijri_zero < 0 && day != 0 )
    {
        year -= 30;
        day   = 10631 + day;
    }

    for( int i=0 ; i<30 ; i++ )
    {
        int leap = leapIndexHijri( year );
        int year_days = (leap==-1)?354:355;
        if( day < year_days )
            break;

        year += 1;
        day  -= year_days;
    }

    day++;

    int leap_number = leapIndexHijri( year );
    bool leap = (leap_number!=-1);
    for( int i=11 ; i>=0 ; i-- )
    {
        qint16 month_day = (leap)? hijri_leap_months_start[i] : hijri_months_start[i] ;
        if( day > month_day )
        {
            month = i;
            day  -= month_day;
            break;
        }
    }

    month++;

    DateProperty property;
        property.day = day;
        property.month = month;
        property.year = year;
        property.day_of_week = (days_from_hijri_zero-4) % 7;

    if( property.day_of_week < 0 )
        property.day_of_week = 6 + property.day_of_week;
    property.day_of_week++;

    return property;
}

CalendarConverter::~CalendarConverter()
{
    delete p;
}