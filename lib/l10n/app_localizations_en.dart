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

  @override
  String get register => 'Register';

  @override
  String get registered => 'Registered';

  @override
  String levelShort(String level) {
    return 'Lvl. $level';
  }

  @override
  String get noAvailableTournaments => 'No available tournaments';

  @override
  String get notInTournaments => 'You are not in any tournaments';

  @override
  String get noUpcomingTournaments => 'No upcoming tournaments';

  @override
  String get tournaments => 'Tournaments';

  @override
  String get openTab => 'Open';

  @override
  String get myTab => 'My';

  @override
  String get archiveTab => 'Archive';

  @override
  String get noOpenTournaments => 'No open tournaments';

  @override
  String get notRegisteredForTournaments =>
      'You are not registered for any tournaments';

  @override
  String get noFinishedTournaments => 'No finished tournaments';

  @override
  String get tournamentRegistered => 'Registered';

  @override
  String get noSpotsLeft => 'No spots';

  @override
  String get failedToLoadTournament => 'Failed to load tournament';

  @override
  String shareFreeSpots(int count) {
    return 'Free spots: $count';
  }

  @override
  String shareLevel(String level) {
    return 'Level: $level';
  }

  @override
  String shareCost(String cost) {
    return 'Cost: $cost';
  }

  @override
  String get shareAppPromo =>
      'Padel KZ — download the app and register for tournaments!';

  @override
  String get noSpotsLeftUpper => 'NO SPOTS';

  @override
  String get dateLabel => 'DATE';

  @override
  String get timeLabel => 'TIME';

  @override
  String get levelLabel => 'LEVEL';

  @override
  String get costLabel => 'COST';

  @override
  String get perPerson => 'per person';

  @override
  String get pay => 'Pay';

  @override
  String get pendingModeration => 'Pending moderation';

  @override
  String get participants => 'Participants';

  @override
  String countOfMax(int count, int max) {
    return '$count of $max';
  }

  @override
  String get noParticipantsYet => 'No participants yet';

  @override
  String spotsLeftCount(int count) {
    return '$count more spots available';
  }

  @override
  String get pendingStatus => 'Pending';

  @override
  String get organizer => 'Organizer';

  @override
  String get registerButton => 'Register';

  @override
  String get applicationPending => 'Application pending';

  @override
  String get cancelApplication => 'Cancel application';

  @override
  String get cancelRegistration => 'Cancel registration';

  @override
  String get youAreParticipating => 'You are participating';

  @override
  String get ok => 'OK';

  @override
  String get choosePartner => 'Choose partner';

  @override
  String get subscriptionActive => 'Subscription active';

  @override
  String get notifyOnFreeSpot => 'Notify when spot opens';

  @override
  String get matchesLabel => 'MATCHES';

  @override
  String get winsLabel => 'WINS';

  @override
  String get ratingLabel => 'RATING';

  @override
  String get matchesTitle => 'Matches';

  @override
  String roundsCount(int count) {
    return '$count rounds';
  }

  @override
  String get resultDraw => 'DRAW';

  @override
  String get resultWin => 'WIN';

  @override
  String get resultLoss => 'LOSS';

  @override
  String placeResult(int place) {
    return '$place place';
  }

  @override
  String get teamConfirmed => 'Confirmed';

  @override
  String get yourTeam => 'Your team';

  @override
  String get teams => 'Teams';

  @override
  String get noTeamsYet => 'No teams yet';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get playersNotFound => 'Players not found';

  @override
  String registerWith(String name) {
    return 'Register with $name';
  }
}
