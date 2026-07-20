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
  String get navChallenges => 'Game';

  @override
  String get navBooking => 'Booking';

  @override
  String get ratingTabRating => 'Rating';

  @override
  String get ratingTabGrowth => 'Growth';

  @override
  String get ratingTabTournaments => 'Tournaments';

  @override
  String get growthPeriodWeek => 'Week';

  @override
  String get growthPeriodMonth => 'Month';

  @override
  String get growthPeriodAll => 'All time';

  @override
  String growthPoints(int points) {
    return '+$points';
  }

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
  String get activeTournament => 'Live Tournament';

  @override
  String get nearestTournamentInfo =>
      'This shows your nearest tournament that you are registered for and that hasn\'t started yet.';

  @override
  String get activeTournamentInfo =>
      'This shows the tournament you are participating in that is happening right now. Open it to follow the matches and score live, in real time.';

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
  String get losses => 'LOSSES';

  @override
  String levelProgressLabel(String from, String to) {
    return 'Level $from → $to';
  }

  @override
  String get weekdayShortMon => 'MO';

  @override
  String get weekdayShortTue => 'TU';

  @override
  String get weekdayShortWed => 'WE';

  @override
  String get weekdayShortThu => 'TH';

  @override
  String get weekdayShortFri => 'FR';

  @override
  String get weekdayShortSat => 'SA';

  @override
  String get weekdayShortSun => 'SU';

  @override
  String get tournamentTypeAmericano => 'Americano';

  @override
  String get tournamentTypeMexicano => 'Mexicano';

  @override
  String get tournamentTypeKingOfCourt => 'King of the Court';

  @override
  String get tournamentTypeBaliKoc => 'King of the Court (Bali Format)';

  @override
  String get tournamentTypeTeam => 'Doubles + Playoff';

  @override
  String get tournamentTypeClassic => 'Classic';

  @override
  String get challengeCreateSubtitle => 'Challenge a player';

  @override
  String get challengesCardTitle => 'Games';

  @override
  String get challengesCardSubtitle => 'All challenges';

  @override
  String get playerStatRating => 'Rating';

  @override
  String get playerStatGames => 'Games';

  @override
  String get playerStatWins => 'Wins';

  @override
  String get playerStatTournaments => 'Tournaments';

  @override
  String get developerLabel => 'Developer';

  @override
  String get filterLevel => 'Level';

  @override
  String get filterMyLevel => 'My level';

  @override
  String get filterFormat => 'Format';

  @override
  String filterFormatWithCount(int count) {
    return 'Format · $count';
  }

  @override
  String get filterDate => 'Date';

  @override
  String get filterDateTomorrow => 'Tomorrow';

  @override
  String get filterDateWeek => 'Week';

  @override
  String get filterClub => 'Club';

  @override
  String filterClubWithCount(int count) {
    return 'Club · $count';
  }

  @override
  String get filterCommunity => 'Community';

  @override
  String get forYouSection => 'For you';

  @override
  String get tournamentLevelLabel => 'Tournament level';

  @override
  String get levelSuits => 'Suits';

  @override
  String get levelDoesNotSuit => 'Doesn\'t suit';

  @override
  String yourLevelMark(String level) {
    return 'you $level';
  }

  @override
  String get notifyButton => 'Notify';

  @override
  String get subscribedButton => 'Subscribed';

  @override
  String get dateAll => 'All dates';

  @override
  String get dateThisWeek => 'This week';

  @override
  String get tournamentStatusDraft => 'Draft';

  @override
  String get tournamentStatusOpen => 'Registration open';

  @override
  String get tournamentStatusClosed => 'Registration closed';

  @override
  String get tournamentStatusInProgress => 'In progress';

  @override
  String get tournamentStatusCompleted => 'Completed';

  @override
  String get tournamentStatusCancelled => 'Cancelled';

  @override
  String get sectionContacts => 'CONTACTS';

  @override
  String get sectionAbout => 'ABOUT YOU';

  @override
  String get sectionGameStyle => 'GAME STYLE';

  @override
  String get nameHint => 'Enter name';

  @override
  String get agePlaceholder => 'Select birth date';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileNameless => 'No name';

  @override
  String get profileFilled => 'Profile is complete';

  @override
  String get profileFillBio =>
      'Add your age and court position so people can find a partner';

  @override
  String get profileFillAge => 'Add your age so it\'s easier to find a partner';

  @override
  String get profileFillPosition => 'Set your court position';

  @override
  String get profileFillHand => 'Add your dominant hand';

  @override
  String get profileFillGender => 'Specify your gender';

  @override
  String get profileFillCity => 'Select your city';

  @override
  String get fieldHand => 'Dominant hand';

  @override
  String get fieldPosition => 'Court position';

  @override
  String get fieldGender => 'Gender';

  @override
  String rankInRatingShort(int n) {
    return '#$n in rating';
  }

  @override
  String ratingValueShort(int n) {
    return '$n rating';
  }

  @override
  String get notFilled => 'Not filled';

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
  String payOnlineButton(String price) {
    return 'Pay online — $price ₸';
  }

  @override
  String get bookWithoutPaymentButton => 'Book without payment';

  @override
  String get onlinePaymentComingSoon => 'Online payment is coming soon';

  @override
  String get agreeWithDocsPrefix => 'I agree to ';

  @override
  String get docOfferAgreement => 'the Offer Agreement';

  @override
  String get docPrivacyPolicy => 'the Privacy Policy';

  @override
  String get docGoodsDescription => 'the Goods and Services Description';

  @override
  String get docCardPayment => 'the Card Payment Terms';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsSubtitle => 'App legal documents';

  @override
  String get docTitleOffer => 'Offer Agreement';

  @override
  String get docTitlePrivacy => 'Privacy Policy';

  @override
  String get docTitleGoods => 'Goods and Services Description';

  @override
  String get docTitleCard => 'Card Payment Terms';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get bookingConfirmedSubtitle => 'You have successfully booked a court';

  @override
  String get paymentNotCompletedTitle => 'Payment not completed';

  @override
  String get paymentNotCompleted =>
      'You didn\'t finish the payment. The booking is saved as unpaid — you can pay later in \"My bookings\" or at the club.';

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
  String get statusNotConfirmed => 'Not confirmed';

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
  String get notifCategoryGeneral => 'General';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsMenuItem => 'Settings';

  @override
  String get settingsMenuItemSubtitle => 'Rating and level display';

  @override
  String get preciseRatingTitle => 'Precise rating values';

  @override
  String get preciseRatingSubtitle =>
      'Show rating and level with two decimals (2.69 instead of 2690)';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get themeSubtitle => 'Light, dark or follow system';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get newsChannelTitle => 'Latest app news';

  @override
  String get newsChannelSubtitle => 'Telegram channel @padelkz_app';

  @override
  String get newsChannelButton => 'Latest app news';

  @override
  String get calendarLink => 'Calendar →';

  @override
  String get calendarTitle => 'Tournament calendar';

  @override
  String get calendarNoTournamentsForDay => 'No tournaments on this day';

  @override
  String get calendarAllTournaments => 'All tournaments →';

  @override
  String calendarSeats(int filled, int max) {
    return '$filled/$max spots';
  }

  @override
  String calendarSeatsLeft(int n) {
    return '$n left';
  }

  @override
  String get calendarTodayDow => 'Today';

  @override
  String get calendarEmptyAll => 'No tournaments in the next 14 days';

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
  String get details => 'Details';

  @override
  String get chooseTournament => 'Choose a tournament';

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
  String get cancelledTab => 'Cancelled';

  @override
  String get noCancelledTournaments => 'No cancelled tournaments';

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
  String clubTournamentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tournaments',
      one: 'tournament',
    );
    return '$count $_temp0';
  }

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
  String get tournamentUnrated => 'UNRATED';

  @override
  String get tournamentVerifiedBadge => 'VERIFIED';

  @override
  String get tournamentVerifiedOnly => 'Verified players only';

  @override
  String get unratedBadge => 'Unrated';

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
  String get enterNameOrPhone => 'Name or phone number';

  @override
  String get playersNotFound => 'Players not found';

  @override
  String registerWith(String name) {
    return 'Register with $name';
  }

  @override
  String get challenge => 'Game';

  @override
  String get challengeHint =>
      'Find opponents and play rated or friendly matches';

  @override
  String get challengeOpenTab => 'Open';

  @override
  String get challengeMyTab => 'My';

  @override
  String get noOpenChallenges => 'No open games';

  @override
  String get noMyChallenges => 'You have no games';

  @override
  String get challengeNotSpecified => 'Not specified';

  @override
  String challengeLevel(String level) {
    return 'Level $level';
  }

  @override
  String get challengeRated => 'Rated';

  @override
  String get challengeFriendly => 'Friendly';

  @override
  String get challengeJoinSlot => 'Join';

  @override
  String get challengeDetails => 'Details';

  @override
  String get challengeChoosePosition => 'Choose position';

  @override
  String get challengePositionHint => 'Positions 1-2 — Team A, 3-4 — Team B';

  @override
  String get challengeTeamA => 'Team A';

  @override
  String get challengeTeamB => 'Team B';

  @override
  String get challengeCancelTitle => 'Cancel game?';

  @override
  String get challengeCancelConfirm =>
      'Are you sure you want to cancel the game?';

  @override
  String get challengeYesCancel => 'Yes, cancel';

  @override
  String get challengeEnterScore => 'Enter score for at least one set';

  @override
  String get challengeNotFound => 'Game not found';

  @override
  String get challengeScore => 'SCORE';

  @override
  String get challengeAddSet => 'Add set';

  @override
  String get challengeFinish => 'Finish game';

  @override
  String get challengeScoreCreatorHint =>
      'The score is entered by the game creator. After completion, you will be able to confirm the result.';

  @override
  String get challengeResult => 'RESULT';

  @override
  String challengeSetScore(int index, int scoreA, int scoreB) {
    return 'Set $index    $scoreA : $scoreB';
  }

  @override
  String get challengeConfirmed => 'Confirmed';

  @override
  String get challengeWaiting => 'Waiting';

  @override
  String get challengeConfirmScore => 'Confirm score';

  @override
  String get challengeScoreConfirmed => 'You confirmed the score';

  @override
  String get challengeTeamAWin => 'Team A wins';

  @override
  String get challengeTeamBWin => 'Team B wins';

  @override
  String get challengeDraw => 'Draw';

  @override
  String challengeSetLabel(int index) {
    return 'Set $index';
  }

  @override
  String get challengeAccept => 'Accept';

  @override
  String get challengeDecline => 'Decline';

  @override
  String get challengeWaitingInvites =>
      'Waiting for invited players to confirm';

  @override
  String challengeNeedMorePlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'players',
      one: 'player',
    );
    return '$count more $_temp0 needed';
  }

  @override
  String get challengeStart => 'Start game';

  @override
  String get challengeCancelButton => 'Cancel game';

  @override
  String get challengeLeave => 'Leave';

  @override
  String get challengeAddPlayer => 'Add player';

  @override
  String challengePositionTeam(int position, String team) {
    return 'Position $position · $team';
  }

  @override
  String get challengePhoneHint => 'Phone number';

  @override
  String get challengeNobodyFound => 'Nobody found';

  @override
  String get challengeLeaveOpen => 'Leave open';

  @override
  String get challengeYou => 'You';

  @override
  String get challengeSpecifyDateTime => 'Specify date and time';

  @override
  String get challengeErrorTitle => 'Error';

  @override
  String get challengeDoneTitle => 'Done';

  @override
  String get challengeMonthJan => 'January';

  @override
  String get challengeMonthFeb => 'February';

  @override
  String get challengeMonthMar => 'March';

  @override
  String get challengeMonthApr => 'April';

  @override
  String get challengeMonthMay => 'May';

  @override
  String get challengeMonthJun => 'June';

  @override
  String get challengeMonthJul => 'July';

  @override
  String get challengeMonthAug => 'August';

  @override
  String get challengeMonthSep => 'September';

  @override
  String get challengeMonthOct => 'October';

  @override
  String get challengeMonthNov => 'November';

  @override
  String get challengeMonthDec => 'December';

  @override
  String get challengeNewTitle => 'New game';

  @override
  String get challengeDatePlaceholder => 'Date';

  @override
  String get challengeTimePlaceholder => 'Time';

  @override
  String get challengeType => 'Game type';

  @override
  String get challengeMinLevel => 'Min. level';

  @override
  String get challengeMaxLevel => 'Max. level';

  @override
  String get challengeCourtLayout => 'COURT LAYOUT';

  @override
  String get challengeCreateButton => 'Create game';

  @override
  String get challengeLoadingClubs => 'Loading...';

  @override
  String get challengeClubOptional => 'Club (optional)';

  @override
  String get challengeNoClub => 'No club';

  @override
  String get courtNet => 'NET';

  @override
  String get courtInvite => 'Invite';

  @override
  String get courtFreeSlot => 'Free';

  @override
  String get ratingTitle => 'Rating';

  @override
  String get ratingSearchHint => 'Search by name...';

  @override
  String get ratingPlayerHeader => 'PLAYER';

  @override
  String get ratingPointsHeader => 'POINTS';

  @override
  String get ratingPlayersNotFound => 'Players not found';

  @override
  String ratingRemainingPlayers(int count) {
    return '$count players';
  }

  @override
  String get ratingShowAll => 'Show all';

  @override
  String get ratingMyPosition => 'My position';

  @override
  String ratingLevelPoints(String level, String rating) {
    return 'Level $level · $rating points';
  }

  @override
  String ratingOutOfPlayers(int count) {
    return 'of $count players';
  }

  @override
  String get ratingFilterAll => 'All';

  @override
  String get profileUser => 'User';

  @override
  String profileLevelLabel(String level) {
    return 'Level $level';
  }

  @override
  String get profileMissingCity => 'city';

  @override
  String get profileMissingGender => 'gender';

  @override
  String get profileMissingPhone => 'phone';

  @override
  String profileMissingFields(String fields) {
    return 'Please specify $fields in profile settings';
  }

  @override
  String get profileMissingAnd => ' and ';

  @override
  String get profileBannerTitle => 'Complete your profile';

  @override
  String get profileBannerDesc =>
      'Without this info you can\'t register for tournaments.';

  @override
  String profileBannerMissing(String fields) {
    return 'Missing: $fields';
  }

  @override
  String get profileBannerCta => 'Complete';

  @override
  String get profileBannerSeparator => ' · ';

  @override
  String get tournamentHistory => 'Tournament History';

  @override
  String get allButton => 'All';

  @override
  String get noFinishedTournamentsYet => 'No finished tournaments yet';

  @override
  String placeLabel(int place) {
    return '$place place';
  }

  @override
  String get matchHistory => 'Match History';

  @override
  String get noMatchesYet => 'No matches yet';

  @override
  String get loadMore => 'Load more';

  @override
  String get winResult => 'Win';

  @override
  String get lossResult => 'Loss';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementFirstWin => 'First\nwin';

  @override
  String get achievementFiveWins => '5 wins\nin a row';

  @override
  String get achievementTopTen => 'Top 10\nrating';

  @override
  String get achievementTenTournaments => '10 tournaments';

  @override
  String get editProfile => 'Profile Settings';

  @override
  String get editProfileSubtitle => 'Name, city, gender';

  @override
  String get saveProfile => 'Save';

  @override
  String get sectionName => 'NAME';

  @override
  String get fieldName => 'Name';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get sectionPhone => 'PHONE';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get phoneHintEdit => '+7 (___) ___-__-__';

  @override
  String get phoneLockedHint => 'Phone cannot be changed';

  @override
  String get phoneInvalidFormat => 'Enter a valid number';

  @override
  String get sectionLocation => 'LOCATION';

  @override
  String get fieldCity => 'City';

  @override
  String get cityNotSpecified => 'Not specified';

  @override
  String get selectCity => 'Select city';

  @override
  String get sectionGender => 'GENDER';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get sectionAge => 'AGE';

  @override
  String get fieldAge => 'Age';

  @override
  String get ageNotSpecified => 'Not specified';

  @override
  String get sectionHand => 'DOMINANT HAND';

  @override
  String get handRight => 'Right';

  @override
  String get handLeft => 'Left';

  @override
  String get sectionPosition => 'COURT POSITION';

  @override
  String get positionRight => 'Right';

  @override
  String get positionLeft => 'Left';

  @override
  String get positionAny => 'Any';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoGallery => 'Gallery';

  @override
  String photoUploadError(String error) {
    return 'Photo upload error: $error';
  }

  @override
  String saveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get logoutTitle => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action is irreversible. All your data will be deleted.';

  @override
  String get deleteAccountPassword => 'Password (if any)';

  @override
  String get deleteButton => 'Delete';

  @override
  String get notificationSettingsMenu => 'Notification settings';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get monthShortJan => 'Jan';

  @override
  String get monthShortFeb => 'Feb';

  @override
  String get monthShortMar => 'Mar';

  @override
  String get monthShortApr => 'Apr';

  @override
  String get monthShortMay => 'May';

  @override
  String get monthShortJun => 'Jun';

  @override
  String get monthShortJul => 'Jul';

  @override
  String get monthShortAug => 'Aug';

  @override
  String get monthShortSep => 'Sep';

  @override
  String get monthShortOct => 'Oct';

  @override
  String get monthShortNov => 'Nov';

  @override
  String get monthShortDec => 'Dec';

  @override
  String courtDefault(int index) {
    return 'Court $index';
  }

  @override
  String get bookingError => 'Booking error';

  @override
  String get summaryClub => 'Club';

  @override
  String get summaryCourt => 'Court';

  @override
  String get summaryDate => 'Date';

  @override
  String get summaryStart => 'Start';

  @override
  String get summaryTime => 'Time';

  @override
  String get summaryCoach => 'Coach';

  @override
  String get summaryTotal => 'Total';

  @override
  String courtPriceBreakdown(String courtPrice, String coachPrice) {
    return 'Court $courtPrice + Coach $coachPrice ₸';
  }

  @override
  String coachPlus(String price) {
    return '+ coach $price ₸';
  }

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get failedToLoadSettings => 'Failed to load settings';

  @override
  String get settingsSaveError => 'Failed to save settings';

  @override
  String get onlyMyLevelTournaments => 'Only my level tournaments';

  @override
  String get onlyMyLevelTournamentsDesc =>
      'Receive notifications only about tournaments matching your level';

  @override
  String get notifyClubsTitle => 'Notifications from clubs';

  @override
  String get notifyClubsDesc =>
      'Choose clubs you want to receive new tournament notifications from';

  @override
  String get onboardingTitle1 => 'Join\ntournaments';

  @override
  String get onboardingDesc1 =>
      'Find padel tennis tournaments\nnear you and register in\none click';

  @override
  String get onboardingTitle2 => 'Track your\nrating';

  @override
  String get onboardingDesc2 =>
      'Track your progress and\ncompare results with other\nplayers';

  @override
  String get onboardingTitle3 => 'Find\npartners';

  @override
  String get onboardingDesc3 =>
      'Find players at your level for\njoint training and tournaments';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get authAcceptHint =>
      'To continue, you must accept the terms of service and consent to personal data processing';

  @override
  String get understood => 'Got it';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get consentToProcessing => 'Consent to Data Processing';

  @override
  String get enterCode => 'Enter code';

  @override
  String get authCancel => 'Cancel';

  @override
  String get loginTitle => 'Login';

  @override
  String get enterPhoneForLogin => 'Enter phone number to log in';

  @override
  String get loginViaTelegramToContinue => 'Log in via Telegram to continue';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get continueButton => 'Continue';

  @override
  String get or => 'or';

  @override
  String get loginViaTelegram => 'Log in via Telegram';

  @override
  String get loginViaEmail => 'Log in via Email or Phone';

  @override
  String get consentToProcessPersonalData =>
      'Consent to personal data processing';

  @override
  String get emailLoginTitle => 'Sign in';

  @override
  String get enterEmailAndPassword => 'Enter email or phone and password';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'No account? ';

  @override
  String get registerLink => 'Register';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get emailOrPhone => 'Email or phone';

  @override
  String get enterEmailOrPhone => 'Enter email or phone';

  @override
  String get enterValidEmailOrPhone => 'Enter a valid email or phone';

  @override
  String get emailOrPhonePlaceholder => 'example@mail.com or +7 777 123 45 67';

  @override
  String get registrationTitle => 'Sign up';

  @override
  String get createAccountToContinue => 'Create an account to continue';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNamePlaceholder => 'John Doe';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get cityLabel => 'City';

  @override
  String get selectCityTitle => 'Select city';

  @override
  String get minSixChars => 'Minimum 6 characters';

  @override
  String get enterPasswordHint => 'Enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get passwordsDontMatch => 'Passwords don\'t match';

  @override
  String get registerAction => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInLink => 'Sign In';

  @override
  String get passwordRecovery => 'Password Recovery';

  @override
  String get enterEmailForResetLink =>
      'Enter your email to receive\na password reset link';

  @override
  String get linkSentToEmail => 'Link sent to email';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get sendLink => 'Send link';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String codeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get confirmLogin => 'Confirm login';

  @override
  String get pressStartInTelegram =>
      'Press Start in the Telegram bot\nand return to the app';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get tryAgain => 'Try again';

  @override
  String get waitingForConfirmation => 'Waiting for confirmation...';

  @override
  String get openTelegram => 'Open Telegram';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateRequired =>
      'An update is required to continue using the app';

  @override
  String get newVersionAvailable =>
      'A new version with improvements is available';

  @override
  String get updateButton => 'Update';

  @override
  String get later => 'Later';

  @override
  String get profileMissingPhoneTitle => 'Add a phone number';

  @override
  String get profileMissingPhoneDesc =>
      'Without it you can\'t register for tournaments and games.';

  @override
  String get profileMissingCityTitle => 'Set your city';

  @override
  String get profileMissingCityDesc =>
      'So you see relevant tournaments in your city.';

  @override
  String get profileMissingGenderTitle => 'Set your gender';

  @override
  String get profileMissingGenderDesc =>
      'Required for doubles tournaments and partner matching.';

  @override
  String get verificationNotConfirmedTitle => 'Rating not yet confirmed';

  @override
  String get verificationNoAvatarTitle => 'Add a profile photo';

  @override
  String get verificationNoAvatarDesc =>
      'Go to Profile Settings and add a photo.';

  @override
  String get verificationNoTournamentsTitle => 'Play at least one tournament';

  @override
  String get verificationNoTournamentsDesc =>
      'Your rating confirms automatically after a tournament at a club that can confirm levels.';

  @override
  String get verificationSheetTitle => 'Level verification';

  @override
  String get verificationLatestEntry => 'LATEST CONFIRMATION';

  @override
  String get verificationFieldLevel => 'Set level';

  @override
  String get verificationFieldVerifiedBy => 'Confirmed by';

  @override
  String get verificationFieldClub => 'Club';

  @override
  String get verificationFieldWhen => 'When';

  @override
  String get verificationConfirmedByClub => 'Level confirmed by club.';

  @override
  String get verificationToConfirm => 'To confirm your rating:';

  @override
  String verificationHistoryRecords(int count) {
    return 'History records: $count';
  }

  @override
  String verificationLoadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get verificationNotConfirmedYet => 'Level not confirmed yet.';

  @override
  String get verificationNotChecked =>
      'This player\'s level hasn\'t been verified by a club yet.';

  @override
  String get tournamentDescription => 'Description';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get registerViaChat => 'Register via chat';

  @override
  String get searchClubHint => 'Search club';

  @override
  String get searchCommunityHint => 'Search community';

  @override
  String get cityAll => 'All';

  @override
  String get bannerClubsTitle => 'Clubs';

  @override
  String get bannerClubsSubtitle => 'Addresses and contacts';

  @override
  String get bannerCommunityTitle => 'Community';

  @override
  String get bannerCommunitySubtitle => 'Player communities';

  @override
  String get bannerCreateTournamentTitle => 'Create tournament';

  @override
  String get bannerCreateTournamentSubtitle => 'Organize your event';

  @override
  String get bannerBookCourtTitle => 'Book a court';

  @override
  String get bannerBookCourtSubtitle => 'Pick a club and time';

  @override
  String get restartTournament => 'Restart tournament';

  @override
  String get startTournamentMenu => 'Start tournament';

  @override
  String get restartTournamentConfirmTitle => 'Restart tournament?';

  @override
  String get restartTournamentConfirmMessage =>
      'The bracket and results will be deleted; you\'ll be able to change participants. This action cannot be undone.';

  @override
  String get restartTournamentConfirmOk => 'Restart';

  @override
  String get restartTournamentSuccess => 'Tournament restarted';

  @override
  String get editClubCard => 'Edit club card';

  @override
  String get editClubCardSubtitle => 'Name, contacts, description';

  @override
  String get clubName => 'Club name';

  @override
  String get clubAddress => 'Address';

  @override
  String get clubCity => 'City';

  @override
  String get clubPhone => 'Phone';

  @override
  String get clubEmail => 'Email';

  @override
  String get clubDescription => 'Description';

  @override
  String get clubPaymentUrl => 'Payment link';

  @override
  String get clubCardSaved => 'Club card saved';

  @override
  String get clubTelegram => 'Telegram channel';

  @override
  String get openTelegramChannel => 'Open Telegram channel';

  @override
  String get clubInstagram => 'Instagram';

  @override
  String get openInstagram => 'Open Instagram';

  @override
  String get tournamentInfoTitle => 'About tournaments';

  @override
  String get tournamentInfoMenuSubtitle => 'Rules and formats';

  @override
  String get tournamentInfoHeader =>
      'The formats and how each is played. Level and final place are counted differently in each.';

  @override
  String get tournamentInfoAmericanoName => 'Americano';

  @override
  String get tournamentInfoAmericanoBody =>
      'The most popular and friendly format. Great when a mixed-level group wants to play with everyone instead of staying in one fixed pair.\n\nHow it works. The tournament runs in rounds. Each round players are split into pairs on 2×2 courts. After the round the pairs are reshuffled — your next game is with a new partner against new opponents.\n\nIndividual scoring. Points are the games you win: whatever your pair scores in a round goes to you personally. Your partner changes every round, so the result depends mostly on your own play.\n\nWho wins. The champion is the player with the most points across the whole tournament. The standings are individual — everyone for themselves.\n\nGroups and playoff. At the organizer\'s discretion players can be split into several groups — then scoring is within your group. A playoff can also be added: after the group stage the top players contest the prizes in knockout matches.\n\nExample. 8 players, rounds to 21. Round 1: you and Denis win 21:14 → +21 for you. Round 2: you and Aigul lose 16:21 → +16 for you. At the end all your points are summed — the highest total wins.\n\nGood for. Mixed groups, beginners and experienced together, corporate events, «play with everyone and meet people».';

  @override
  String get tournamentInfoMexicanoName => 'Mexicano';

  @override
  String get tournamentInfoMexicanoBody =>
      'A «smart» rotation: opponents and partner are chosen not by lot but by the current standings. After every round you play with those near you in points — so matches stay even and tense throughout.\n\nHow it works. The first round is random pairs 2×2. After that, following each round players are sorted by points, split into fours by place, and within a four the pairs are formed 1+4 against 2+3 (strongest with weakest against the two in the middle) for maximum balance. The partner changes every round; the system remembers who has played with whom and tries not to repeat.\n\nLineup. Players in multiples of 4 (minimum 8). The organizer generates the rounds and ends the tournament at any time.\n\nScoring is individual, by points. The sum of balls scored across all matches. Standings: 1) points; 2) difference (scored − conceded); 3) win percentage.\n\nDifference from Americano. Americano is essentially a fixed «everyone with everyone» rotation. In Mexicano each round\'s pairs depend on the current places — leaders play against leaders, and it\'s harder to pull away.\n\nWho wins. First place goes to whoever has the most points in the final table.\n\nExample. After round 2 you\'re 3rd in points — next round you land in a four with places 1, 2 and 4 and play 1+4 vs 2+3. You go neck-and-neck with equals — every match counts.\n\nGood for. Those who want always-equal opponents and suspense to the end: the better you do, the stronger your opponents.';

  @override
  String get tournamentInfoRoundRobinName => 'Round Robin';

  @override
  String get tournamentInfoRoundRobinBody =>
      'Similar to Americano but more «sporty»: everyone plays against everyone in a round-robin, and standings are based on wins, not total points.\n\nHow it works. Rounds on 2×2 courts, partners change each round in a round-robin layout. Over a full circle (7 rounds for 8 players) you partner each player and face each one. Players in multiples of 4, minimum 8.\n\nDifference from Americano. The key is scoring. Americano sums the points you score; Round Robin counts matches won. What matters is winning games, not piling up points in lost ones.\n\nStandings (how place is decided). 1) number of wins; 2) on a tie — game difference (scored minus conceded); 3) still tied — head-to-head. No draws, you play to win.\n\nWho wins. First place goes to the player with the most wins (after the tie-breakers above).\n\nExample. You have 5 wins out of 7 — above those with 4. If two players have 5 wins each, the one with the better game difference ranks higher; if that\'s equal too, whoever beat the other head-to-head.\n\nRounds. The organizer generates the next round as it goes and can finish the tournament at any time. A full circle for 8 players is 7 rounds, and it can continue further.\n\nGood for. When you want a fair «everyone vs everyone» and the result to reflect wins. A bit longer and more sporty than Americano.';

  @override
  String get tournamentInfoKingOfCourtName => 'King of the Court';

  @override
  String get tournamentInfoKingOfCourtBody =>
      'A dynamic format with movement between courts. The goal is to climb to court №1 (the «king\'s court») and hold it against the strongest players.\n\nHow it works. Courts form a ladder: court 1 is the top, the last is the bottom. Each round is played 2×2 on a court, and afterwards: on the top court winners stay and losers drop down; on the middle courts winners move up and losers move down; on the bottom court winners move up and losers stay. Pairs on a court are reshuffled every round — a new partner each time.\n\nLineup. Players in multiples of 4 (minimum 8). Courts = players ÷ 4. The first round is drawn at random. The organizer generates the rounds and ends the tournament whenever they want.\n\nScoring is individual. Points are the balls you score across all your matches. Standings: 1) total points; 2) difference (scored − conceded); 3) win percentage. No draws.\n\nWho wins. The champion has the most points over the tournament. On court 1 the opponents are stronger, so scoring there is «worth more».\n\nPaired variant. King of the Court can also run with fixed pairs — then the whole pair moves along the court ladder: win and you both move up, lose and you both move down. You keep one partner for the whole tournament, and standings are kept by pairs.\n\nExample. 8 players = 2 courts. Win at the top and you stay against the strong ones. Lose at the bottom and you stay down. Gradually the strongest gather on court 1.\n\nGood for. Lovers of dynamics and the fight for the top: a new setup every round. Unlike Americano, it\'s not just a rotation but a ladder of courts with a battle for the top one.';

  @override
  String get tournamentInfoBaliKocName => 'King of the Court (Bali Format)';

  @override
  String get tournamentInfoBaliKocBody =>
      'A King of the Court variant with fixed pairs and court-dependent scoring. You play with the same partner the whole tournament.\n\nHow it works. Pairs are placed on a court ladder (court 1 is the top). Each round a pair plays a match by games, and afterwards pairs move: winners go up, losers go down. The whole pair moves along the ladder — the partner doesn\'t change.\n\nMatch points (the key twist). Only the match winner gets points, and the amount depends on the court:\n— Round 1: a win is worth 1 point (the starting setup);\n— after that: a win on court K of N is worth (N + 2 − K) points. So a win on the top court is «worth the most», and on the bottom the least.\nThat\'s why winning on the king\'s court pays off more than down below.\n\nStandings (by pairs). Place by: 1) points; 2) head-to-head; 3) more games won; 4) game difference (6:0 ranks above 6:2).\n\nLineup. Registration in pairs, pairs are fixed. The organizer generates the rounds and ends the tournament whenever they want.\n\nWho wins. The champion is the pair with the most points. Just winning isn\'t enough — it matters to win on the upper courts.\n\nExample. 12 players = 6 pairs = 3 courts (N=3). A win on court 1 = 3+2−1 = 4 points, court 2 = 3, court 3 = 2. A pair that reaches court 1 and keeps winning there pulls away quickly.\n\nGood for. Pairs who want to play together the whole tournament, and those who like a «weighted» points system with a fight for the top court.';

  @override
  String get tournamentInfoTeamName => 'Groups + Playoff';

  @override
  String get tournamentInfoTeamBody =>
      'A team format with fixed pairs: you register as a pair (or the organizer assembles the pairs), and that pair plays the whole tournament together. Two stages — group and playoff.\n\nHow it works.\n1) Group stage. Teams are spread into groups «snake»-style by rating (so the groups are roughly equal). Within a group it\'s a round-robin: every pair plays every other. A win is +1 point, a loss is 0, no draws.\n2) Playoff. The best teams from the groups advance to a knockout bracket (semifinals → final, and if needed a third-place match). Lose and you\'re out.\n\nGroup table. Place by: 1) points (wins); 2) game difference (scored − conceded); 3) more games scored.\n\nLineup. Registration in pairs, one partner for the whole tournament. The organizer sets the bracket configuration (number of groups, lower bracket, bronze match).\n\nWho wins. The champion is the winner of the playoff final. The group stage decides who reaches the bracket and from which seed.\n\nExample. 8 pairs → 2 groups of 4. In the group everyone plays everyone (3 matches each), the top two pairs from each group go to crossed semifinals, and the winners reach the final.\n\nGood for. Those who want to play with a constant partner and enjoy classic tournament drama: first the group qualifying, then a knockout playoff.';

  @override
  String get tournamentInfoFlexName => 'Americano Flex';

  @override
  String get tournamentInfoFlexBody =>
      'A flexible Americano for any number of players. Regular Americano needs a strict multiple of 4; here almost any number can play — extras sit out a round in turn.\n\nHow it works. Each round forms 2×2 matches with changing partners (like Americano). If there aren\'t enough players for even courts, some sit out (a bye). Rest is shared fairly: those who rested longest and played least go first — over time everyone gets roughly the same number of matches.\n\nScoring is individual, by average. Because of byes the number of matches played differs, so place is decided by average points per match (not the total). That way no one is helped or hurt by playing more or fewer games.\n\nLineup. Good for an «awkward» number of participants when a strict Americano won\'t fill. The organizer generates the rounds and ends the tournament at any time.\n\nPaired variant. Flex can also run with fixed pairs: then the «atom» is a pair, opponents and rest rotate, and the partner stays the same all tournament.\n\nWho wins. First place goes to whoever has the best average result per match.\n\nExample. 10 players, 2 courts = 8 play, 2 rest each round. Next round two others rest — and so on in a circle. If you played 6 matches for 36 points (average 6), you rank above someone with 40 over 8 matches (average 5).\n\nGood for. When a «non-round» number of players shows up but you want a fair Americano with no idle time and equal opportunity.';

  @override
  String get filterDateCustom => 'Pick dates';

  @override
  String get smsLoginButton => 'Sign in with SMS';

  @override
  String get phoneLoginTitle => 'Phone sign-in';

  @override
  String get phoneLoginSubtitle =>
      'Enter your phone number — we\'ll send a verification code';

  @override
  String get getCodeButton => 'Get code';

  @override
  String get registrationSubtitle => 'Fill in your profile to continue';

  @override
  String get fieldBirthDate => 'Date of birth';

  @override
  String get selectBirthDate => 'Select date';

  @override
  String get registrationFillAll => 'Fill in all fields';

  @override
  String get deleteAccountCodeHint =>
      'Enter the code from SMS to confirm deletion. This action is irreversible.';

  @override
  String resendCodeIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get changePhoneButton => 'Change number';

  @override
  String get changePhoneTitle => 'Change phone number';

  @override
  String get changePhoneOldHint => 'Enter the code sent to your current number';

  @override
  String get changePhoneEnterNew => 'Enter your new phone number';

  @override
  String get changePhoneNewHint => 'Enter the code sent to the new number';

  @override
  String get changePhoneSuccess => 'Phone number changed';

  @override
  String get chatTitle => 'Tournament chat';

  @override
  String get chatModeAdmin => 'Organizer only';

  @override
  String get chatModeParticipants => 'Participants';

  @override
  String get chatModeEveryone => 'Open chat';

  @override
  String get chatInputHint => 'Message…';

  @override
  String get chatLockedOnlyAdmin => 'Only the organizer can post';

  @override
  String get chatReadOnlyFinished => 'Chat closed — read only';

  @override
  String get chatEmpty => 'No messages yet';

  @override
  String get chatDelete => 'Delete';

  @override
  String get chatOrganizerBadge => 'Organizer';

  @override
  String get chatSendFailed => 'Failed to send message';

  @override
  String get chatRetry => 'Retry';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get notifyOrganizerChat => 'Organizer chat';

  @override
  String get notifyOrganizerChatDesc =>
      'Push when the organizer posts a new message in the tournament chat';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get sectionInfo => 'Information';

  @override
  String get sectionAccount => 'Account';

  @override
  String get coachTitle => 'Coach';

  @override
  String get coachScheduleButton => 'Schedule';

  @override
  String get coachScheduleButtonSubtitle => 'Your lessons schedule';

  @override
  String get coachBusyToday => 'Busy today';

  @override
  String get coachSlotFree => 'Free';

  @override
  String get coachSlotBooked => 'Booked';

  @override
  String get coachSlotBlocked => 'Blocked';

  @override
  String get coachDayOff => 'No working hours for this day';

  @override
  String get hoursShort => 'h';

  @override
  String get tournamentDurationTitle => 'Tournament duration';

  @override
  String get tournamentDurationSubtitle =>
      'This tournament has no duration set. Choose how long to add it to the calendar.';
}
