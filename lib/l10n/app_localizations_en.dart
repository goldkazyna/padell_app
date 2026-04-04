// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Padel KZ';

  @override
  String get navHome => 'Home';

  @override
  String get navTournaments => 'Tournaments';

  @override
  String get navChallenges => 'Challenges';

  @override
  String get navRating => 'Rating';

  @override
  String get navProfile => 'Profile';

  @override
  String hello(String name) {
    return 'Hi, $name!';
  }

  @override
  String get welcome => 'Welcome';

  @override
  String get bookCourt => 'Book a Court';

  @override
  String get bookCourtSubtitle => 'Choose a club and time';

  @override
  String get nearestTournament => 'Nearest Tournament';

  @override
  String get activeTournament => 'Active Tournament';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get all => 'All';

  @override
  String get rating => 'RATING';

  @override
  String get level => 'LEVEL';

  @override
  String get place => 'RANK';

  @override
  String get matches => 'MATCHES';

  @override
  String get wins => 'WINS';

  @override
  String get winrate => 'WIN RATE';

  @override
  String get selectClub => 'Select Club';

  @override
  String get searchClub => 'Search club...';

  @override
  String get allCities => 'All';

  @override
  String courtsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'courts',
      one: 'court',
    );
    return '$count $_temp0';
  }

  @override
  String priceFrom(String price) {
    return 'from $price ₸';
  }

  @override
  String get noClubsFound => 'No clubs found';

  @override
  String get booking => 'Booking';

  @override
  String get court => 'Court';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get start => 'Start';

  @override
  String get duration => 'Duration';

  @override
  String get total => 'Total';

  @override
  String get coach => 'Coach';

  @override
  String get coachOptional => 'Coach (optional)';

  @override
  String get yourName => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get comment => 'Comment';

  @override
  String get optional => 'Optional';

  @override
  String get enterName => 'Enter name';

  @override
  String bookButton(String price) {
    return 'Book — $price ₸';
  }

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get bookingConfirmedSubtitle => 'You have successfully booked a court';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get goHome => 'Go Home';

  @override
  String get upcomingBookings => 'Upcoming';

  @override
  String get pastBookings => 'Past';

  @override
  String get noUpcomingBookings => 'No upcoming bookings';

  @override
  String get noPastBookings => 'No past bookings';

  @override
  String get statusPending => 'New request';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelBooking => 'Cancel booking?';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get yesCancelIt => 'Yes, cancel';

  @override
  String get bookingCancelled => 'Booking cancelled';

  @override
  String get cancelError => 'Cancel error';

  @override
  String get occupied => 'Occupied';

  @override
  String get blocked => 'Blocked';

  @override
  String get free => 'Free';

  @override
  String get noCourtsAvailable => 'No courts available';

  @override
  String get noSlotsForDay => 'No slots for this day';

  @override
  String get today => 'Today';

  @override
  String get hourOne => 'hour';

  @override
  String get hourFew => 'hours';

  @override
  String get hourMany => 'hours';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get bookedCourts => 'Booked courts';

  @override
  String get logout => 'Log out';

  @override
  String get logoutSubtitle => 'Sign out of account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Permanent deletion';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get networkError => 'Network error. Check your internet connection.';

  @override
  String get loadError => 'Failed to load data';

  @override
  String get language => 'Language';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';
}
