// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Padel KZ';

  @override
  String get navHome => 'Басты';

  @override
  String get navTournaments => 'Турнирлер';

  @override
  String get navChallenges => 'Ойын';

  @override
  String get navBooking => 'Брондау';

  @override
  String get ratingTabRating => 'Рейтинг';

  @override
  String get ratingTabGrowth => 'Рейтинг өсуі';

  @override
  String get ratingTabTournaments => 'Турнирлер';

  @override
  String get growthPeriodWeek => 'Апта';

  @override
  String get growthPeriodMonth => 'Ай';

  @override
  String get growthPeriodAll => 'Барлық уақыт';

  @override
  String growthPoints(int points) {
    return '+$points';
  }

  @override
  String get navRating => 'Рейтинг';

  @override
  String get navProfile => 'Профиль';

  @override
  String hello(String name) {
    return 'Сәлем, $name!';
  }

  @override
  String get welcome => 'Қош келдіңіз';

  @override
  String get bookCourt => 'Корт брондау';

  @override
  String get bookCourtSubtitle => 'Клуб пен ыңғайлы уақытты таңдаңыз';

  @override
  String get nearestTournament => 'Жақын арадағы турнир';

  @override
  String get activeTournament => 'Live турнир';

  @override
  String get nearestTournamentInfo =>
      'Мұнда сіз тіркелген және әлі басталмаған ең жақын турнир көрсетіледі.';

  @override
  String get activeTournamentInfo =>
      'Мұнда сіз қатысып жатқан және дәл қазір өтіп жатқан турнир көрсетіледі. Матчтар мен есепті тікелей эфирде (live) бақылау үшін оны ашыңыз.';

  @override
  String get upcoming => 'Жақында';

  @override
  String get all => 'Барлығы';

  @override
  String get rating => 'РЕЙТИНГ';

  @override
  String get level => 'ДЕҢГЕЙ';

  @override
  String get place => 'ОРЫН';

  @override
  String get matches => 'МАТЧТАР';

  @override
  String get wins => 'ЖЕҢІСТЕР';

  @override
  String get winrate => 'ЖЕҢУ %';

  @override
  String get losses => 'ЖЕҢІЛІС';

  @override
  String levelProgressLabel(String from, String to) {
    return 'Деңгей $from → $to';
  }

  @override
  String get weekdayShortMon => 'ДС';

  @override
  String get weekdayShortTue => 'СС';

  @override
  String get weekdayShortWed => 'СР';

  @override
  String get weekdayShortThu => 'БС';

  @override
  String get weekdayShortFri => 'ЖМ';

  @override
  String get weekdayShortSat => 'СБ';

  @override
  String get weekdayShortSun => 'ЖС';

  @override
  String get tournamentTypeAmericano => 'Американо';

  @override
  String get tournamentTypeMexicano => 'Мексикано';

  @override
  String get tournamentTypeKingOfCourt => 'Корт королі';

  @override
  String get tournamentTypeBaliKoc => 'Корт королі (Bali Format)';

  @override
  String get tournamentTypeTeam => 'Топтық + Плей-офф';

  @override
  String get tournamentTypeClassic => 'Классикалық';

  @override
  String get challengeCreateSubtitle => 'Ойынға шақыру';

  @override
  String get challengesCardTitle => 'Ойындар';

  @override
  String get challengesCardSubtitle => 'Барлық шақырулар';

  @override
  String get playerStatRating => 'Рейтинг';

  @override
  String get playerStatGames => 'Ойындар';

  @override
  String get playerStatWins => 'Жеңістер';

  @override
  String get playerStatTournaments => 'Турнирлер';

  @override
  String get developerLabel => 'Әзірлеуші';

  @override
  String get filterLevel => 'Деңгей';

  @override
  String get filterMyLevel => 'Менің деңгейім';

  @override
  String get filterFormat => 'Формат';

  @override
  String filterFormatWithCount(int count) {
    return 'Формат · $count';
  }

  @override
  String get filterDate => 'Күн';

  @override
  String get filterDateTomorrow => 'Ертең';

  @override
  String get filterDateWeek => 'Апта';

  @override
  String get filterClub => 'Клуб';

  @override
  String filterClubWithCount(int count) {
    return 'Клуб · $count';
  }

  @override
  String get filterCommunity => 'Комьюнити';

  @override
  String get forYouSection => 'Сіз үшін';

  @override
  String get tournamentLevelLabel => 'Турнир деңгейі';

  @override
  String get levelSuits => 'Сай келеді';

  @override
  String get levelDoesNotSuit => 'Сай емес';

  @override
  String yourLevelMark(String level) {
    return 'сіз $level';
  }

  @override
  String get notifyButton => 'Хабарлау';

  @override
  String get subscribedButton => 'Жазылдыңыз';

  @override
  String get dateAll => 'Барлық күндер';

  @override
  String get dateThisWeek => 'Осы аптада';

  @override
  String get tournamentStatusDraft => 'Жоба';

  @override
  String get tournamentStatusOpen => 'Тіркеу ашық';

  @override
  String get tournamentStatusClosed => 'Тіркеу жабық';

  @override
  String get tournamentStatusInProgress => 'Жүріп жатыр';

  @override
  String get tournamentStatusCompleted => 'Аяқталды';

  @override
  String get tournamentStatusCancelled => 'Бас тартылды';

  @override
  String get sectionContacts => 'БАЙЛАНЫСТАР';

  @override
  String get sectionAbout => 'СІЗ ТУРАЛЫ';

  @override
  String get sectionGameStyle => 'ОЙЫН СТИЛІ';

  @override
  String get nameHint => 'Атыңызды енгізіңіз';

  @override
  String get agePlaceholder => 'Туған күніңізді көрсетіңіз';

  @override
  String get saveChanges => 'Өзгерістерді сақтау';

  @override
  String get profileNameless => 'Атсыз';

  @override
  String get profileFilled => 'Профиль толтырылған';

  @override
  String get profileFillBio => 'Жасыңыз бен корттағы позицияңызды толтырыңыз';

  @override
  String get profileFillAge => 'Серіктес табу үшін жасыңызды көрсетіңіз';

  @override
  String get profileFillPosition => 'Корттағы позицияны көрсетіңіз';

  @override
  String get profileFillHand => 'Жетекші қолды қосыңыз';

  @override
  String get profileFillGender => 'Жынысыңызды көрсетіңіз';

  @override
  String get profileFillCity => 'Қаланы таңдаңыз';

  @override
  String get fieldHand => 'Жетекші қол';

  @override
  String get fieldPosition => 'Корттағы позиция';

  @override
  String get fieldGender => 'Жыныс';

  @override
  String rankInRatingShort(int n) {
    return 'Рейтингте #$n';
  }

  @override
  String ratingValueShort(int n) {
    return 'Рейтинг $n';
  }

  @override
  String get notFilled => 'Толтырылмаған';

  @override
  String get selectClub => 'Клуб таңдаңыз';

  @override
  String get searchClub => 'Клуб іздеу...';

  @override
  String get allCities => 'Барлығы';

  @override
  String courtsCount(int count) {
    return '$count корт';
  }

  @override
  String priceFrom(String price) {
    return '$price ₸-ден';
  }

  @override
  String get noClubsFound => 'Клубтар табылмады';

  @override
  String get booking => 'Брондау';

  @override
  String get court => 'Корт';

  @override
  String get date => 'Күні';

  @override
  String get time => 'Уақыты';

  @override
  String get start => 'Басталуы';

  @override
  String get duration => 'Ұзақтығы';

  @override
  String get total => 'Барлығы';

  @override
  String get coach => 'Жаттықтырушы';

  @override
  String get coachOptional => 'Жаттықтырушы (міндетті емес)';

  @override
  String get yourName => 'Аты';

  @override
  String get phone => 'Телефон';

  @override
  String get comment => 'Пікір';

  @override
  String get optional => 'Міндетті емес';

  @override
  String get enterName => 'Атыңызды енгізіңіз';

  @override
  String bookButton(String price) {
    return 'Брондау — $price ₸';
  }

  @override
  String payOnlineButton(String price) {
    return 'Онлайн төлеу — $price ₸';
  }

  @override
  String get bookWithoutPaymentButton => 'Төлемсіз брондау';

  @override
  String get onlinePaymentComingSoon =>
      'Онлайн төлем жақында қолжетімді болады';

  @override
  String get agreeWithDocsPrefix => 'Мен келісемін: ';

  @override
  String get docOfferAgreement => 'Оферта шартымен';

  @override
  String get docPrivacyPolicy => 'Құпиялылық саясатымен';

  @override
  String get docGoodsDescription => 'Тауарлар мен қызметтер сипаттамасымен';

  @override
  String get docCardPayment => 'Картамен төлеу шарттарымен';

  @override
  String get bookingConfirmed => 'Брон расталды!';

  @override
  String get bookingConfirmedSubtitle => 'Сіз кортты сәтті брондадыңыз';

  @override
  String get myBookings => 'Менің брондарым';

  @override
  String get goHome => 'Басты бетке';

  @override
  String get upcomingBookings => 'Алдағы';

  @override
  String get pastBookings => 'Өткен';

  @override
  String get noUpcomingBookings => 'Алдағы брондар жоқ';

  @override
  String get noPastBookings => 'Өткен брондар жоқ';

  @override
  String get statusPending => 'Жаңа өтінім';

  @override
  String get statusConfirmed => 'Расталды';

  @override
  String get statusCancelled => 'Күші жойылды';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get cancelBooking => 'Бронды жою керек пе?';

  @override
  String get areYouSure => 'Сенімдісіз бе?';

  @override
  String get yes => 'Иә';

  @override
  String get no => 'Жоқ';

  @override
  String get yesCancelIt => 'Иә, жою';

  @override
  String get bookingCancelled => 'Брон жойылды';

  @override
  String get cancelError => 'Жою қатесі';

  @override
  String get occupied => 'Бос емес';

  @override
  String get blocked => 'Блок.';

  @override
  String get free => 'Бос';

  @override
  String get noCourtsAvailable => 'Қол жетімді корттар жоқ';

  @override
  String get noSlotsForDay => 'Бұл күнге слоттар жоқ';

  @override
  String get today => 'Бүгін';

  @override
  String get hourOne => 'сағат';

  @override
  String get hourFew => 'сағат';

  @override
  String get hourMany => 'сағат';

  @override
  String get notifications => 'Хабарламалар';

  @override
  String get notifCategoryGeneral => 'Жалпы';

  @override
  String get notificationSettings => 'Хабарлама баптаулары';

  @override
  String get bookedCourts => 'Брондалған корттар';

  @override
  String get logout => 'Шығу';

  @override
  String get logoutSubtitle => 'Аккаунттан шығу';

  @override
  String get deleteAccount => 'Аккаунтты жою';

  @override
  String get deleteAccountSubtitle => 'Қайтарылмайтын жою';

  @override
  String get retry => 'Қайталау';

  @override
  String get error => 'Қате';

  @override
  String get networkError => 'Желі қатесі. Интернет байланысын тексеріңіз.';

  @override
  String get loadError => 'Деректерді жүктеу қатесі';

  @override
  String get language => 'Тіл';

  @override
  String get russian => 'Орысша';

  @override
  String get english => 'English';

  @override
  String get settingsTitle => 'Параметрлер';

  @override
  String get settingsMenuItem => 'Параметрлер';

  @override
  String get settingsMenuItemSubtitle => 'Рейтинг пен деңгейді көрсету';

  @override
  String get preciseRatingTitle => 'Дәл рейтинг мәндері';

  @override
  String get preciseRatingSubtitle =>
      'Рейтинг пен деңгейді екі ондық санмен көрсету (2690 орнына 2.69)';

  @override
  String get newsChannelTitle => 'Қолданбаның соңғы жаңалықтары';

  @override
  String get newsChannelSubtitle => 'Telegram-арна @padelkz_app';

  @override
  String get newsChannelButton => 'Қолданбаның соңғы жаңалықтары';

  @override
  String get calendarLink => 'Күнтізбе →';

  @override
  String get calendarTitle => 'Турнирлер күнтізбесі';

  @override
  String get calendarNoTournamentsForDay => 'Бұл күнге турнир жоқ';

  @override
  String get calendarAllTournaments => 'Барлық турнирлер →';

  @override
  String calendarSeats(int filled, int max) {
    return '$filled/$max орын';
  }

  @override
  String calendarSeatsLeft(int n) {
    return '$n орын қалды';
  }

  @override
  String get calendarTodayDow => 'Бүгін';

  @override
  String get calendarEmptyAll => 'Алдағы 14 күнде турнир жоқ';

  @override
  String get register => 'Тіркелу';

  @override
  String get registered => 'Сіз тіркелдіңіз';

  @override
  String levelShort(String level) {
    return 'Дең. $level';
  }

  @override
  String get noAvailableTournaments => 'Қол жетімді турнирлер жоқ';

  @override
  String get notInTournaments => 'Сіз турнирлерге қатыспайсыз';

  @override
  String get details => 'Толығырақ';

  @override
  String get chooseTournament => 'Турнир таңдау';

  @override
  String get noUpcomingTournaments => 'Алдағы турнирлер жоқ';

  @override
  String get tournaments => 'Турнирлер';

  @override
  String get openTab => 'Ашық';

  @override
  String get myTab => 'Менің';

  @override
  String get archiveTab => 'Мұрағат';

  @override
  String get cancelledTab => 'Болдырылмаған';

  @override
  String get noCancelledTournaments => 'Болдырылмаған турнирлер жоқ';

  @override
  String get noOpenTournaments => 'Ашық турнирлер жоқ';

  @override
  String get notRegisteredForTournaments => 'Сіз турнирлерге тіркелмедіңіз';

  @override
  String get noFinishedTournaments => 'Аяқталған турнирлер жоқ';

  @override
  String get tournamentRegistered => 'Тіркелді';

  @override
  String get noSpotsLeft => 'Орын жоқ';

  @override
  String clubTournamentsCount(int count) {
    return '$count турнир';
  }

  @override
  String get failedToLoadTournament => 'Турнирді жүктеу мүмкін болмады';

  @override
  String shareFreeSpots(int count) {
    return 'Бос орындар: $count';
  }

  @override
  String shareLevel(String level) {
    return 'Деңгей: $level';
  }

  @override
  String shareCost(String cost) {
    return 'Құны: $cost';
  }

  @override
  String get shareAppPromo =>
      'Padel KZ — қосымшаны жүктеп алыңыз және турнирлерге тіркеліңіз!';

  @override
  String get noSpotsLeftUpper => 'ОРЫН ЖОҚ';

  @override
  String get dateLabel => 'КҮНІ';

  @override
  String get timeLabel => 'УАҚЫТЫ';

  @override
  String get levelLabel => 'ДЕҢГЕЙ';

  @override
  String get costLabel => 'ҚҰНЫ';

  @override
  String get perPerson => 'адамға';

  @override
  String get pay => 'Төлеу';

  @override
  String get pendingModeration => 'Модерацияда';

  @override
  String get participants => 'Қатысушылар';

  @override
  String countOfMax(int count, int max) {
    return '$max-нен $count';
  }

  @override
  String get noParticipantsYet => 'Қатысушылар әлі жоқ';

  @override
  String spotsLeftCount(int count) {
    return 'Тағы $count бос орын';
  }

  @override
  String get pendingStatus => 'Күтуде';

  @override
  String get organizer => 'Ұйымдастырушы';

  @override
  String get registerButton => 'Тіркелу';

  @override
  String get applicationPending => 'Өтінім модерацияда';

  @override
  String get cancelApplication => 'Өтінімді кері қайтару';

  @override
  String get cancelRegistration => 'Тіркелуден бас тарту';

  @override
  String get youAreParticipating => 'Сіз қатысасыз';

  @override
  String get ok => 'ОК';

  @override
  String get choosePartner => 'Серіктесті таңдау';

  @override
  String get subscriptionActive => 'Жазылу белсенді';

  @override
  String get notifyOnFreeSpot => 'Бос орын туралы хабарлау';

  @override
  String get matchesLabel => 'МАТЧТАР';

  @override
  String get winsLabel => 'ЖЕҢІСТЕР';

  @override
  String get ratingLabel => 'РЕЙТИНГ';

  @override
  String get matchesTitle => 'Матчтар';

  @override
  String roundsCount(int count) {
    return '$count раунд';
  }

  @override
  String get resultDraw => 'ТЕҢ';

  @override
  String get resultWin => 'ЖЕҢІС';

  @override
  String get resultLoss => 'ЖЕҢІЛІС';

  @override
  String placeResult(int place) {
    return '$place орын';
  }

  @override
  String get teamConfirmed => 'Расталды';

  @override
  String get yourTeam => 'Сіздің командаңыз';

  @override
  String get teams => 'Командалар';

  @override
  String get noTeamsYet => 'Командалар әлі жоқ';

  @override
  String get enterPhoneNumber => 'Телефон нөмірін енгізіңіз';

  @override
  String get playersNotFound => 'Ойыншылар табылмады';

  @override
  String registerWith(String name) {
    return '$name серіктесімен тіркелу';
  }

  @override
  String get challenge => 'Ойын';

  @override
  String get challengeHint =>
      'Қарсыластар табыңыз және рейтингтік немесе достық матчтар ойнаңыз';

  @override
  String get challengeOpenTab => 'Ашық';

  @override
  String get challengeMyTab => 'Менің';

  @override
  String get noOpenChallenges => 'Ашық ойындар жоқ';

  @override
  String get noMyChallenges => 'Сізде ойындар жоқ';

  @override
  String get challengeNotSpecified => 'Көрсетілмеген';

  @override
  String challengeLevel(String level) {
    return 'Деңгей $level';
  }

  @override
  String get challengeRated => 'Рейтингтік';

  @override
  String get challengeFriendly => 'Достық';

  @override
  String get challengeJoinSlot => 'Орын алу';

  @override
  String get challengeDetails => 'Толығырақ';

  @override
  String get challengeChoosePosition => 'Позицияны таңдаңыз';

  @override
  String get challengePositionHint =>
      '1-2 позициялар — A командасы, 3-4 — B командасы';

  @override
  String get challengeTeamA => 'A командасы';

  @override
  String get challengeTeamB => 'B командасы';

  @override
  String get challengeCancelTitle => 'Ойынды жою?';

  @override
  String get challengeCancelConfirm => 'Ойынды жоюға сенімдісіз бе?';

  @override
  String get challengeYesCancel => 'Иә, жою';

  @override
  String get challengeEnterScore => 'Кем дегенде бір сетте есепті енгізіңіз';

  @override
  String get challengeNotFound => 'Ойын табылмады';

  @override
  String get challengeScore => 'ЕСЕП';

  @override
  String get challengeAddSet => 'Сет қосу';

  @override
  String get challengeFinish => 'Ойынды аяқтау';

  @override
  String get challengeScoreCreatorHint =>
      'Есепті ойынды құрушы енгізеді. Аяқталғаннан кейін нәтижені растай аласыз.';

  @override
  String get challengeResult => 'НӘТИЖЕ';

  @override
  String challengeSetScore(int index, int scoreA, int scoreB) {
    return 'Сет $index    $scoreA : $scoreB';
  }

  @override
  String get challengeConfirmed => 'Растады';

  @override
  String get challengeWaiting => 'Күтуде';

  @override
  String get challengeConfirmScore => 'Есепті растаймын';

  @override
  String get challengeScoreConfirmed => 'Сіз есепті растадыңыз';

  @override
  String get challengeTeamAWin => 'A командасының жеңісі';

  @override
  String get challengeTeamBWin => 'B командасының жеңісі';

  @override
  String get challengeDraw => 'Тең';

  @override
  String challengeSetLabel(int index) {
    return 'Сет $index';
  }

  @override
  String get challengeAccept => 'Қабылдау';

  @override
  String get challengeDecline => 'Бас тарту';

  @override
  String get challengeWaitingInvites => 'Шақырылған ойыншылардың растауын күту';

  @override
  String challengeNeedMorePlayers(int count) {
    return 'Бастау үшін тағы $count ойыншы керек';
  }

  @override
  String get challengeStart => 'Ойынды бастау';

  @override
  String get challengeCancelButton => 'Ойынды жою';

  @override
  String get challengeLeave => 'Шығу';

  @override
  String get challengeAddPlayer => 'Ойыншы қосу';

  @override
  String challengePositionTeam(int position, String team) {
    return '$position позиция · $team';
  }

  @override
  String get challengePhoneHint => 'Телефон нөмірі';

  @override
  String get challengeNobodyFound => 'Ешкім табылмады';

  @override
  String get challengeLeaveOpen => 'Ашық қалдыру';

  @override
  String get challengeYou => 'Сіз';

  @override
  String get challengeSpecifyDateTime => 'Күн мен уақытты көрсетіңіз';

  @override
  String get challengeErrorTitle => 'Қате';

  @override
  String get challengeDoneTitle => 'Дайын';

  @override
  String get challengeMonthJan => 'қаңтар';

  @override
  String get challengeMonthFeb => 'ақпан';

  @override
  String get challengeMonthMar => 'наурыз';

  @override
  String get challengeMonthApr => 'сәуір';

  @override
  String get challengeMonthMay => 'мамыр';

  @override
  String get challengeMonthJun => 'маусым';

  @override
  String get challengeMonthJul => 'шілде';

  @override
  String get challengeMonthAug => 'тамыз';

  @override
  String get challengeMonthSep => 'қыркүйек';

  @override
  String get challengeMonthOct => 'қазан';

  @override
  String get challengeMonthNov => 'қараша';

  @override
  String get challengeMonthDec => 'желтоқсан';

  @override
  String get challengeNewTitle => 'Жаңа ойын';

  @override
  String get challengeDatePlaceholder => 'Күні';

  @override
  String get challengeTimePlaceholder => 'Уақыты';

  @override
  String get challengeType => 'Ойын түрі';

  @override
  String get challengeMinLevel => 'Мин. деңгей';

  @override
  String get challengeMaxLevel => 'Макс. деңгей';

  @override
  String get challengeCourtLayout => 'КОРТТАҒЫ ОРНАЛАСУ';

  @override
  String get challengeCreateButton => 'Ойын құру';

  @override
  String get challengeLoadingClubs => 'Жүктелуде...';

  @override
  String get challengeClubOptional => 'Клуб (міндетті емес)';

  @override
  String get challengeNoClub => 'Клубсыз';

  @override
  String get courtNet => 'ТОР';

  @override
  String get courtInvite => 'Шақыру';

  @override
  String get courtFreeSlot => 'Бос';

  @override
  String get ratingTitle => 'Рейтинг';

  @override
  String get ratingSearchHint => 'Аты бойынша іздеу...';

  @override
  String get ratingPlayerHeader => 'ОЙЫНШЫ';

  @override
  String get ratingPointsHeader => 'ҰПАЙ';

  @override
  String get ratingPlayersNotFound => 'Ойыншылар табылмады';

  @override
  String ratingRemainingPlayers(int count) {
    return '$count ойыншы';
  }

  @override
  String get ratingShowAll => 'Барлығын көрсету';

  @override
  String get ratingMyPosition => 'Менің орным';

  @override
  String ratingLevelPoints(String level, String rating) {
    return 'Деңгей $level · $rating ұпай';
  }

  @override
  String ratingOutOfPlayers(int count) {
    return '$count ойыншыдан';
  }

  @override
  String get ratingFilterAll => 'Барлығы';

  @override
  String get profileUser => 'Қолданушы';

  @override
  String profileLevelLabel(String level) {
    return 'Деңгей $level';
  }

  @override
  String get profileMissingCity => 'қала';

  @override
  String get profileMissingGender => 'жыныс';

  @override
  String get profileMissingPhone => 'телефон';

  @override
  String profileMissingFields(String fields) {
    return 'Профиль баптауларында $fields көрсетіңіз';
  }

  @override
  String get profileMissingAnd => ' және ';

  @override
  String get profileBannerTitle => 'Профильді толтырыңыз';

  @override
  String get profileBannerDesc => 'Бұл деректерсіз турнирге тіркеле алмайсыз.';

  @override
  String profileBannerMissing(String fields) {
    return 'Толтырылмаған: $fields';
  }

  @override
  String get profileBannerCta => 'Толықтыру';

  @override
  String get profileBannerSeparator => ' · ';

  @override
  String get tournamentHistory => 'Турнирлер тарихы';

  @override
  String get allButton => 'Барлығы';

  @override
  String get noFinishedTournamentsYet => 'Аяқталған турнирлер әлі жоқ';

  @override
  String placeLabel(int place) {
    return '$place орын';
  }

  @override
  String get matchHistory => 'Матчтар тарихы';

  @override
  String get noMatchesYet => 'Матчтар әлі жоқ';

  @override
  String get loadMore => 'Тағы жүктеу';

  @override
  String get winResult => 'Жеңіс';

  @override
  String get lossResult => 'Жеңіліс';

  @override
  String get achievements => 'Жетістіктер';

  @override
  String get achievementFirstWin => 'Бірінші\nжеңіс';

  @override
  String get achievementFiveWins => 'Қатарынан\n5 жеңіс';

  @override
  String get achievementTopTen => 'Топ-10\nрейтингі';

  @override
  String get achievementTenTournaments => '10 турнир';

  @override
  String get editProfile => 'Профиль баптаулары';

  @override
  String get editProfileSubtitle => 'Аты, қала, жыныс';

  @override
  String get saveProfile => 'Сақтау';

  @override
  String get sectionName => 'ТАӘ';

  @override
  String get fieldName => 'Аты';

  @override
  String get notSpecified => 'Көрсетілмеген';

  @override
  String get sectionPhone => 'ТЕЛЕФОН';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get phoneHintEdit => '+7 (___) ___-__-__';

  @override
  String get phoneLockedHint => 'Телефонды өзгертуге болмайды';

  @override
  String get phoneInvalidFormat => 'Дұрыс нөмір енгізіңіз';

  @override
  String get sectionLocation => 'ОРНАЛАСУ';

  @override
  String get fieldCity => 'Қала';

  @override
  String get cityNotSpecified => 'Көрсетілмеген';

  @override
  String get selectCity => 'Қаланы таңдаңыз';

  @override
  String get sectionGender => 'ЖЫНЫС';

  @override
  String get genderMale => 'Ер';

  @override
  String get genderFemale => 'Әйел';

  @override
  String get sectionAge => 'ЖАСЫ';

  @override
  String get fieldAge => 'Жас';

  @override
  String get ageNotSpecified => 'Көрсетілмеген';

  @override
  String get sectionHand => 'БАСЫМ ҚОЛ';

  @override
  String get handRight => 'Оңқай';

  @override
  String get handLeft => 'Солақай';

  @override
  String get sectionPosition => 'КОРТТАҒЫ ПОЗИЦИЯ';

  @override
  String get positionRight => 'Оң жақ';

  @override
  String get positionLeft => 'Сол жақ';

  @override
  String get positionAny => 'Кез келген';

  @override
  String get photoCamera => 'Камера';

  @override
  String get photoGallery => 'Галерея';

  @override
  String photoUploadError(String error) {
    return 'Фото жүктеу қатесі: $error';
  }

  @override
  String saveError(String error) {
    return 'Сақтау қатесі: $error';
  }

  @override
  String get logoutTitle => 'Шығу';

  @override
  String get logoutConfirm => 'Шығуға сенімдісіз бе?';

  @override
  String get deleteAccountTitle => 'Аккаунтты жою';

  @override
  String get deleteAccountWarning =>
      'Бұл әрекет қайтарылмайды. Барлық деректеріңіз жойылады.';

  @override
  String get deleteAccountPassword => 'Құпия сөз (бар болса)';

  @override
  String get deleteButton => 'Жою';

  @override
  String get notificationSettingsMenu => 'Хабарлама баптаулары';

  @override
  String get dayMon => 'Дс';

  @override
  String get dayTue => 'Сс';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Бс';

  @override
  String get dayFri => 'Жм';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Жс';

  @override
  String get monthShortJan => 'қаң';

  @override
  String get monthShortFeb => 'ақп';

  @override
  String get monthShortMar => 'нау';

  @override
  String get monthShortApr => 'сәу';

  @override
  String get monthShortMay => 'мам';

  @override
  String get monthShortJun => 'мау';

  @override
  String get monthShortJul => 'шіл';

  @override
  String get monthShortAug => 'там';

  @override
  String get monthShortSep => 'қыр';

  @override
  String get monthShortOct => 'қаз';

  @override
  String get monthShortNov => 'қар';

  @override
  String get monthShortDec => 'жел';

  @override
  String courtDefault(int index) {
    return 'Корт $index';
  }

  @override
  String get bookingError => 'Брондау қатесі';

  @override
  String get summaryClub => 'Клуб';

  @override
  String get summaryCourt => 'Корт';

  @override
  String get summaryDate => 'Күні';

  @override
  String get summaryStart => 'Басталуы';

  @override
  String get summaryTime => 'Уақыты';

  @override
  String get summaryCoach => 'Жаттықтырушы';

  @override
  String get summaryTotal => 'Барлығы';

  @override
  String courtPriceBreakdown(String courtPrice, String coachPrice) {
    return 'Корт $courtPrice + Жаттықтырушы $coachPrice ₸';
  }

  @override
  String coachPlus(String price) {
    return '+ жаттықтырушы $price ₸';
  }

  @override
  String get failedToLoadNotifications =>
      'Хабарламаларды жүктеу мүмкін болмады';

  @override
  String get noNotifications => 'Хабарламалар жоқ';

  @override
  String minutesAgo(int count) {
    return '$count мин. бұрын';
  }

  @override
  String hoursAgo(int count) {
    return '$count сағ. бұрын';
  }

  @override
  String daysAgo(int count) {
    return '$count күн бұрын';
  }

  @override
  String get failedToLoadSettings => 'Баптауларды жүктеу мүмкін болмады';

  @override
  String get settingsSaveError => 'Баптауларды сақтау қатесі';

  @override
  String get onlyMyLevelTournaments => 'Тек өз деңгейімдегі турнирлер';

  @override
  String get onlyMyLevelTournamentsDesc =>
      'Өз деңгейіңізге сай келетін турнирлер туралы ғана хабарлама алу';

  @override
  String get notifyClubsTitle => 'Клубтардан хабарламалар';

  @override
  String get notifyClubsDesc =>
      'Жаңа турнирлер туралы хабарлама алғыңыз келетін клубтарды таңдаңыз';

  @override
  String get onboardingTitle1 => 'Турнирлерге\nқатысыңыз';

  @override
  String get onboardingDesc1 =>
      'Жаныңыздан падел-теннис\nтурнирлерін табыңыз және бір\nбасуда тіркеліңіз';

  @override
  String get onboardingTitle2 => 'Рейтингті\nбақылаңыз';

  @override
  String get onboardingDesc2 =>
      'Прогрессіңізді бақылаңыз және\nбасқа ойыншылармен нәтижелеріңізді\nсалыстырыңыз';

  @override
  String get onboardingTitle3 => 'Серіктестерді\nтабыңыз';

  @override
  String get onboardingDesc3 =>
      'Бірлескен жаттығулар мен\nтурнирлер үшін өз деңгейіңіздегі\nойыншыларды іздеңіз';

  @override
  String get skip => 'Өткізу';

  @override
  String get next => 'Әрі қарай';

  @override
  String get getStarted => 'Бастау';

  @override
  String get authAcceptHint =>
      'Жалғастыру үшін пайдаланушы келісімін қабылдап, дербес деректерді өңдеуге келісім беру керек';

  @override
  String get understood => 'Түсінікті';

  @override
  String get termsOfService => 'Пайдаланушы келісімі';

  @override
  String get consentToProcessing => 'Деректерді өңдеуге келісім';

  @override
  String get enterCode => 'Кодты енгізіңіз';

  @override
  String get authCancel => 'Бас тарту';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get enterPhoneForLogin => 'Кіру үшін телефон нөмірін енгізіңіз';

  @override
  String get loginViaTelegramToContinue =>
      'Жалғастыру үшін Telegram арқылы кіріңіз';

  @override
  String get phoneNumber => 'Телефон нөмірі';

  @override
  String get enterValidNumber => 'Дұрыс нөмір енгізіңіз';

  @override
  String get continueButton => 'Жалғастыру';

  @override
  String get or => 'немесе';

  @override
  String get loginViaTelegram => 'Telegram арқылы кіру';

  @override
  String get loginViaEmail => 'Email немесе телефон арқылы кіру';

  @override
  String get consentToProcessPersonalData =>
      'Дербес деректерді өңдеуге келісім';

  @override
  String get emailLoginTitle => 'Кіру';

  @override
  String get enterEmailAndPassword =>
      'Email немесе телефон мен құпия сөзді енгізіңіз';

  @override
  String get password => 'Құпия сөз';

  @override
  String get enterPassword => 'Құпия сөзді енгізіңіз';

  @override
  String get forgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get signIn => 'Кіру';

  @override
  String get noAccount => 'Аккаунт жоқ па? ';

  @override
  String get registerLink => 'Тіркелу';

  @override
  String get enterEmail => 'Email енгізіңіз';

  @override
  String get enterValidEmail => 'Дұрыс email енгізіңіз';

  @override
  String get emailOrPhone => 'Email немесе телефон';

  @override
  String get enterEmailOrPhone => 'Email немесе телефон енгізіңіз';

  @override
  String get enterValidEmailOrPhone => 'Дұрыс email немесе телефон енгізіңіз';

  @override
  String get emailOrPhonePlaceholder =>
      'example@mail.com немесе +7 777 123 45 67';

  @override
  String get registrationTitle => 'Тіркелу';

  @override
  String get createAccountToContinue => 'Жалғастыру үшін аккаунт құрыңыз';

  @override
  String get fullName => 'ТАӘ';

  @override
  String get fullNamePlaceholder => 'Ивановтар Иван Иванович';

  @override
  String get enterFullName => 'ТАӘ енгізіңіз';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get cityLabel => 'Қала';

  @override
  String get selectCityTitle => 'Қаланы таңдаңыз';

  @override
  String get minSixChars => 'Кемінде 6 таңба';

  @override
  String get enterPasswordHint => 'Құпия сөзді енгізіңіз';

  @override
  String get passwordMinLength => 'Құпия сөз кемінде 6 таңбадан тұруы керек';

  @override
  String get confirmPassword => 'Құпия сөзді растау';

  @override
  String get repeatPassword => 'Құпия сөзді қайталаңыз';

  @override
  String get confirmPasswordHint => 'Құпия сөзді растаңыз';

  @override
  String get passwordsDontMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get registerAction => 'Тіркелу';

  @override
  String get alreadyHaveAccount => 'Аккаунт бар ма? ';

  @override
  String get signInLink => 'Кіру';

  @override
  String get passwordRecovery => 'Құпия сөзді қалпына келтіру';

  @override
  String get enterEmailForResetLink =>
      'Құпия сөзді қалпына келтіру сілтемесін\nалу үшін email енгізіңіз';

  @override
  String get linkSentToEmail => 'Сілтеме email-ге жіберілді';

  @override
  String get backToLogin => 'Кіруге қайту';

  @override
  String get sendLink => 'Сілтемені жіберу';

  @override
  String get verificationCode => 'Растау коды';

  @override
  String codeSentTo(String phone) {
    return 'Код $phone нөміріне жіберілді';
  }

  @override
  String get resendCode => 'Кодты қайта жіберу';

  @override
  String get confirmButton => 'Растау';

  @override
  String get confirmLogin => 'Кіруді растаңыз';

  @override
  String get pressStartInTelegram =>
      'Telegram ботында Start басыңыз\nжәне қосымшаға оралыңыз';

  @override
  String get connectionFailed => 'Байланыс орнатылмады';

  @override
  String get tryAgain => 'Қайталап көру';

  @override
  String get waitingForConfirmation => 'Растауды күту...';

  @override
  String get openTelegram => 'Telegram ашу';

  @override
  String get updateAvailable => 'Жаңарту қолжетімді';

  @override
  String get updateRequired => 'Қосымшаны жалғастыру үшін жаңарту қажет';

  @override
  String get newVersionAvailable => 'Жақсартулармен жаңа нұсқасы шықты';

  @override
  String get updateButton => 'Жаңарту';

  @override
  String get later => 'Кейінірек';

  @override
  String get profileMissingPhoneTitle => 'Телефон нөмірін көрсетіңіз';

  @override
  String get profileMissingPhoneDesc =>
      'Онсыз турнирлер мен ойындарға тіркеле алмайсыз.';

  @override
  String get profileMissingCityTitle => 'Қаланы көрсетіңіз';

  @override
  String get profileMissingCityDesc =>
      'Қалаңыздағы өзекті турнирлерді көру үшін.';

  @override
  String get profileMissingGenderTitle => 'Жынысыңызды көрсетіңіз';

  @override
  String get profileMissingGenderDesc =>
      'Жұптық турнирлер мен серіктесті таңдау үшін қажет.';

  @override
  String get verificationNotConfirmedTitle => 'Рейтинг әлі расталмаған';

  @override
  String get verificationNoAvatarTitle => 'Аватар қойыңыз';

  @override
  String get verificationNoAvatarDesc =>
      '«Профиль баптауларына» кіріп, фотоны қосыңыз.';

  @override
  String get verificationNoTournamentsTitle => 'Кем дегенде бір турнир ойнаңыз';

  @override
  String get verificationNoTournamentsDesc =>
      'Бірінші турнир аяқталғаннан кейін рейтинг автоматты расталады.';

  @override
  String get verificationSheetTitle => 'Деңгейді растау';

  @override
  String get verificationLatestEntry => 'СОҢҒЫ РАСТАУ';

  @override
  String get verificationFieldLevel => 'Қойылған деңгей';

  @override
  String get verificationFieldVerifiedBy => 'Кім растады';

  @override
  String get verificationFieldClub => 'Клуб';

  @override
  String get verificationFieldWhen => 'Қашан';

  @override
  String get verificationConfirmedByClub => 'Деңгей клубпен расталды.';

  @override
  String get verificationToConfirm => 'Рейтингті растау үшін:';

  @override
  String verificationHistoryRecords(int count) {
    return 'Тарихтағы жазбалар: $count';
  }

  @override
  String verificationLoadFailed(String error) {
    return 'Жүктеу мүмкін болмады: $error';
  }

  @override
  String get verificationNotConfirmedYet => 'Деңгей әлі расталмаған.';

  @override
  String get verificationNotChecked =>
      'Бұл ойыншының деңгейін клуб әлі растаған жоқ.';

  @override
  String get tournamentDescription => 'Сипаттама';

  @override
  String get showMore => 'Толығырақ көрсету';

  @override
  String get showLess => 'Жасыру';

  @override
  String get registerViaChat => 'Чат арқылы тіркелу';

  @override
  String get searchClubHint => 'Клуб іздеу';

  @override
  String get searchCommunityHint => 'Қоғамдастық іздеу';

  @override
  String get cityAll => 'Барлығы';

  @override
  String get bannerClubsTitle => 'Клубтар';

  @override
  String get bannerClubsSubtitle => 'Мекенжайлар мен байланыстар';

  @override
  String get bannerCommunityTitle => 'Қоғамдастық';

  @override
  String get bannerCommunitySubtitle => 'Ойыншылар қауымдастығы';

  @override
  String get bannerCreateTournamentTitle => 'Турнир құру';

  @override
  String get bannerCreateTournamentSubtitle => 'Өз шараңды ұйымдастыр';

  @override
  String get bannerBookCourtTitle => 'Корт брондау';

  @override
  String get bannerBookCourtSubtitle => 'Клуб пен ыңғайлы уақытты таңдаңыз';

  @override
  String get restartTournament => 'Турнирді қайта бастау';

  @override
  String get startTournamentMenu => 'Турнирді бастау';

  @override
  String get restartTournamentConfirmTitle => 'Турнирді қайта бастау?';

  @override
  String get restartTournamentConfirmMessage =>
      'Тор мен нәтижелер жойылады; қатысушыларды өзгерте аласыз. Бұл әрекетті қайтару мүмкін емес.';

  @override
  String get restartTournamentConfirmOk => 'Қайта бастау';

  @override
  String get restartTournamentSuccess => 'Турнир қайта басталды';

  @override
  String get editClubCard => 'Клуб картасын өңдеу';

  @override
  String get editClubCardSubtitle => 'Атауы, байланыстар, сипаттама';

  @override
  String get clubName => 'Клуб атауы';

  @override
  String get clubAddress => 'Мекенжай';

  @override
  String get clubCity => 'Қала';

  @override
  String get clubPhone => 'Телефон';

  @override
  String get clubEmail => 'Email';

  @override
  String get clubDescription => 'Сипаттама';

  @override
  String get clubPaymentUrl => 'Төлем сілтемесі';

  @override
  String get clubCardSaved => 'Клуб картасы сақталды';

  @override
  String get clubTelegram => 'Телеграм-арна';

  @override
  String get openTelegramChannel => 'Телеграм-арнаны ашу';

  @override
  String get clubInstagram => 'Instagram';

  @override
  String get openInstagram => 'Instagram-ды ашу';
}
