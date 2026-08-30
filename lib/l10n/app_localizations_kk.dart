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
  String get filterCity => 'Қала';

  @override
  String filterCityWithCount(int count) {
    return 'Қала · $count';
  }

  @override
  String get forYouSection => 'Сіз үшін';

  @override
  String get tournamentLevelLabel => 'Турнир деңгейі';

  @override
  String get prizeTournament => 'Жүлделі';

  @override
  String get prizesLabel => 'Жүлделер';

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
  String get documentsTitle => 'Құжаттар';

  @override
  String get documentsSubtitle => 'Қосымшаның заңды құжаттары';

  @override
  String get docTitleOffer => 'Оферта шарты';

  @override
  String get docTitlePrivacy => 'Құпиялылық саясаты';

  @override
  String get docTitleGoods => 'Тауарлар мен қызметтер сипаттамасы';

  @override
  String get docTitleCard => 'Картамен төлеу шарттары';

  @override
  String get bookingConfirmed => 'Брон расталды!';

  @override
  String get bookingConfirmedSubtitle => 'Сіз кортты сәтті брондадыңыз';

  @override
  String get paymentNotCompletedTitle => 'Төлем аяқталмады';

  @override
  String get paymentNotCompleted =>
      'Сіз төлемді аяқтаған жоқсыз. Брон төленбеген күйінде сақталды — кейінірек «Менің брондарым» бөлімінде немесе клубта төлеуге болады.';

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
  String get statusNotConfirmed => 'Расталмаған';

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
  String get themeTitle => 'Безендіру тақырыбы';

  @override
  String get themeSubtitle => 'Ашық, қараңғы немесе жүйедегідей';

  @override
  String get themeSystem => 'Жүйелік';

  @override
  String get themeLight => 'Ашық';

  @override
  String get themeDark => 'Қараңғы';

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
  String get tournamentUnrated => 'РЕЙТИНГСІЗ';

  @override
  String get tournamentVerifiedBadge => 'ВЕРИФ.';

  @override
  String get tournamentVerifiedOnly => 'Тек верификацияланғандар';

  @override
  String get unratedBadge => 'Рейтингсіз';

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
  String get enterNameOrPhone => 'Аты немесе телефон нөмірі';

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
  String get notifyAllCities => 'Барлық қалалар';

  @override
  String get notifyAllClubs => 'Барлық клубтар';

  @override
  String notifyClubsChosen(int count, int total) {
    return '$total ішінен $count таңдалды';
  }

  @override
  String get notifyCitiesTitle => 'Қалалар';

  @override
  String get notifyCitiesDesc =>
      'Қаланы өшірсеңіз, оның клубтарының турнирлері туралы хабарламалар келмейді';

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
      'Рейтинг деңгейлерді растай алатын клубтағы турнирден кейін автоматты түрде расталады.';

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

  @override
  String get tournamentInfoTitle => 'О турнирах';

  @override
  String get tournamentInfoMenuSubtitle => 'Правила и форматы';

  @override
  String get tournamentInfoHeader =>
      'Какие бывают форматы и как в них играют. Уровень и место в каждом считаются по-своему.';

  @override
  String get tournamentInfoAmericanoName => 'Американо';

  @override
  String get tournamentInfoAmericanoBody =>
      'Самый популярный и дружелюбный формат. Подходит, когда собралась компания разного уровня и хочется поиграть со всеми, а не одной фиксированной парой.\n\nКак играется. Турнир идёт раундами. В каждом раунде участников разбивают на пары и ставят на корты 2×2. После раунда пары перемешиваются — следующую игру вы проводите с новым партнёром и против новых соперников.\n\nЗачёт — личный. Считаются набранные очки (геймы): сколько ваша пара набрала в раунде — столько идёт лично вам. Партнёр каждый раз новый, поэтому результат зависит в первую очередь от вашей игры.\n\nКто победил. Чемпион — тот, кто набрал больше всего очков за весь турнир. Таблица индивидуальная, каждый сам за себя.\n\nГруппы и плей-офф. На усмотрение организатора участников могут разбить на несколько групп — тогда зачёт идёт внутри своей группы. Также может быть добавлен плей-офф: после группового этапа лучшие разыгрывают призовые места в матчах на вылет.\n\nПример. 8 игроков, раунд до 21 очка. Раунд 1: вы с Денисом выиграли 21:14 → вам +21. Раунд 2: вы с Айгуль проиграли 16:21 → вам +16. В конце суммируем все очки — у кого больше, тот и первый.\n\nКому подходит. Смешанные компании, новички и опытные вместе, корпоративы, «поиграть со всеми и познакомиться».';

  @override
  String get tournamentInfoMexicanoName => 'Мексикано';

  @override
  String get tournamentInfoMexicanoBody =>
      '«Умная» ротация: соперников и партнёра подбирает не жребий, а текущая таблица. После каждого раунда вы играете с теми, кто рядом с вами по очкам — поэтому матчи всё время равные и напряжённые.\n\nКак играется. Первый раунд — случайные пары 2×2. Дальше после каждого раунда игроки сортируются по очкам, делятся на четвёрки по местам, и внутри четвёрки пары составляются по схеме 1+4 против 2+3 (сильнейший со слабейшим против двух средних) — для максимального баланса. Партнёр меняется каждый раунд; система помнит, кто с кем уже играл, и старается не повторять.\n\nСостав. Игроков кратно 4 (минимум 8). Раунды генерирует организатор и завершает турнир в любой момент.\n\nЗачёт — личный, по очкам. Сумма набранных мячей во всех матчах. Таблица: 1) очки; 2) разница (забил − пропустил); 3) процент побед.\n\nЧем отличается от Американо. В Американо расклад по сути фиксированная ротация «каждый с каждым». В Мексикано пары на каждый раунд зависят от текущих мест — лидеры играют против лидеров, оторваться сложнее.\n\nКто победил. Первый — у кого больше всего очков в итоговой таблице.\n\nПример. После 2-го раунда вы 3-й по очкам — в следующем раунде попадёте в четвёрку с 1, 2 и 4 местами и сыграете 1+4 vs 2+3. Идёте ровно с равными — каждый матч решает.\n\nКому подходит. Кто хочет всегда равных соперников и интриги до конца: чем лучше идёте, тем сильнее оппоненты.';

  @override
  String get tournamentInfoRoundRobinName => 'Round Robin';

  @override
  String get tournamentInfoRoundRobinBody =>
      'Похож на Американо, но более «спортивный»: каждый играет с каждым по круговой системе, а в зачёте важны победы, а не сумма очков.\n\nКак играется. Раунды на кортах 2×2, партнёры каждый раунд меняются по круговой раскладке. За полный круг (для 8 игроков — 7 раундов) вы успеваете побыть в паре с каждым и сыграть против каждого. Игроков кратно 4, минимум 8.\n\nЧем отличается от Американо. Главное — зачёт. В Американо считают сумму набранных очков, а в Round Robin — число выигранных матчей. Важно именно выигрывать партии, а не «доколачивать» очки в проигранных.\n\nТаблица (как считается место). 1) число побед; 2) при равенстве — разница геймов (забил минус пропустил); 3) если снова равенство — личная встреча. Ничьих нет, играем до победы.\n\nКто победил. Первый — у кого больше всего побед за турнир (с учётом тай-брейков выше).\n\nПример. У вас 5 побед из 7 — вы выше тех, у кого 4. Если у двоих по 5 побед, выше тот, у кого лучше разница геймов; если равна и она — кто обыграл соперника в очной встрече.\n\nРаунды. Организатор генерирует следующий раунд по ходу и может завершить турнир в любой момент. Полный круг для 8 игроков — 7 раундов, дальше можно продолжать.\n\nКому подходит. Когда хочется честного «каждый с каждым», и чтобы итог отражал именно победы. Чуть длиннее и спортивнее Американо.';

  @override
  String get tournamentInfoKingOfCourtName => 'Король корта';

  @override
  String get tournamentInfoKingOfCourtBody =>
      'Динамичный формат с движением по кортам. Цель — подняться на корт №1 («королевский») и удержаться там против сильнейших.\n\nКак играется. Корты выстроены лестницей: корт 1 — верхний, последний — нижний. Каждый раунд на корте играют 2×2, после раунда: на верхнем корте победители остаются, проигравшие опускаются; на средних — победители поднимаются, проигравшие опускаются; на нижнем победители поднимаются, проигравшие остаются. Пары на корте каждый раунд перемешиваются — партнёр новый.\n\nСостав. Игроков кратно 4 (минимум 8). Кортов = игроков ÷ 4. Первый раунд раскидывается случайно. Раунды генерирует организатор и завершает турнир, когда захочет.\n\nЗачёт — личный. Очки — это набранные мячи во всех ваших матчах. Таблица: 1) сумма очков; 2) разница (забил − пропустил); 3) процент побед. Ничьих нет.\n\nКто победил. Чемпион — у кого больше всего очков за турнир. На корте 1 соперники сильнее, и набрать там «дороже».\n\nПарный вариант. Король корта можно проводить и с фиксированными парами — тогда по лестнице кортов двигается пара целиком: выиграли — поднимаетесь вдвоём, проиграли — опускаетесь вдвоём. Партнёр на весь турнир один, а зачёт ведётся по парам.\n\nПример. 8 игроков = 2 корта. Выиграли наверху — остаётесь против сильных. Проиграли внизу — остаётесь внизу. Постепенно сильнейшие собираются на корте 1.\n\nКому подходит. Любителям динамики и борьбы за вершину: каждый раунд новый расклад. Отличие от Американо — не просто ротация, а лестница кортов с борьбой за верхний.';

  @override
  String get tournamentInfoBaliKocName => 'Король Корта (Bali Format)';

  @override
  String get tournamentInfoBaliKocBody =>
      'Версия Короля корта с фиксированными парами и начислением очков в зависимости от корта. Весь турнир вы играете с одним партнёром.\n\nКак играется. Пары распределяются по кортам-лестнице (корт 1 — верхний). Каждый раунд пара играет матч по геймам, после раунда пары двигаются: победители — выше, проигравшие — ниже. По лестнице двигается пара целиком, партнёр не меняется.\n\nОчки за матч (главная фишка). Очки получает только победитель матча, и их размер зависит от корта:\n— 1-й раунд: за победу 1 очко (стартовый расклад);\n— дальше: победа на корте K из N даёт (N + 2 − K) очков. То есть на верхнем корте победа «дороже всего», на нижнем — минимум.\nПоэтому выигрывать на королевском корте выгоднее, чем внизу.\n\nТаблица (по парам). Место: 1) очки; 2) личная встреча; 3) больше выигранных геймов; 4) разница геймов (6:0 выше, чем 6:2).\n\nСостав. Регистрация парами, пары фиксированы. Раунды генерирует организатор и завершает турнир, когда захочет.\n\nКто победил. Чемпион — пара с наибольшим числом очков. Мало просто побеждать — важно побеждать на верхних кортах.\n\nПример. 12 игроков = 6 пар = 3 корта (N=3). Победа на корте 1 = 3+2−1 = 4 очка, на корте 2 = 3, на корте 3 = 2. Пара, что доберётся до корта 1 и будет там выигрывать, быстро уйдёт в отрыв.\n\nКому подходит. Парам, которые хотят сыграть вместе весь турнир, и тем, кому нравится «весовая» система очков с борьбой за топовый корт.';

  @override
  String get tournamentInfoTeamName => 'Групповой + Плей-офф';

  @override
  String get tournamentInfoTeamBody =>
      'Командный формат с фиксированными парами: вы регистрируетесь парой (или организатор собирает пары), и эта пара играет весь турнир вместе. Два этапа — групповой и плей-офф.\n\nКак играется.\n1) Групповой этап. Команды распределяются по группам «змейкой» по рейтингу (чтобы группы были примерно равными). Внутри группы — круговая система: каждая пара играет с каждой. За победу +1 очко, за поражение 0, ничьих нет.\n2) Плей-офф. Лучшие команды из групп выходят в сетку на вылет (полуфиналы → финал, при необходимости — матч за 3-е место). Проиграл — вылетел.\n\nТаблица группы. Место: 1) очки (победы); 2) разница геймов (забил − пропустил); 3) больше забитых геймов.\n\nСостав. Регистрация парами, партнёр на весь турнир один. Конфигурацию сетки задаёт организатор (число групп, нижняя сетка, матч за бронзу).\n\nКто победил. Чемпион — победитель финала плей-офф. Групповой этап определяет, кто и с какого места попадёт в сетку.\n\nПример. 8 пар → 2 группы по 4. В группе каждый с каждым (по 3 матча), две лучшие пары из каждой группы выходят в полуфиналы крест-накрест, победители — в финал.\n\nКому подходит. Тем, кто хочет играть постоянным напарником и любит классическую турнирную драму: сначала отбор в группе, потом плей-офф навылет.';

  @override
  String get tournamentInfoFlexName => 'Americano Flex';

  @override
  String get tournamentInfoFlexBody =>
      'Гибкий Американо для любого числа игроков. Обычному Американо нужно строго кратно 4; здесь играть может почти любое число — лишние в раунде по очереди отдыхают.\n\nКак играется. Каждый раунд формируются матчи 2×2 с меняющимися партнёрами (как в Американо). Если игроков не хватает на ровные корты, часть садится отдыхать (bye). Отдых распределяется честно: первыми играют те, кто дольше отдыхал и меньше сыграл — со временем у всех примерно поровну матчей.\n\nЗачёт — личный, по среднему. Из-за отдыха число сыгранных матчей у всех разное, поэтому место считается по среднему количеству очков за матч (а не по сумме). Так никто не в плюсе и не в минусе из-за того, что сыграл больше или меньше.\n\nСостав. Подходит для «неудобного» числа участников, когда строгий Американо не собирается. Раунды генерирует организатор и завершает турнир в любой момент.\n\nПарный вариант. Флекс можно проводить и с фиксированными парами: тогда «атом» — пара, ротируются соперники и отдых, а партнёр на весь турнир один.\n\nКто победил. Первый — у кого лучший средний результат за матч.\n\nПример. 10 игроков, 2 корта = 8 играют, 2 отдыхают каждый раунд. Дальше отдыхают другие двое — и так по кругу. Если вы сыграли 6 матчей и набрали 36 очков (среднее 6), вы выше того, у кого 40 за 8 матчей (среднее 5).\n\nКому подходит. Когда собралось «некруглое» число игроков, но хочется честный Американо без простоев и с равными возможностями.';

  @override
  String get tournamentInfoEscaleraName => 'Ladder';

  @override
  String get tournamentInfoEscaleraBody =>
      'Лестница из кортов: наверху сильнейшие, внизу те, кто пока проигрывает. Каждый раунд четвёрка на корте играет три коротких матча, после чего двое лучших поднимаются на корт выше, двое последних опускаются ниже.\n\nКак играется. Игроков ровно корты × 4. Стартовая расстановка — по рейтингу: четверо сильнейших на корт 1, следующие четверо на корт 2 и так далее. Внутри корта играются три матча, чтобы каждый побывал в паре с каждым: 1+4 против 2+3, затем 1+3 против 2+4, затем 1+2 против 3+4.\n\nПеремещения. По сумме очков за три матча четвёрка выстраивается по местам. Двое первых уходят на корт выше, двое последних — на корт ниже. С верхнего корта наверх уходить некуда, поэтому пара лидеров там остаётся; на нижнем так же остаются двое последних. Состав корта обновляется каждый раунд целиком.\n\nСчёт. Формат короткого матча организатор объявляет сам — счёт вводится любой, ничья допустима.\n\nТаблица. Зачёт выбирается при создании турнира. По очкам — сумма забитых за все короткие матчи. По баллам за позиции — родной зачёт формата: номер корта встроен в позицию, поэтому подниматься наверх выгоднее, чем набивать очки внизу. При равенстве выше тот, кто выиграл больше матчей, затем — личная встреча, затем — рейтинг на старте.\n\nРейтинг. Начисляется за каждый короткий матч по обычной формуле Elo, то есть за вечер набегает много матчей — рейтинг может заметно качнуться.\n\nКому подходит. Тем, кто хочет играть с равными по силе: лестница сама разводит игроков по уровню за пару раундов.';

  @override
  String get filterDateCustom => 'Выбрать даты';

  @override
  String get smsLoginButton => 'SMS арқылы кіру';

  @override
  String get phoneLoginTitle => 'Нөмір арқылы кіру';

  @override
  String get phoneLoginSubtitle =>
      'Телефон нөміріңізді енгізіңіз — растау кодын жібереміз';

  @override
  String get getCodeButton => 'Код алу';

  @override
  String get registrationSubtitle => 'Жалғастыру үшін профильді толтырыңыз';

  @override
  String get fieldBirthDate => 'Туған күні';

  @override
  String get selectBirthDate => 'Күнді таңдаңыз';

  @override
  String get registrationFillAll => 'Барлық өрістерді толтырыңыз';

  @override
  String get deleteAccountCodeHint =>
      'Жоюды растау үшін SMS кодын енгізіңіз. Бұл әрекетті қайтару мүмкін емес.';

  @override
  String resendCodeIn(int seconds) {
    return '$seconds сек кейін қайта жіберу';
  }

  @override
  String get changePhoneButton => 'Нөмірді өзгерту';

  @override
  String get changePhoneTitle => 'Нөмірді өзгерту';

  @override
  String get changePhoneOldHint =>
      'Ағымдағы нөмірге жіберілген кодты енгізіңіз';

  @override
  String get changePhoneEnterNew => 'Жаңа телефон нөмірін енгізіңіз';

  @override
  String get changePhoneNewHint => 'Жаңа нөмірге жіберілген кодты енгізіңіз';

  @override
  String get changePhoneSuccess => 'Нөмір өзгертілді';

  @override
  String get chatTitle => 'Турнир чаты';

  @override
  String get chatModeAdmin => 'Тек ұйымдастырушы';

  @override
  String get chatModeParticipants => 'Қатысушылар';

  @override
  String get chatModeEveryone => 'Ашық чат';

  @override
  String get chatInputHint => 'Хабарлама…';

  @override
  String get chatLockedOnlyAdmin => 'Тек ұйымдастырушы жаза алады';

  @override
  String get chatReadOnlyFinished => 'Чат жабылды — тек оқу';

  @override
  String get chatEmpty => 'Әзірге хабарлама жоқ';

  @override
  String get chatDelete => 'Жою';

  @override
  String get chatOrganizerBadge => 'Ұйымдастырушы';

  @override
  String get chatSendFailed => 'Хабарлама жіберілмеді';

  @override
  String get chatRetry => 'Қайталау';

  @override
  String get chatToday => 'Бүгін';

  @override
  String get chatYesterday => 'Кеше';

  @override
  String get notifyBookingReminders => 'Брондау туралы еске салу';

  @override
  String get notifyBookingRemindersDesc =>
      'Корт бронынан бір тәулік, 2 сағат және бір сағат бұрын push';

  @override
  String get notifyOrganizerChat => 'Ұйымдастырушы чаты';

  @override
  String get notifyOrganizerChatDesc =>
      'Ұйымдастырушы турнир чатына жаңа хабарлама жазғанда пуш';

  @override
  String get sectionSettings => 'Баптаулар';

  @override
  String get sectionInfo => 'Ақпарат';

  @override
  String get sectionAccount => 'Аккаунт';

  @override
  String get coachTitle => 'Жаттықтырушы';

  @override
  String get coachScheduleButton => 'Кесте';

  @override
  String get coachScheduleButtonSubtitle => 'Сабақтар кестеңіз';

  @override
  String get coachBusyToday => 'Бүгін бос емес';

  @override
  String get coachSlotFree => 'Бос';

  @override
  String get coachSlotBooked => 'Бос емес';

  @override
  String get coachSlotBlocked => 'Бұғатталған';

  @override
  String get coachDayOff => 'Бұл күнге жұмыс сағаттары жоқ';

  @override
  String get hoursShort => 'сағ';

  @override
  String get tournamentDurationTitle => 'Турнир ұзақтығы';

  @override
  String get tournamentDurationSubtitle =>
      'Турнирдің ұзақтығы көрсетілмеген. Күнтізбеге қанша уақытқа қосуды таңдаңыз.';

  @override
  String get aiAnalysisButton => 'AI талдау';

  @override
  String get aiAnalysisTitle => 'Турнир талдауы';

  @override
  String get aiAnalysisLoading => 'AI сіздің ойыныңызды талдап жатыр…';

  @override
  String get aiAnalysisErrorTitle => 'Талдауды алу мүмкін болмады';

  @override
  String get aiAnalysisRetry => 'Қайталау';

  @override
  String get aiAnalysisFactorsTitle => 'Рейтингке не әсер етті';

  @override
  String get aiAnalysisBestMatch => 'Үздік матч';

  @override
  String get aiAnalysisWorstMatch => 'Әлсіз матч';

  @override
  String get aiAnalysisTipsTitle => 'Өсу үшін кеңестер';

  @override
  String get aiAnalysisFootnote => 'Матчтарыңыз негізінде AI жасаған';

  @override
  String get aiMatchesTitle => 'Матч бойынша талдау';

  @override
  String get aiYourPair => 'Сіздің жұбыңыз';

  @override
  String get aiOpponents => 'Қарсыластар';

  @override
  String get aiWinChance => 'Жеңу мүмкіндігі';

  @override
  String get aiResultWin => 'Жеңіс';

  @override
  String get aiResultLoss => 'Жеңіліс';

  @override
  String get aiMatchNoEffect => 'Матч рейтингке әсер етпеді (0:0)';

  @override
  String get aiMatchWinStrong => 'Күштірек жұпты жеңу — максимум ұпай';

  @override
  String get aiMatchWinExpected => 'Күтілген жеңіс — қосымша аз';

  @override
  String get aiMatchLossFavorite => 'Фаворитке жеңілу — жоғалту аз';

  @override
  String get aiMatchLossWeak => 'Әлсіз жұпқа жеңілу — жоғалту көбірек';

  @override
  String get servicesTitle => 'Сервистер';

  @override
  String get serviceBooking => 'Брондау';

  @override
  String get serviceClubs => 'Клубтар';

  @override
  String get serviceCommunity => 'Қауымдастық';

  @override
  String get serviceShop => 'Дүкен';

  @override
  String get serviceCreateGame => 'Ойын құру';

  @override
  String get serviceGames => 'Ойындар';

  @override
  String get serviceClubCards => 'Клуб карталары';

  @override
  String get serviceTournaments => 'Турнирлер';

  @override
  String get serviceCertificates => 'Сертификаттар';

  @override
  String get serviceComingSoon => 'Бөлім әзірленуде';

  @override
  String get certificatesTitle => 'Менің сертификаттарым';

  @override
  String get certActive => 'Белсенді';

  @override
  String get certUsed => 'Пайдаланылған';

  @override
  String get certStatusActive => 'Белсенді';

  @override
  String get certStatusUsed => 'Пайдаланылған';

  @override
  String get certDetailTitle => 'Сертификат';

  @override
  String get certOwner => 'Иесі';

  @override
  String get certBearer => 'Ұсынушыға';

  @override
  String get certShare => 'Бөлісу';

  @override
  String get certIssued => 'Берілген';

  @override
  String get certRedeemed => 'Пайдаланылған';

  @override
  String get certStamp => 'ӨТЕЛГЕН';

  @override
  String get certActiveUsable => 'Белсенді — пайдалануға болады';

  @override
  String get certActiveHint =>
      'Брондау кезінде осы нөмірді клуб әкімшісіне көрсетіңіз — ол сертификатты есептен шығарады.';

  @override
  String get certUsedHint =>
      'Бұл сертификат өтелген және енді пайдалануға болмайды.';

  @override
  String get certEmptyTitle => 'Әзірге сертификаттар жоқ';

  @override
  String get certEmptyText =>
      'Клуб сіздің телефон нөміріңізге сертификат бергенде, ол осы жерде пайда болады.';

  @override
  String get clubCardsTitle => 'Клуб карталары';

  @override
  String get clubCardsEmptyTitle => 'Сізде әзірге клуб карталары жоқ';

  @override
  String get clubCardsEmptyHint =>
      'Клуб картаны сіздің нөміріңізге рәсімдесе, ол осында автоматты түрде пайда болады';

  @override
  String get clubCardsActive => 'Белсенді';

  @override
  String get clubCardsArchive => 'Мұрағат';

  @override
  String get clubCardsNoActive => 'Белсенді карта жоқ';

  @override
  String get clubCardsArchiveEmpty => 'Мұрағат бос';

  @override
  String clubCardActiveTotal(int active, int total) {
    return '$active белсенді · барлығы $total';
  }

  @override
  String clubCardRemaining(int balance, int initial) {
    return '$initial ішінен $balance қалды';
  }

  @override
  String clubCardBalanceAfter(int balance) {
    return 'қалдық $balance';
  }

  @override
  String get clubCardUnlimited => 'Мерзімсіз';

  @override
  String get clubCardExpired => 'Мерзімі бітті';

  @override
  String get clubCardValidUntilShort => 'дейін';

  @override
  String get clubCardKindVisits => 'Сабақтар';

  @override
  String get clubCardKindTrainer => 'Жаттықтырушы';

  @override
  String get clubCardKindDiscountCourt => 'Кортқа жеңілдік';

  @override
  String get clubCardKindDiscountTrainer => 'Жаттықтырушыға жеңілдік';

  @override
  String get clubCardCodeLabel => 'Карта коды';

  @override
  String get clubCardValidUntilLabel => 'Дейін жарамды';

  @override
  String get clubCardBenefitsTitle => 'Карта не береді';

  @override
  String get clubCardHistoryTitle => 'Операциялар тарихы';

  @override
  String get clubCardHistoryEmpty => 'Әзірге операциялар жоқ';

  @override
  String get clubCardCharge => 'Есептен шығару';

  @override
  String get clubCardChargeBooking => 'Бронь үшін есептен шығару';

  @override
  String get clubCardBookingsButton => 'Карта бойынша брондар';

  @override
  String get clubCardBookingsEmpty => 'Бұл карта бойынша алдағы брондар жоқ';

  @override
  String clubCardBookingCancelHint(int hours) {
    return 'Басталуға $hours сағат қалғанша ғана болдырмауға болады';
  }

  @override
  String clubCardsCountShort(int count) {
    return '$count карта';
  }

  @override
  String get minutesShort => 'мин';

  @override
  String get bookingToday => 'бүгін';

  @override
  String get bookingTomorrow => 'ертең';

  @override
  String bookingInDays(int days) {
    return '$days күннен кейін';
  }

  @override
  String get gameDetailTitle => 'Ойын мәліметтері';

  @override
  String get gameCreateTitle => 'Ойын құру';

  @override
  String get gameSoon => 'Жақында';

  @override
  String get gameTitleFallback => 'Ойын';

  @override
  String get gameTypeRated => 'Рейтингтік';

  @override
  String get gameTypeFriendly => 'Достық';

  @override
  String get gameFormatSets => 'Сеттер бойынша';

  @override
  String get gameFormatPoints => 'Ұпайға дейін';

  @override
  String get gameFormatAmericano => 'Американо';

  @override
  String get gameJoinSlot => 'Орын алу';

  @override
  String get gameDetails => 'Толығырақ';

  @override
  String get gameScreenTitle => 'Ойындар';

  @override
  String get gameOpenTab => 'Ашық';

  @override
  String get gameMyTab => 'Менікі';

  @override
  String get gameEmptyOpen => 'Әзірге ашық ойындар жоқ';

  @override
  String get gameEmptyMy => 'Сізде әлі ойындар жоқ';

  @override
  String get gameCreateSubmit => 'Құру';

  @override
  String get gameFieldClub => 'Клуб';

  @override
  String get gameFieldDate => 'Күні';

  @override
  String get gameFieldTime => 'Уақыты';

  @override
  String get gameFieldDuration => 'Ұзақтығы';

  @override
  String get gameFieldType => 'Түрі';

  @override
  String get gameFieldVisibility => 'Көрінуі';

  @override
  String get gameVisibilityPublic => 'Ашық';

  @override
  String get gameVisibilityPrivate => 'Жеке';

  @override
  String get gameFieldFormat => 'Формат';

  @override
  String get gameFieldTiebreak => 'Тай-брейк';

  @override
  String get gamePointsMode => 'Ұпай режимі';

  @override
  String get gamePointsFirstTo => 'N ұпайға дейін';

  @override
  String get gamePointsTotal => 'Жалпы сомаға';

  @override
  String get gamePointsTarget => 'Жеңіске дейінгі ұпай';

  @override
  String get gamePointsCap => 'Ұпай шегі';

  @override
  String get gameAmSub => 'Қосымша формат';

  @override
  String get gameAmBySets => 'Сеттер бойынша';

  @override
  String get gameAmByTiebreak => 'Тай-брейк бойынша';

  @override
  String get gameAmByPoints => 'Ұпай бойынша';

  @override
  String get gameAmTarget => 'Мәні';

  @override
  String get gameFieldRatingRange => 'Деңгей диапазоны';

  @override
  String get gameRatingAny => 'Кез келген';

  @override
  String get gameFieldPrice => 'Бағасы, ₸';

  @override
  String get gameFieldDescription => 'Сипаттама';

  @override
  String get gameCreateValidationError => 'Міндетті өрістерді толтырыңыз';

  @override
  String gameDurationMin(int min) {
    return '$min мин';
  }

  @override
  String get gameStatusLabel => 'Мәртебесі';

  @override
  String get gamePlayersTitle => 'Қатысушылар';

  @override
  String get gameSlotFree => 'Бос';

  @override
  String get gamePlayerYou => 'сіз';

  @override
  String get gameStatusAccepted => 'Құрамда';

  @override
  String get gameStatusCandidate => 'Өтінім';

  @override
  String get gameStatusInvited => 'Шақырылды';

  @override
  String get gameShareTitle => 'Шақыру сілтемесі';

  @override
  String get gameShareActive => 'белсенді';

  @override
  String get gameShareInactive => 'белсенді емес';

  @override
  String get gamePriceLabel => 'Бағасы';

  @override
  String get gameOrganizerLabel => 'Ұйымдастырушы';

  @override
  String get gameActionAccept => 'Қабылдау';

  @override
  String get gameActionDecline => 'Бас тарту';

  @override
  String get gameActionApply => 'Өтінім беру';

  @override
  String get gameApplied => 'Өтінім жіберілді';

  @override
  String get gameActionLeave => 'Шығу';

  @override
  String get gameActionStart => 'Ойынды бастау';

  @override
  String get gameActionStartCancel => 'Стартты болдырмау';

  @override
  String get gameActionInvite => 'Шақыру';

  @override
  String get gameActionApprove => 'Мақұлдау';

  @override
  String get gameActionReject => 'Бас тарту';

  @override
  String get gameActionRemove => 'Жою';

  @override
  String get gameShareRotate => 'Сілтемені жаңарту';

  @override
  String get gameShareRevoke => 'Кері қайтару';

  @override
  String get gameShareCopied => 'Сілтеме көшірілді';

  @override
  String get gameInviteSearchHint => 'Ойыншының телефоны';

  @override
  String get gameInviteSearchBtn => 'Іздеу';

  @override
  String get gameInviteEmpty => 'Ешкім табылмады';

  @override
  String get gameLeaveConfirm => 'Ойыннан шығу керек пе?';

  @override
  String get gameRoundsTitle => 'Раундтар бойынша есеп';

  @override
  String gameRoundNo(int n) {
    return 'Раунд $n';
  }

  @override
  String get gameTeamA => 'A командасы';

  @override
  String get gameTeamB => 'B командасы';

  @override
  String get gameAddRound => 'Раунд қосу';

  @override
  String get gameRegenerate => 'Қайта жасау';

  @override
  String get gameRoundSave => 'Сақтау';

  @override
  String get gameRoundScoreA => 'A есебі';

  @override
  String get gameRoundScoreB => 'B есебі';

  @override
  String get gamePickTeamA => 'A командасын таңдаңыз (2 ойыншы)';

  @override
  String get gameRoundDeleteConfirm => 'Раундты жою керек пе?';

  @override
  String get gameActionFinish => 'Аяқтау';

  @override
  String get gameFinishConfirm => 'Ойынды аяқтап, есепті бекіту керек пе?';

  @override
  String get gameConfirmTitle => 'Есепті растау';

  @override
  String get gameConfirmBtn => 'Есепті растаймын';

  @override
  String get gameConfirmed => 'растады';

  @override
  String get gameNotConfirmed => 'күтуде';

  @override
  String get gameResultTitle => 'Қорытынды';

  @override
  String get gameRankingTitle => 'Рейтинг кестесі';

  @override
  String get gameRankPlace => 'Орын';

  @override
  String get gameRankPoints => 'Ұпай';

  @override
  String get gameRankWins => 'Жеңістер';

  @override
  String get gameRatingChange => 'Рейтинг';

  @override
  String gameResultPlace(int place) {
    return '$place-орын';
  }

  @override
  String get gameInvitationsTitle => 'Шақырулар';

  @override
  String get gameInvitationsEmpty => 'Шақырулар жоқ';

  @override
  String gameInvitedBy(String name) {
    return 'Шақырған: $name';
  }
}
