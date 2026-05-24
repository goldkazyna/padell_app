import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Padel KZ'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get navHome;

  /// No description provided for @navTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Турниры'**
  String get navTournaments;

  /// No description provided for @navChallenges.
  ///
  /// In ru, this message translates to:
  /// **'Игра'**
  String get navChallenges;

  /// No description provided for @navBooking.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование'**
  String get navBooking;

  /// No description provided for @ratingTabRating.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get ratingTabRating;

  /// No description provided for @ratingTabGrowth.
  ///
  /// In ru, this message translates to:
  /// **'Рост рейтинга'**
  String get ratingTabGrowth;

  /// No description provided for @ratingTabTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Турниры'**
  String get ratingTabTournaments;

  /// No description provided for @growthPeriodWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get growthPeriodWeek;

  /// No description provided for @growthPeriodMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get growthPeriodMonth;

  /// No description provided for @growthPeriodAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get growthPeriodAll;

  /// No description provided for @growthPoints.
  ///
  /// In ru, this message translates to:
  /// **'+{points}'**
  String growthPoints(int points);

  /// No description provided for @navRating.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get navRating;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @hello.
  ///
  /// In ru, this message translates to:
  /// **'Привет, {name}!'**
  String hello(String name);

  /// No description provided for @welcome.
  ///
  /// In ru, this message translates to:
  /// **'Добро пожаловать'**
  String get welcome;

  /// No description provided for @bookCourt.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать корт'**
  String get bookCourt;

  /// No description provided for @bookCourtSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите клуб и удобное время'**
  String get bookCourtSubtitle;

  /// No description provided for @nearestTournament.
  ///
  /// In ru, this message translates to:
  /// **'Ближайший турнир'**
  String get nearestTournament;

  /// No description provided for @activeTournament.
  ///
  /// In ru, this message translates to:
  /// **'Live турнир'**
  String get activeTournament;

  /// No description provided for @nearestTournamentInfo.
  ///
  /// In ru, this message translates to:
  /// **'Здесь показывается ваш ближайший турнир, на который вы записаны и который ещё не начался.'**
  String get nearestTournamentInfo;

  /// No description provided for @activeTournamentInfo.
  ///
  /// In ru, this message translates to:
  /// **'Здесь показывается турнир, в котором вы участвуете и который идёт прямо сейчас. Откройте его, чтобы в реальном времени (live) следить за матчами и счётом.'**
  String get activeTournamentInfo;

  /// No description provided for @upcoming.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get upcoming;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @rating.
  ///
  /// In ru, this message translates to:
  /// **'РЕЙТИНГ'**
  String get rating;

  /// No description provided for @level.
  ///
  /// In ru, this message translates to:
  /// **'УРОВЕНЬ'**
  String get level;

  /// No description provided for @place.
  ///
  /// In ru, this message translates to:
  /// **'МЕСТО'**
  String get place;

  /// No description provided for @matches.
  ///
  /// In ru, this message translates to:
  /// **'МАТЧЕЙ'**
  String get matches;

  /// No description provided for @wins.
  ///
  /// In ru, this message translates to:
  /// **'ПОБЕД'**
  String get wins;

  /// No description provided for @winrate.
  ///
  /// In ru, this message translates to:
  /// **'ВИНРЕЙТ'**
  String get winrate;

  /// No description provided for @losses.
  ///
  /// In ru, this message translates to:
  /// **'ПОРАЖ.'**
  String get losses;

  /// No description provided for @levelProgressLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {from} → {to}'**
  String levelProgressLabel(String from, String to);

  /// No description provided for @weekdayShortMon.
  ///
  /// In ru, this message translates to:
  /// **'ПН'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In ru, this message translates to:
  /// **'ВТ'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In ru, this message translates to:
  /// **'СР'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In ru, this message translates to:
  /// **'ЧТ'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In ru, this message translates to:
  /// **'ПТ'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In ru, this message translates to:
  /// **'СБ'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In ru, this message translates to:
  /// **'ВС'**
  String get weekdayShortSun;

  /// No description provided for @tournamentTypeAmericano.
  ///
  /// In ru, this message translates to:
  /// **'Американо'**
  String get tournamentTypeAmericano;

  /// No description provided for @tournamentTypeMexicano.
  ///
  /// In ru, this message translates to:
  /// **'Мексикано'**
  String get tournamentTypeMexicano;

  /// No description provided for @tournamentTypeKingOfCourt.
  ///
  /// In ru, this message translates to:
  /// **'Король корта'**
  String get tournamentTypeKingOfCourt;

  /// No description provided for @tournamentTypeBaliKoc.
  ///
  /// In ru, this message translates to:
  /// **'Король Корта (Bali Format)'**
  String get tournamentTypeBaliKoc;

  /// No description provided for @tournamentTypeTeam.
  ///
  /// In ru, this message translates to:
  /// **'Групповой + Плей-офф'**
  String get tournamentTypeTeam;

  /// No description provided for @tournamentTypeClassic.
  ///
  /// In ru, this message translates to:
  /// **'Классический'**
  String get tournamentTypeClassic;

  /// No description provided for @challengeCreateSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вызвать на игру'**
  String get challengeCreateSubtitle;

  /// No description provided for @challengesCardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Игры'**
  String get challengesCardTitle;

  /// No description provided for @challengesCardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Все вызовы'**
  String get challengesCardSubtitle;

  /// No description provided for @playerStatRating.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get playerStatRating;

  /// No description provided for @playerStatGames.
  ///
  /// In ru, this message translates to:
  /// **'Игры'**
  String get playerStatGames;

  /// No description provided for @playerStatWins.
  ///
  /// In ru, this message translates to:
  /// **'Побед'**
  String get playerStatWins;

  /// No description provided for @playerStatTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Турниры'**
  String get playerStatTournaments;

  /// No description provided for @developerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Разработчик'**
  String get developerLabel;

  /// No description provided for @filterLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень'**
  String get filterLevel;

  /// No description provided for @filterMyLevel.
  ///
  /// In ru, this message translates to:
  /// **'Мой уровень'**
  String get filterMyLevel;

  /// No description provided for @filterFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get filterFormat;

  /// No description provided for @filterFormatWithCount.
  ///
  /// In ru, this message translates to:
  /// **'Формат · {count}'**
  String filterFormatWithCount(int count);

  /// No description provided for @filterDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get filterDate;

  /// No description provided for @filterDateTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get filterDateTomorrow;

  /// No description provided for @filterDateWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get filterDateWeek;

  /// No description provided for @filterClub.
  ///
  /// In ru, this message translates to:
  /// **'Клуб'**
  String get filterClub;

  /// No description provided for @filterClubWithCount.
  ///
  /// In ru, this message translates to:
  /// **'Клуб · {count}'**
  String filterClubWithCount(int count);

  /// No description provided for @filterCommunity.
  ///
  /// In ru, this message translates to:
  /// **'Комьюнити'**
  String get filterCommunity;

  /// No description provided for @forYouSection.
  ///
  /// In ru, this message translates to:
  /// **'Для вас'**
  String get forYouSection;

  /// No description provided for @tournamentLevelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень турнира'**
  String get tournamentLevelLabel;

  /// No description provided for @levelSuits.
  ///
  /// In ru, this message translates to:
  /// **'Подходит'**
  String get levelSuits;

  /// No description provided for @levelDoesNotSuit.
  ///
  /// In ru, this message translates to:
  /// **'Не подходит'**
  String get levelDoesNotSuit;

  /// No description provided for @yourLevelMark.
  ///
  /// In ru, this message translates to:
  /// **'вы {level}'**
  String yourLevelMark(String level);

  /// No description provided for @notifyButton.
  ///
  /// In ru, this message translates to:
  /// **'Уведомить'**
  String get notifyButton;

  /// No description provided for @subscribedButton.
  ///
  /// In ru, this message translates to:
  /// **'Подписан'**
  String get subscribedButton;

  /// No description provided for @dateAll.
  ///
  /// In ru, this message translates to:
  /// **'Все даты'**
  String get dateAll;

  /// No description provided for @dateThisWeek.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе'**
  String get dateThisWeek;

  /// No description provided for @tournamentStatusDraft.
  ///
  /// In ru, this message translates to:
  /// **'Черновик'**
  String get tournamentStatusDraft;

  /// No description provided for @tournamentStatusOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыта регистрация'**
  String get tournamentStatusOpen;

  /// No description provided for @tournamentStatusClosed.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация закрыта'**
  String get tournamentStatusClosed;

  /// No description provided for @tournamentStatusInProgress.
  ///
  /// In ru, this message translates to:
  /// **'Идёт турнир'**
  String get tournamentStatusInProgress;

  /// No description provided for @tournamentStatusCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Завершён'**
  String get tournamentStatusCompleted;

  /// No description provided for @tournamentStatusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get tournamentStatusCancelled;

  /// No description provided for @sectionContacts.
  ///
  /// In ru, this message translates to:
  /// **'КОНТАКТЫ'**
  String get sectionContacts;

  /// No description provided for @sectionAbout.
  ///
  /// In ru, this message translates to:
  /// **'О ВАС'**
  String get sectionAbout;

  /// No description provided for @sectionGameStyle.
  ///
  /// In ru, this message translates to:
  /// **'ИГРОВОЙ СТИЛЬ'**
  String get sectionGameStyle;

  /// No description provided for @nameHint.
  ///
  /// In ru, this message translates to:
  /// **'Укажите имя'**
  String get nameHint;

  /// No description provided for @agePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Укажите дату рождения'**
  String get agePlaceholder;

  /// No description provided for @saveChanges.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить изменения'**
  String get saveChanges;

  /// No description provided for @profileNameless.
  ///
  /// In ru, this message translates to:
  /// **'Без имени'**
  String get profileNameless;

  /// No description provided for @profileFilled.
  ///
  /// In ru, this message translates to:
  /// **'Профиль заполнен'**
  String get profileFilled;

  /// No description provided for @profileFillBio.
  ///
  /// In ru, this message translates to:
  /// **'Заполните возраст и позицию на корте, чтобы находить пары'**
  String get profileFillBio;

  /// No description provided for @profileFillAge.
  ///
  /// In ru, this message translates to:
  /// **'Укажите возраст, чтобы было проще найти партнёра'**
  String get profileFillAge;

  /// No description provided for @profileFillPosition.
  ///
  /// In ru, this message translates to:
  /// **'Укажите позицию на корте'**
  String get profileFillPosition;

  /// No description provided for @profileFillHand.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте ведущую руку'**
  String get profileFillHand;

  /// No description provided for @profileFillGender.
  ///
  /// In ru, this message translates to:
  /// **'Укажите пол'**
  String get profileFillGender;

  /// No description provided for @profileFillCity.
  ///
  /// In ru, this message translates to:
  /// **'Выберите город'**
  String get profileFillCity;

  /// No description provided for @fieldHand.
  ///
  /// In ru, this message translates to:
  /// **'Ведущая рука'**
  String get fieldHand;

  /// No description provided for @fieldPosition.
  ///
  /// In ru, this message translates to:
  /// **'Позиция на корте'**
  String get fieldPosition;

  /// No description provided for @fieldGender.
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get fieldGender;

  /// No description provided for @rankInRatingShort.
  ///
  /// In ru, this message translates to:
  /// **'#{n} в рейтинге'**
  String rankInRatingShort(int n);

  /// No description provided for @ratingValueShort.
  ///
  /// In ru, this message translates to:
  /// **'{n} рейтинг'**
  String ratingValueShort(int n);

  /// No description provided for @notFilled.
  ///
  /// In ru, this message translates to:
  /// **'Не заполнено'**
  String get notFilled;

  /// No description provided for @selectClub.
  ///
  /// In ru, this message translates to:
  /// **'Выберите клуб'**
  String get selectClub;

  /// No description provided for @searchClub.
  ///
  /// In ru, this message translates to:
  /// **'Поиск клуба...'**
  String get searchClub;

  /// No description provided for @allCities.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allCities;

  /// No description provided for @courtsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} {count, plural, one{корт} few{корта} other{кортов}}'**
  String courtsCount(int count);

  /// No description provided for @priceFrom.
  ///
  /// In ru, this message translates to:
  /// **'от {price} ₸'**
  String priceFrom(String price);

  /// No description provided for @noClubsFound.
  ///
  /// In ru, this message translates to:
  /// **'Клубов не найдено'**
  String get noClubsFound;

  /// No description provided for @booking.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование'**
  String get booking;

  /// No description provided for @court.
  ///
  /// In ru, this message translates to:
  /// **'Корт'**
  String get court;

  /// No description provided for @date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get time;

  /// No description provided for @start.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get start;

  /// No description provided for @duration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get duration;

  /// No description provided for @total.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get total;

  /// No description provided for @coach.
  ///
  /// In ru, this message translates to:
  /// **'Тренер'**
  String get coach;

  /// No description provided for @coachOptional.
  ///
  /// In ru, this message translates to:
  /// **'Тренер (необязательно)'**
  String get coachOptional;

  /// No description provided for @yourName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get yourName;

  /// No description provided for @phone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// No description provided for @comment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get comment;

  /// No description provided for @optional.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно'**
  String get optional;

  /// No description provided for @enterName.
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get enterName;

  /// No description provided for @bookButton.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать — {price} ₸'**
  String bookButton(String price);

  /// No description provided for @payOnlineButton.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить онлайн — {price} ₸'**
  String payOnlineButton(String price);

  /// No description provided for @bookWithoutPaymentButton.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать без оплаты'**
  String get bookWithoutPaymentButton;

  /// No description provided for @onlinePaymentComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-оплата скоро будет доступна'**
  String get onlinePaymentComingSoon;

  /// No description provided for @agreeWithDocsPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Я соглашаюсь с '**
  String get agreeWithDocsPrefix;

  /// No description provided for @docOfferAgreement.
  ///
  /// In ru, this message translates to:
  /// **'Договором оферты'**
  String get docOfferAgreement;

  /// No description provided for @docPrivacyPolicy.
  ///
  /// In ru, this message translates to:
  /// **'Политикой конфиденциальности'**
  String get docPrivacyPolicy;

  /// No description provided for @docGoodsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описанием товаров и услуг'**
  String get docGoodsDescription;

  /// No description provided for @docCardPayment.
  ///
  /// In ru, this message translates to:
  /// **'Условиями оплаты картой'**
  String get docCardPayment;

  /// No description provided for @bookingConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Бронь подтверждена!'**
  String get bookingConfirmed;

  /// No description provided for @bookingConfirmedSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы успешно забронировали корт'**
  String get bookingConfirmedSubtitle;

  /// No description provided for @myBookings.
  ///
  /// In ru, this message translates to:
  /// **'Мои бронирования'**
  String get myBookings;

  /// No description provided for @goHome.
  ///
  /// In ru, this message translates to:
  /// **'На главную'**
  String get goHome;

  /// No description provided for @upcomingBookings.
  ///
  /// In ru, this message translates to:
  /// **'Предстоящие'**
  String get upcomingBookings;

  /// No description provided for @pastBookings.
  ///
  /// In ru, this message translates to:
  /// **'Прошедшие'**
  String get pastBookings;

  /// No description provided for @noUpcomingBookings.
  ///
  /// In ru, this message translates to:
  /// **'Нет предстоящих бронирований'**
  String get noUpcomingBookings;

  /// No description provided for @noPastBookings.
  ///
  /// In ru, this message translates to:
  /// **'Нет прошедших бронирований'**
  String get noPastBookings;

  /// No description provided for @statusPending.
  ///
  /// In ru, this message translates to:
  /// **'Новая заявка'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждено'**
  String get statusConfirmed;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get statusCancelled;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get cancel;

  /// No description provided for @cancelBooking.
  ///
  /// In ru, this message translates to:
  /// **'Отменить бронирование?'**
  String get cancelBooking;

  /// No description provided for @areYouSure.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены?'**
  String get areYouSure;

  /// No description provided for @yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get no;

  /// No description provided for @yesCancelIt.
  ///
  /// In ru, this message translates to:
  /// **'Да, отменить'**
  String get yesCancelIt;

  /// No description provided for @bookingCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование отменено'**
  String get bookingCancelled;

  /// No description provided for @cancelError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка отмены'**
  String get cancelError;

  /// No description provided for @occupied.
  ///
  /// In ru, this message translates to:
  /// **'Занято'**
  String get occupied;

  /// No description provided for @blocked.
  ///
  /// In ru, this message translates to:
  /// **'Заблок.'**
  String get blocked;

  /// No description provided for @free.
  ///
  /// In ru, this message translates to:
  /// **'Свободен'**
  String get free;

  /// No description provided for @noCourtsAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных кортов'**
  String get noCourtsAvailable;

  /// No description provided for @noSlotsForDay.
  ///
  /// In ru, this message translates to:
  /// **'Нет слотов на этот день'**
  String get noSlotsForDay;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @hourOne.
  ///
  /// In ru, this message translates to:
  /// **'час'**
  String get hourOne;

  /// No description provided for @hourFew.
  ///
  /// In ru, this message translates to:
  /// **'часа'**
  String get hourFew;

  /// No description provided for @hourMany.
  ///
  /// In ru, this message translates to:
  /// **'часов'**
  String get hourMany;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @notifCategoryGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Общие'**
  String get notifCategoryGeneral;

  /// No description provided for @notificationSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки уведомлений'**
  String get notificationSettings;

  /// No description provided for @bookedCourts.
  ///
  /// In ru, this message translates to:
  /// **'Забронированные корты'**
  String get bookedCourts;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logoutSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Безвозвратное удаление'**
  String get deleteAccountSubtitle;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @networkError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сети. Проверьте подключение к интернету.'**
  String get networkError;

  /// No description provided for @loadError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки данных'**
  String get loadError;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @russian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsMenuItem.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsMenuItem;

  /// No description provided for @settingsMenuItemSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отображение рейтинга и уровня'**
  String get settingsMenuItemSubtitle;

  /// No description provided for @preciseRatingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Точные значения рейтинга'**
  String get preciseRatingTitle;

  /// No description provided for @preciseRatingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Показывать рейтинг и уровень с двумя знаками (2.69 вместо 2690)'**
  String get preciseRatingSubtitle;

  /// No description provided for @newsChannelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Последние новости приложения'**
  String get newsChannelTitle;

  /// No description provided for @newsChannelSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Telegram-канал @padelkz_app'**
  String get newsChannelSubtitle;

  /// No description provided for @newsChannelButton.
  ///
  /// In ru, this message translates to:
  /// **'Последние новости приложения'**
  String get newsChannelButton;

  /// No description provided for @calendarLink.
  ///
  /// In ru, this message translates to:
  /// **'Календарь →'**
  String get calendarLink;

  /// No description provided for @calendarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Календарь турниров'**
  String get calendarTitle;

  /// No description provided for @calendarNoTournamentsForDay.
  ///
  /// In ru, this message translates to:
  /// **'На этот день турниров нет'**
  String get calendarNoTournamentsForDay;

  /// No description provided for @calendarAllTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Все турниры →'**
  String get calendarAllTournaments;

  /// No description provided for @calendarSeats.
  ///
  /// In ru, this message translates to:
  /// **'{filled}/{max} мест'**
  String calendarSeats(int filled, int max);

  /// No description provided for @calendarSeatsLeft.
  ///
  /// In ru, this message translates to:
  /// **'Осталось {n}'**
  String calendarSeatsLeft(int n);

  /// No description provided for @calendarTodayDow.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get calendarTodayDow;

  /// No description provided for @calendarEmptyAll.
  ///
  /// In ru, this message translates to:
  /// **'В ближайшие 14 дней турниров нет'**
  String get calendarEmptyAll;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Записаться'**
  String get register;

  /// No description provided for @registered.
  ///
  /// In ru, this message translates to:
  /// **'Вы записаны'**
  String get registered;

  /// No description provided for @levelShort.
  ///
  /// In ru, this message translates to:
  /// **'Ур. {level}'**
  String levelShort(String level);

  /// No description provided for @noAvailableTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных турниров'**
  String get noAvailableTournaments;

  /// No description provided for @notInTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Вы не участвуете в турнирах'**
  String get notInTournaments;

  /// No description provided for @details.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get details;

  /// No description provided for @chooseTournament.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать турнир'**
  String get chooseTournament;

  /// No description provided for @noUpcomingTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Нет предстоящих турниров'**
  String get noUpcomingTournaments;

  /// No description provided for @tournaments.
  ///
  /// In ru, this message translates to:
  /// **'Турниры'**
  String get tournaments;

  /// No description provided for @openTab.
  ///
  /// In ru, this message translates to:
  /// **'Открытые'**
  String get openTab;

  /// No description provided for @myTab.
  ///
  /// In ru, this message translates to:
  /// **'Мои'**
  String get myTab;

  /// No description provided for @archiveTab.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archiveTab;

  /// No description provided for @cancelledTab.
  ///
  /// In ru, this message translates to:
  /// **'Отменённые'**
  String get cancelledTab;

  /// No description provided for @noCancelledTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Нет отменённых турниров'**
  String get noCancelledTournaments;

  /// No description provided for @noOpenTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Нет открытых турниров'**
  String get noOpenTournaments;

  /// No description provided for @notRegisteredForTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Вы не записаны на турниры'**
  String get notRegisteredForTournaments;

  /// No description provided for @noFinishedTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Нет завершённых турниров'**
  String get noFinishedTournaments;

  /// No description provided for @tournamentRegistered.
  ///
  /// In ru, this message translates to:
  /// **'Записан'**
  String get tournamentRegistered;

  /// No description provided for @noSpotsLeft.
  ///
  /// In ru, this message translates to:
  /// **'Мест нет'**
  String get noSpotsLeft;

  /// No description provided for @clubTournamentsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} {count, plural, one{турнир} few{турнира} other{турниров}}'**
  String clubTournamentsCount(int count);

  /// No description provided for @failedToLoadTournament.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить турнир'**
  String get failedToLoadTournament;

  /// No description provided for @shareFreeSpots.
  ///
  /// In ru, this message translates to:
  /// **'Свободных мест: {count}'**
  String shareFreeSpots(int count);

  /// No description provided for @shareLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень: {level}'**
  String shareLevel(String level);

  /// No description provided for @shareCost.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость: {cost}'**
  String shareCost(String cost);

  /// No description provided for @shareAppPromo.
  ///
  /// In ru, this message translates to:
  /// **'Padel KZ — скачай приложение и записывайся на турниры!'**
  String get shareAppPromo;

  /// No description provided for @noSpotsLeftUpper.
  ///
  /// In ru, this message translates to:
  /// **'МЕСТ НЕТ'**
  String get noSpotsLeftUpper;

  /// No description provided for @dateLabel.
  ///
  /// In ru, this message translates to:
  /// **'ДАТА'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In ru, this message translates to:
  /// **'ВРЕМЯ'**
  String get timeLabel;

  /// No description provided for @levelLabel.
  ///
  /// In ru, this message translates to:
  /// **'УРОВЕНЬ'**
  String get levelLabel;

  /// No description provided for @costLabel.
  ///
  /// In ru, this message translates to:
  /// **'СТОИМОСТЬ'**
  String get costLabel;

  /// No description provided for @perPerson.
  ///
  /// In ru, this message translates to:
  /// **'за человека'**
  String get perPerson;

  /// No description provided for @pay.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить'**
  String get pay;

  /// No description provided for @pendingModeration.
  ///
  /// In ru, this message translates to:
  /// **'На модерации'**
  String get pendingModeration;

  /// No description provided for @participants.
  ///
  /// In ru, this message translates to:
  /// **'Участники'**
  String get participants;

  /// No description provided for @countOfMax.
  ///
  /// In ru, this message translates to:
  /// **'{count} из {max}'**
  String countOfMax(int count, int max);

  /// No description provided for @noParticipantsYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет участников'**
  String get noParticipantsYet;

  /// No description provided for @spotsLeftCount.
  ///
  /// In ru, this message translates to:
  /// **'Ещё {count} свободных мест'**
  String spotsLeftCount(int count);

  /// No description provided for @pendingStatus.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание'**
  String get pendingStatus;

  /// No description provided for @organizer.
  ///
  /// In ru, this message translates to:
  /// **'Организатор'**
  String get organizer;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Записаться'**
  String get registerButton;

  /// No description provided for @applicationPending.
  ///
  /// In ru, this message translates to:
  /// **'Заявка на модерации'**
  String get applicationPending;

  /// No description provided for @cancelApplication.
  ///
  /// In ru, this message translates to:
  /// **'Отменить заявку'**
  String get cancelApplication;

  /// No description provided for @cancelRegistration.
  ///
  /// In ru, this message translates to:
  /// **'Отменить запись'**
  String get cancelRegistration;

  /// No description provided for @youAreParticipating.
  ///
  /// In ru, this message translates to:
  /// **'Вы участвуете'**
  String get youAreParticipating;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'ОК'**
  String get ok;

  /// No description provided for @choosePartner.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать партнёра'**
  String get choosePartner;

  /// No description provided for @subscriptionActive.
  ///
  /// In ru, this message translates to:
  /// **'Подписка активна'**
  String get subscriptionActive;

  /// No description provided for @notifyOnFreeSpot.
  ///
  /// In ru, this message translates to:
  /// **'Уведомить о свободном месте'**
  String get notifyOnFreeSpot;

  /// No description provided for @matchesLabel.
  ///
  /// In ru, this message translates to:
  /// **'МАТЧЕЙ'**
  String get matchesLabel;

  /// No description provided for @winsLabel.
  ///
  /// In ru, this message translates to:
  /// **'ПОБЕДЫ'**
  String get winsLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In ru, this message translates to:
  /// **'РЕЙТИНГ'**
  String get ratingLabel;

  /// No description provided for @matchesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Матчи'**
  String get matchesTitle;

  /// No description provided for @roundsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} раундов'**
  String roundsCount(int count);

  /// No description provided for @resultDraw.
  ///
  /// In ru, this message translates to:
  /// **'НИЧЬЯ'**
  String get resultDraw;

  /// No description provided for @resultWin.
  ///
  /// In ru, this message translates to:
  /// **'ПОБЕДА'**
  String get resultWin;

  /// No description provided for @resultLoss.
  ///
  /// In ru, this message translates to:
  /// **'ПОРАЖЕНИЕ'**
  String get resultLoss;

  /// No description provided for @placeResult.
  ///
  /// In ru, this message translates to:
  /// **'{place} место'**
  String placeResult(int place);

  /// No description provided for @teamConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждена'**
  String get teamConfirmed;

  /// No description provided for @yourTeam.
  ///
  /// In ru, this message translates to:
  /// **'Ваша команда'**
  String get yourTeam;

  /// No description provided for @teams.
  ///
  /// In ru, this message translates to:
  /// **'Команды'**
  String get teams;

  /// No description provided for @noTeamsYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет команд'**
  String get noTeamsYet;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона'**
  String get enterPhoneNumber;

  /// No description provided for @playersNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Игроки не найдены'**
  String get playersNotFound;

  /// No description provided for @registerWith.
  ///
  /// In ru, this message translates to:
  /// **'Записаться с {name}'**
  String registerWith(String name);

  /// No description provided for @challenge.
  ///
  /// In ru, this message translates to:
  /// **'Игра'**
  String get challenge;

  /// No description provided for @challengeHint.
  ///
  /// In ru, this message translates to:
  /// **'Находите соперников и играйте рейтинговые или товарищеские матчи'**
  String get challengeHint;

  /// No description provided for @challengeOpenTab.
  ///
  /// In ru, this message translates to:
  /// **'Открытые'**
  String get challengeOpenTab;

  /// No description provided for @challengeMyTab.
  ///
  /// In ru, this message translates to:
  /// **'Мои'**
  String get challengeMyTab;

  /// No description provided for @noOpenChallenges.
  ///
  /// In ru, this message translates to:
  /// **'Нет открытых игр'**
  String get noOpenChallenges;

  /// No description provided for @noMyChallenges.
  ///
  /// In ru, this message translates to:
  /// **'У вас нет игр'**
  String get noMyChallenges;

  /// No description provided for @challengeNotSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get challengeNotSpecified;

  /// No description provided for @challengeLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String challengeLevel(String level);

  /// No description provided for @challengeRated.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинговый'**
  String get challengeRated;

  /// No description provided for @challengeFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Товарищеский'**
  String get challengeFriendly;

  /// No description provided for @challengeJoinSlot.
  ///
  /// In ru, this message translates to:
  /// **'Занять место'**
  String get challengeJoinSlot;

  /// No description provided for @challengeDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get challengeDetails;

  /// No description provided for @challengeChoosePosition.
  ///
  /// In ru, this message translates to:
  /// **'Выберите позицию'**
  String get challengeChoosePosition;

  /// No description provided for @challengePositionHint.
  ///
  /// In ru, this message translates to:
  /// **'Позиции 1-2 — Команда A, 3-4 — Команда B'**
  String get challengePositionHint;

  /// No description provided for @challengeTeamA.
  ///
  /// In ru, this message translates to:
  /// **'Команда A'**
  String get challengeTeamA;

  /// No description provided for @challengeTeamB.
  ///
  /// In ru, this message translates to:
  /// **'Команда B'**
  String get challengeTeamB;

  /// No description provided for @challengeCancelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отменить игру?'**
  String get challengeCancelTitle;

  /// No description provided for @challengeCancelConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите отменить игру?'**
  String get challengeCancelConfirm;

  /// No description provided for @challengeYesCancel.
  ///
  /// In ru, this message translates to:
  /// **'Да, отменить'**
  String get challengeYesCancel;

  /// No description provided for @challengeEnterScore.
  ///
  /// In ru, this message translates to:
  /// **'Введите счёт хотя бы в одном сете'**
  String get challengeEnterScore;

  /// No description provided for @challengeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Игра не найдена'**
  String get challengeNotFound;

  /// No description provided for @challengeScore.
  ///
  /// In ru, this message translates to:
  /// **'СЧЁТ'**
  String get challengeScore;

  /// No description provided for @challengeAddSet.
  ///
  /// In ru, this message translates to:
  /// **'Добавить сет'**
  String get challengeAddSet;

  /// No description provided for @challengeFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить игру'**
  String get challengeFinish;

  /// No description provided for @challengeScoreCreatorHint.
  ///
  /// In ru, this message translates to:
  /// **'Счёт вводит создатель игры. После завершения вы сможете подтвердить результат.'**
  String get challengeScoreCreatorHint;

  /// No description provided for @challengeResult.
  ///
  /// In ru, this message translates to:
  /// **'РЕЗУЛЬТАТ'**
  String get challengeResult;

  /// No description provided for @challengeSetScore.
  ///
  /// In ru, this message translates to:
  /// **'Сет {index}    {scoreA} : {scoreB}'**
  String challengeSetScore(int index, int scoreA, int scoreB);

  /// No description provided for @challengeConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердил'**
  String get challengeConfirmed;

  /// No description provided for @challengeWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание'**
  String get challengeWaiting;

  /// No description provided for @challengeConfirmScore.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждаю счёт'**
  String get challengeConfirmScore;

  /// No description provided for @challengeScoreConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Вы подтвердили счёт'**
  String get challengeScoreConfirmed;

  /// No description provided for @challengeTeamAWin.
  ///
  /// In ru, this message translates to:
  /// **'Победа команды A'**
  String get challengeTeamAWin;

  /// No description provided for @challengeTeamBWin.
  ///
  /// In ru, this message translates to:
  /// **'Победа команды B'**
  String get challengeTeamBWin;

  /// No description provided for @challengeDraw.
  ///
  /// In ru, this message translates to:
  /// **'Ничья'**
  String get challengeDraw;

  /// No description provided for @challengeSetLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сет {index}'**
  String challengeSetLabel(int index);

  /// No description provided for @challengeAccept.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get challengeAccept;

  /// No description provided for @challengeDecline.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить'**
  String get challengeDecline;

  /// No description provided for @challengeWaitingInvites.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание подтверждения приглашённых игроков'**
  String get challengeWaitingInvites;

  /// No description provided for @challengeNeedMorePlayers.
  ///
  /// In ru, this message translates to:
  /// **'Для начала нужно ещё {count} {count, plural, one{игрок} other{игрока}}'**
  String challengeNeedMorePlayers(int count);

  /// No description provided for @challengeStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать игру'**
  String get challengeStart;

  /// No description provided for @challengeCancelButton.
  ///
  /// In ru, this message translates to:
  /// **'Отменить игру'**
  String get challengeCancelButton;

  /// No description provided for @challengeLeave.
  ///
  /// In ru, this message translates to:
  /// **'Покинуть'**
  String get challengeLeave;

  /// No description provided for @challengeAddPlayer.
  ///
  /// In ru, this message translates to:
  /// **'Добавить игрока'**
  String get challengeAddPlayer;

  /// No description provided for @challengePositionTeam.
  ///
  /// In ru, this message translates to:
  /// **'Позиция {position} · {team}'**
  String challengePositionTeam(int position, String team);

  /// No description provided for @challengePhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get challengePhoneHint;

  /// No description provided for @challengeNobodyFound.
  ///
  /// In ru, this message translates to:
  /// **'Никого не найдено'**
  String get challengeNobodyFound;

  /// No description provided for @challengeLeaveOpen.
  ///
  /// In ru, this message translates to:
  /// **'Оставить открытым'**
  String get challengeLeaveOpen;

  /// No description provided for @challengeYou.
  ///
  /// In ru, this message translates to:
  /// **'Вы'**
  String get challengeYou;

  /// No description provided for @challengeSpecifyDateTime.
  ///
  /// In ru, this message translates to:
  /// **'Укажите дату и время'**
  String get challengeSpecifyDateTime;

  /// No description provided for @challengeErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get challengeErrorTitle;

  /// No description provided for @challengeDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get challengeDoneTitle;

  /// No description provided for @challengeMonthJan.
  ///
  /// In ru, this message translates to:
  /// **'января'**
  String get challengeMonthJan;

  /// No description provided for @challengeMonthFeb.
  ///
  /// In ru, this message translates to:
  /// **'февраля'**
  String get challengeMonthFeb;

  /// No description provided for @challengeMonthMar.
  ///
  /// In ru, this message translates to:
  /// **'марта'**
  String get challengeMonthMar;

  /// No description provided for @challengeMonthApr.
  ///
  /// In ru, this message translates to:
  /// **'апреля'**
  String get challengeMonthApr;

  /// No description provided for @challengeMonthMay.
  ///
  /// In ru, this message translates to:
  /// **'мая'**
  String get challengeMonthMay;

  /// No description provided for @challengeMonthJun.
  ///
  /// In ru, this message translates to:
  /// **'июня'**
  String get challengeMonthJun;

  /// No description provided for @challengeMonthJul.
  ///
  /// In ru, this message translates to:
  /// **'июля'**
  String get challengeMonthJul;

  /// No description provided for @challengeMonthAug.
  ///
  /// In ru, this message translates to:
  /// **'августа'**
  String get challengeMonthAug;

  /// No description provided for @challengeMonthSep.
  ///
  /// In ru, this message translates to:
  /// **'сентября'**
  String get challengeMonthSep;

  /// No description provided for @challengeMonthOct.
  ///
  /// In ru, this message translates to:
  /// **'октября'**
  String get challengeMonthOct;

  /// No description provided for @challengeMonthNov.
  ///
  /// In ru, this message translates to:
  /// **'ноября'**
  String get challengeMonthNov;

  /// No description provided for @challengeMonthDec.
  ///
  /// In ru, this message translates to:
  /// **'декабря'**
  String get challengeMonthDec;

  /// No description provided for @challengeNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая игра'**
  String get challengeNewTitle;

  /// No description provided for @challengeDatePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get challengeDatePlaceholder;

  /// No description provided for @challengeTimePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get challengeTimePlaceholder;

  /// No description provided for @challengeType.
  ///
  /// In ru, this message translates to:
  /// **'Тип игры'**
  String get challengeType;

  /// No description provided for @challengeMinLevel.
  ///
  /// In ru, this message translates to:
  /// **'Мин. уровень'**
  String get challengeMinLevel;

  /// No description provided for @challengeMaxLevel.
  ///
  /// In ru, this message translates to:
  /// **'Макс. уровень'**
  String get challengeMaxLevel;

  /// No description provided for @challengeCourtLayout.
  ///
  /// In ru, this message translates to:
  /// **'РАССТАНОВКА НА КОРТЕ'**
  String get challengeCourtLayout;

  /// No description provided for @challengeCreateButton.
  ///
  /// In ru, this message translates to:
  /// **'Создать игру'**
  String get challengeCreateButton;

  /// No description provided for @challengeLoadingClubs.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get challengeLoadingClubs;

  /// No description provided for @challengeClubOptional.
  ///
  /// In ru, this message translates to:
  /// **'Клуб (необязательно)'**
  String get challengeClubOptional;

  /// No description provided for @challengeNoClub.
  ///
  /// In ru, this message translates to:
  /// **'Без клуба'**
  String get challengeNoClub;

  /// No description provided for @courtNet.
  ///
  /// In ru, this message translates to:
  /// **'СЕТКА'**
  String get courtNet;

  /// No description provided for @courtInvite.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить'**
  String get courtInvite;

  /// No description provided for @courtFreeSlot.
  ///
  /// In ru, this message translates to:
  /// **'Свободно'**
  String get courtFreeSlot;

  /// No description provided for @ratingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get ratingTitle;

  /// No description provided for @ratingSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по имени...'**
  String get ratingSearchHint;

  /// No description provided for @ratingPlayerHeader.
  ///
  /// In ru, this message translates to:
  /// **'ИГРОК'**
  String get ratingPlayerHeader;

  /// No description provided for @ratingPointsHeader.
  ///
  /// In ru, this message translates to:
  /// **'ОЧКИ'**
  String get ratingPointsHeader;

  /// No description provided for @ratingPlayersNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Игроки не найдены'**
  String get ratingPlayersNotFound;

  /// No description provided for @ratingRemainingPlayers.
  ///
  /// In ru, this message translates to:
  /// **'{count} игроков'**
  String ratingRemainingPlayers(int count);

  /// No description provided for @ratingShowAll.
  ///
  /// In ru, this message translates to:
  /// **'Показать всех'**
  String get ratingShowAll;

  /// No description provided for @ratingMyPosition.
  ///
  /// In ru, this message translates to:
  /// **'Моя позиция'**
  String get ratingMyPosition;

  /// No description provided for @ratingLevelPoints.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} · {rating} очков'**
  String ratingLevelPoints(String level, String rating);

  /// No description provided for @ratingOutOfPlayers.
  ///
  /// In ru, this message translates to:
  /// **'из {count} игроков'**
  String ratingOutOfPlayers(int count);

  /// No description provided for @ratingFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get ratingFilterAll;

  /// No description provided for @profileUser.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get profileUser;

  /// No description provided for @profileLevelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String profileLevelLabel(String level);

  /// No description provided for @profileMissingCity.
  ///
  /// In ru, this message translates to:
  /// **'город'**
  String get profileMissingCity;

  /// No description provided for @profileMissingGender.
  ///
  /// In ru, this message translates to:
  /// **'пол'**
  String get profileMissingGender;

  /// No description provided for @profileMissingPhone.
  ///
  /// In ru, this message translates to:
  /// **'телефон'**
  String get profileMissingPhone;

  /// No description provided for @profileMissingFields.
  ///
  /// In ru, this message translates to:
  /// **'Укажите {fields} в настройках профиля'**
  String profileMissingFields(String fields);

  /// No description provided for @profileMissingAnd.
  ///
  /// In ru, this message translates to:
  /// **' и '**
  String get profileMissingAnd;

  /// No description provided for @profileBannerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заполните профиль'**
  String get profileBannerTitle;

  /// No description provided for @profileBannerDesc.
  ///
  /// In ru, this message translates to:
  /// **'Без этих данных нельзя записаться на турнир.'**
  String get profileBannerDesc;

  /// No description provided for @profileBannerMissing.
  ///
  /// In ru, this message translates to:
  /// **'Не заполнено: {fields}'**
  String profileBannerMissing(String fields);

  /// No description provided for @profileBannerCta.
  ///
  /// In ru, this message translates to:
  /// **'Дозаполнить'**
  String get profileBannerCta;

  /// No description provided for @profileBannerSeparator.
  ///
  /// In ru, this message translates to:
  /// **' · '**
  String get profileBannerSeparator;

  /// No description provided for @tournamentHistory.
  ///
  /// In ru, this message translates to:
  /// **'История турниров'**
  String get tournamentHistory;

  /// No description provided for @allButton.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allButton;

  /// No description provided for @noFinishedTournamentsYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет завершённых турниров'**
  String get noFinishedTournamentsYet;

  /// No description provided for @placeLabel.
  ///
  /// In ru, this message translates to:
  /// **'{place} место'**
  String placeLabel(int place);

  /// No description provided for @matchHistory.
  ///
  /// In ru, this message translates to:
  /// **'История матчей'**
  String get matchHistory;

  /// No description provided for @noMatchesYet.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет матчей'**
  String get noMatchesYet;

  /// No description provided for @loadMore.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить ещё'**
  String get loadMore;

  /// No description provided for @winResult.
  ///
  /// In ru, this message translates to:
  /// **'Победа'**
  String get winResult;

  /// No description provided for @lossResult.
  ///
  /// In ru, this message translates to:
  /// **'Поражение'**
  String get lossResult;

  /// No description provided for @achievements.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get achievements;

  /// No description provided for @achievementFirstWin.
  ///
  /// In ru, this message translates to:
  /// **'Первая\nпобеда'**
  String get achievementFirstWin;

  /// No description provided for @achievementFiveWins.
  ///
  /// In ru, this message translates to:
  /// **'5 побед\nподряд'**
  String get achievementFiveWins;

  /// No description provided for @achievementTopTen.
  ///
  /// In ru, this message translates to:
  /// **'Топ-10\nрейтинга'**
  String get achievementTopTen;

  /// No description provided for @achievementTenTournaments.
  ///
  /// In ru, this message translates to:
  /// **'10 турниров'**
  String get achievementTenTournaments;

  /// No description provided for @editProfile.
  ///
  /// In ru, this message translates to:
  /// **'Настройки профиля'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Имя, город, пол'**
  String get editProfileSubtitle;

  /// No description provided for @saveProfile.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get saveProfile;

  /// No description provided for @sectionName.
  ///
  /// In ru, this message translates to:
  /// **'ФИО'**
  String get sectionName;

  /// No description provided for @fieldName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get fieldName;

  /// No description provided for @notSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get notSpecified;

  /// No description provided for @sectionPhone.
  ///
  /// In ru, this message translates to:
  /// **'ТЕЛЕФОН'**
  String get sectionPhone;

  /// No description provided for @fieldPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get fieldPhone;

  /// No description provided for @phoneHintEdit.
  ///
  /// In ru, this message translates to:
  /// **'+7 (___) ___-__-__'**
  String get phoneHintEdit;

  /// No description provided for @phoneLockedHint.
  ///
  /// In ru, this message translates to:
  /// **'Телефон нельзя изменить'**
  String get phoneLockedHint;

  /// No description provided for @phoneInvalidFormat.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный номер'**
  String get phoneInvalidFormat;

  /// No description provided for @sectionLocation.
  ///
  /// In ru, this message translates to:
  /// **'МЕСТОПОЛОЖЕНИЕ'**
  String get sectionLocation;

  /// No description provided for @fieldCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get fieldCity;

  /// No description provided for @cityNotSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get cityNotSpecified;

  /// No description provided for @selectCity.
  ///
  /// In ru, this message translates to:
  /// **'Выберите город'**
  String get selectCity;

  /// No description provided for @sectionGender.
  ///
  /// In ru, this message translates to:
  /// **'ПОЛ'**
  String get sectionGender;

  /// No description provided for @genderMale.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get genderFemale;

  /// No description provided for @sectionAge.
  ///
  /// In ru, this message translates to:
  /// **'ВОЗРАСТ'**
  String get sectionAge;

  /// No description provided for @fieldAge.
  ///
  /// In ru, this message translates to:
  /// **'Лет'**
  String get fieldAge;

  /// No description provided for @ageNotSpecified.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get ageNotSpecified;

  /// No description provided for @sectionHand.
  ///
  /// In ru, this message translates to:
  /// **'ВЕДУЩАЯ РУКА'**
  String get sectionHand;

  /// No description provided for @handRight.
  ///
  /// In ru, this message translates to:
  /// **'Правша'**
  String get handRight;

  /// No description provided for @handLeft.
  ///
  /// In ru, this message translates to:
  /// **'Левша'**
  String get handLeft;

  /// No description provided for @sectionPosition.
  ///
  /// In ru, this message translates to:
  /// **'ПОЗИЦИЯ НА КОРТЕ'**
  String get sectionPosition;

  /// No description provided for @positionRight.
  ///
  /// In ru, this message translates to:
  /// **'Справа'**
  String get positionRight;

  /// No description provided for @positionLeft.
  ///
  /// In ru, this message translates to:
  /// **'Слева'**
  String get positionLeft;

  /// No description provided for @positionAny.
  ///
  /// In ru, this message translates to:
  /// **'Любая'**
  String get positionAny;

  /// No description provided for @photoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get photoCamera;

  /// No description provided for @photoGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get photoGallery;

  /// No description provided for @photoUploadError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки фото: {error}'**
  String photoUploadError(String error);

  /// No description provided for @saveError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сохранения: {error}'**
  String saveError(String error);

  /// No description provided for @logoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In ru, this message translates to:
  /// **'Это действие необратимо. Все ваши данные будут удалены.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль (если есть)'**
  String get deleteAccountPassword;

  /// No description provided for @deleteButton.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteButton;

  /// No description provided for @notificationSettingsMenu.
  ///
  /// In ru, this message translates to:
  /// **'Настройки уведомлений'**
  String get notificationSettingsMenu;

  /// No description provided for @dayMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get daySun;

  /// No description provided for @monthShortJan.
  ///
  /// In ru, this message translates to:
  /// **'янв'**
  String get monthShortJan;

  /// No description provided for @monthShortFeb.
  ///
  /// In ru, this message translates to:
  /// **'фев'**
  String get monthShortFeb;

  /// No description provided for @monthShortMar.
  ///
  /// In ru, this message translates to:
  /// **'мар'**
  String get monthShortMar;

  /// No description provided for @monthShortApr.
  ///
  /// In ru, this message translates to:
  /// **'апр'**
  String get monthShortApr;

  /// No description provided for @monthShortMay.
  ///
  /// In ru, this message translates to:
  /// **'май'**
  String get monthShortMay;

  /// No description provided for @monthShortJun.
  ///
  /// In ru, this message translates to:
  /// **'июн'**
  String get monthShortJun;

  /// No description provided for @monthShortJul.
  ///
  /// In ru, this message translates to:
  /// **'июл'**
  String get monthShortJul;

  /// No description provided for @monthShortAug.
  ///
  /// In ru, this message translates to:
  /// **'авг'**
  String get monthShortAug;

  /// No description provided for @monthShortSep.
  ///
  /// In ru, this message translates to:
  /// **'сен'**
  String get monthShortSep;

  /// No description provided for @monthShortOct.
  ///
  /// In ru, this message translates to:
  /// **'окт'**
  String get monthShortOct;

  /// No description provided for @monthShortNov.
  ///
  /// In ru, this message translates to:
  /// **'ноя'**
  String get monthShortNov;

  /// No description provided for @monthShortDec.
  ///
  /// In ru, this message translates to:
  /// **'дек'**
  String get monthShortDec;

  /// No description provided for @courtDefault.
  ///
  /// In ru, this message translates to:
  /// **'Корт {index}'**
  String courtDefault(int index);

  /// No description provided for @bookingError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка бронирования'**
  String get bookingError;

  /// No description provided for @summaryClub.
  ///
  /// In ru, this message translates to:
  /// **'Клуб'**
  String get summaryClub;

  /// No description provided for @summaryCourt.
  ///
  /// In ru, this message translates to:
  /// **'Корт'**
  String get summaryCourt;

  /// No description provided for @summaryDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get summaryDate;

  /// No description provided for @summaryStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get summaryStart;

  /// No description provided for @summaryTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get summaryTime;

  /// No description provided for @summaryCoach.
  ///
  /// In ru, this message translates to:
  /// **'Тренер'**
  String get summaryCoach;

  /// No description provided for @summaryTotal.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get summaryTotal;

  /// No description provided for @courtPriceBreakdown.
  ///
  /// In ru, this message translates to:
  /// **'Корт {courtPrice} + Тренер {coachPrice} ₸'**
  String courtPriceBreakdown(String courtPrice, String coachPrice);

  /// No description provided for @coachPlus.
  ///
  /// In ru, this message translates to:
  /// **'+ тренер {price} ₸'**
  String coachPlus(String price);

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить уведомления'**
  String get failedToLoadNotifications;

  /// No description provided for @noNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Нет уведомлений'**
  String get noNotifications;

  /// No description provided for @minutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин. назад'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} ч. назад'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн. назад'**
  String daysAgo(int count);

  /// No description provided for @failedToLoadSettings.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить настройки'**
  String get failedToLoadSettings;

  /// No description provided for @settingsSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сохранения настроек'**
  String get settingsSaveError;

  /// No description provided for @onlyMyLevelTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Только турниры моего уровня'**
  String get onlyMyLevelTournaments;

  /// No description provided for @onlyMyLevelTournamentsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Получать уведомления только о турнирах, подходящих по вашему уровню'**
  String get onlyMyLevelTournamentsDesc;

  /// No description provided for @notifyClubsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления от клубов'**
  String get notifyClubsTitle;

  /// No description provided for @notifyClubsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Выберите клубы, от которых хотите получать уведомления о новых турнирах'**
  String get notifyClubsDesc;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ru, this message translates to:
  /// **'Участвуйте\nв турнирах'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In ru, this message translates to:
  /// **'Находите турниры по падел-теннису\nрядом с вами и регистрируйтесь в\nодин клик'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ru, this message translates to:
  /// **'Следите за\nрейтингом'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In ru, this message translates to:
  /// **'Отслеживайте свой прогресс и\nсравнивайте результаты с другими\nигроками'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ru, this message translates to:
  /// **'Находите\nпартнёров'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In ru, this message translates to:
  /// **'Ищите игроков своего уровня для\nсовместных тренировок и турниров'**
  String get onboardingDesc3;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get getStarted;

  /// No description provided for @authAcceptHint.
  ///
  /// In ru, this message translates to:
  /// **'Для продолжения необходимо принять пользовательское соглашение и дать согласие на обработку персональных данных'**
  String get authAcceptHint;

  /// No description provided for @understood.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get understood;

  /// No description provided for @termsOfService.
  ///
  /// In ru, this message translates to:
  /// **'Пользовательское соглашение'**
  String get termsOfService;

  /// No description provided for @consentToProcessing.
  ///
  /// In ru, this message translates to:
  /// **'Согласие на обработку данных'**
  String get consentToProcessing;

  /// No description provided for @enterCode.
  ///
  /// In ru, this message translates to:
  /// **'Введите код'**
  String get enterCode;

  /// No description provided for @authCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get authCancel;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @enterPhoneForLogin.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона для входа'**
  String get enterPhoneForLogin;

  /// No description provided for @loginViaTelegramToContinue.
  ///
  /// In ru, this message translates to:
  /// **'Войдите через Telegram для продолжения'**
  String get loginViaTelegramToContinue;

  /// No description provided for @phoneNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneNumber;

  /// No description provided for @enterValidNumber.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный номер'**
  String get enterValidNumber;

  /// No description provided for @continueButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueButton;

  /// No description provided for @or.
  ///
  /// In ru, this message translates to:
  /// **'или'**
  String get or;

  /// No description provided for @loginViaTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Telegram'**
  String get loginViaTelegram;

  /// No description provided for @loginViaEmail.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Email или телефон'**
  String get loginViaEmail;

  /// No description provided for @consentToProcessPersonalData.
  ///
  /// In ru, this message translates to:
  /// **'Согласие на обработку персональных данных'**
  String get consentToProcessPersonalData;

  /// No description provided for @emailLoginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get emailLoginTitle;

  /// No description provided for @enterEmailAndPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите email или телефон и пароль'**
  String get enterEmailAndPassword;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? '**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerLink;

  /// No description provided for @enterEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный email'**
  String get enterValidEmail;

  /// No description provided for @emailOrPhone.
  ///
  /// In ru, this message translates to:
  /// **'Email или телефон'**
  String get emailOrPhone;

  /// No description provided for @enterEmailOrPhone.
  ///
  /// In ru, this message translates to:
  /// **'Введите email или телефон'**
  String get enterEmailOrPhone;

  /// No description provided for @enterValidEmailOrPhone.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный email или телефон'**
  String get enterValidEmailOrPhone;

  /// No description provided for @emailOrPhonePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'example@mail.com или +7 777 123 45 67'**
  String get emailOrPhonePlaceholder;

  /// No description provided for @registrationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registrationTitle;

  /// No description provided for @createAccountToContinue.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт для продолжения'**
  String get createAccountToContinue;

  /// No description provided for @fullName.
  ///
  /// In ru, this message translates to:
  /// **'ФИО'**
  String get fullName;

  /// No description provided for @fullNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Иванов Иван Иванович'**
  String get fullNamePlaceholder;

  /// No description provided for @enterFullName.
  ///
  /// In ru, this message translates to:
  /// **'Введите ФИО'**
  String get enterFullName;

  /// No description provided for @phoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phoneLabel;

  /// No description provided for @cityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get cityLabel;

  /// No description provided for @selectCityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите город'**
  String get selectCityTitle;

  /// No description provided for @minSixChars.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get minSixChars;

  /// No description provided for @enterPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get enterPasswordHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Пароль должен быть не менее 6 символов'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение пароля'**
  String get confirmPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get repeatPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPasswordHint;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsDontMatch;

  /// No description provided for @registerAction.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerAction;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signInLink;

  /// No description provided for @passwordRecovery.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление пароля'**
  String get passwordRecovery;

  /// No description provided for @enterEmailForResetLink.
  ///
  /// In ru, this message translates to:
  /// **'Введите email для получения ссылки\nна сброс пароля'**
  String get enterEmailForResetLink;

  /// No description provided for @linkSentToEmail.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка отправлена на email'**
  String get linkSentToEmail;

  /// No description provided for @backToLogin.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться к входу'**
  String get backToLogin;

  /// No description provided for @sendLink.
  ///
  /// In ru, this message translates to:
  /// **'Отправить ссылку'**
  String get sendLink;

  /// No description provided for @verificationCode.
  ///
  /// In ru, this message translates to:
  /// **'Код подтверждения'**
  String get verificationCode;

  /// No description provided for @codeSentTo.
  ///
  /// In ru, this message translates to:
  /// **'Код отправлен на {phone}'**
  String codeSentTo(String phone);

  /// No description provided for @resendCode.
  ///
  /// In ru, this message translates to:
  /// **'Отправить код повторно'**
  String get resendCode;

  /// No description provided for @confirmButton.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirmButton;

  /// No description provided for @confirmLogin.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите вход'**
  String get confirmLogin;

  /// No description provided for @pressStartInTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите Start в Telegram боте\nи вернитесь в приложение'**
  String get pressStartInTelegram;

  /// No description provided for @connectionFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться'**
  String get connectionFailed;

  /// No description provided for @tryAgain.
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get tryAgain;

  /// No description provided for @waitingForConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание подтверждения...'**
  String get waitingForConfirmation;

  /// No description provided for @openTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Открыть Telegram'**
  String get openTelegram;

  /// No description provided for @updateAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступно обновление'**
  String get updateAvailable;

  /// No description provided for @updateRequired.
  ///
  /// In ru, this message translates to:
  /// **'Для продолжения работы необходимо обновить приложение'**
  String get updateRequired;

  /// No description provided for @newVersionAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Вышла новая версия приложения с улучшениями'**
  String get newVersionAvailable;

  /// No description provided for @updateButton.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get updateButton;

  /// No description provided for @later.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get later;

  /// No description provided for @profileMissingPhoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите номер телефона'**
  String get profileMissingPhoneTitle;

  /// No description provided for @profileMissingPhoneDesc.
  ///
  /// In ru, this message translates to:
  /// **'Без него нельзя записаться на турниры и игры.'**
  String get profileMissingPhoneDesc;

  /// No description provided for @profileMissingCityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите город'**
  String get profileMissingCityTitle;

  /// No description provided for @profileMissingCityDesc.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы видеть актуальные турниры в вашем городе.'**
  String get profileMissingCityDesc;

  /// No description provided for @profileMissingGenderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Укажите пол'**
  String get profileMissingGenderTitle;

  /// No description provided for @profileMissingGenderDesc.
  ///
  /// In ru, this message translates to:
  /// **'Нужно для парных турниров и подбора партнёров.'**
  String get profileMissingGenderDesc;

  /// No description provided for @verificationNotConfirmedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг ещё не подтверждён'**
  String get verificationNotConfirmedTitle;

  /// No description provided for @verificationNoAvatarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Поставьте аватарку'**
  String get verificationNoAvatarTitle;

  /// No description provided for @verificationNoAvatarDesc.
  ///
  /// In ru, this message translates to:
  /// **'Зайдите в «Настройки профиля» и добавьте фото.'**
  String get verificationNoAvatarDesc;

  /// No description provided for @verificationNoTournamentsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сыграйте хотя бы один турнир'**
  String get verificationNoTournamentsTitle;

  /// No description provided for @verificationNoTournamentsDesc.
  ///
  /// In ru, this message translates to:
  /// **'После завершения первого турнира рейтинг подтвердится автоматически.'**
  String get verificationNoTournamentsDesc;

  /// No description provided for @verificationSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Верификация уровня'**
  String get verificationSheetTitle;

  /// No description provided for @verificationLatestEntry.
  ///
  /// In ru, this message translates to:
  /// **'ПОСЛЕДНЕЕ ПОДТВЕРЖДЕНИЕ'**
  String get verificationLatestEntry;

  /// No description provided for @verificationFieldLevel.
  ///
  /// In ru, this message translates to:
  /// **'Установленный уровень'**
  String get verificationFieldLevel;

  /// No description provided for @verificationFieldVerifiedBy.
  ///
  /// In ru, this message translates to:
  /// **'Кто подтвердил'**
  String get verificationFieldVerifiedBy;

  /// No description provided for @verificationFieldClub.
  ///
  /// In ru, this message translates to:
  /// **'Клуб'**
  String get verificationFieldClub;

  /// No description provided for @verificationFieldWhen.
  ///
  /// In ru, this message translates to:
  /// **'Когда'**
  String get verificationFieldWhen;

  /// No description provided for @verificationConfirmedByClub.
  ///
  /// In ru, this message translates to:
  /// **'Уровень подтверждён клубом.'**
  String get verificationConfirmedByClub;

  /// No description provided for @verificationToConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы рейтинг подтвердился:'**
  String get verificationToConfirm;

  /// No description provided for @verificationHistoryRecords.
  ///
  /// In ru, this message translates to:
  /// **'Записей в истории: {count}'**
  String verificationHistoryRecords(int count);

  /// No description provided for @verificationLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить: {error}'**
  String verificationLoadFailed(String error);

  /// No description provided for @verificationNotConfirmedYet.
  ///
  /// In ru, this message translates to:
  /// **'Уровень пока не подтверждён.'**
  String get verificationNotConfirmedYet;

  /// No description provided for @verificationNotChecked.
  ///
  /// In ru, this message translates to:
  /// **'Уровень этого игрока ещё не подтверждался клубом.'**
  String get verificationNotChecked;

  /// No description provided for @tournamentDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get tournamentDescription;

  /// No description provided for @showMore.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть'**
  String get showLess;

  /// No description provided for @registerViaChat.
  ///
  /// In ru, this message translates to:
  /// **'Записаться через чат'**
  String get registerViaChat;

  /// No description provided for @searchClubHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск клуба'**
  String get searchClubHint;

  /// No description provided for @searchCommunityHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск комьюнити'**
  String get searchCommunityHint;

  /// No description provided for @cityAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get cityAll;

  /// No description provided for @bannerClubsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Клубы'**
  String get bannerClubsTitle;

  /// No description provided for @bannerClubsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Адреса и контакты'**
  String get bannerClubsSubtitle;

  /// No description provided for @bannerCommunityTitle.
  ///
  /// In ru, this message translates to:
  /// **'Комьюнити'**
  String get bannerCommunityTitle;

  /// No description provided for @bannerCommunitySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сообщества игроков'**
  String get bannerCommunitySubtitle;

  /// No description provided for @bannerCreateTournamentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать турнир'**
  String get bannerCreateTournamentTitle;

  /// No description provided for @bannerCreateTournamentSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Организуй своё событие'**
  String get bannerCreateTournamentSubtitle;

  /// No description provided for @bannerBookCourtTitle.
  ///
  /// In ru, this message translates to:
  /// **'Забронировать корт'**
  String get bannerBookCourtTitle;

  /// No description provided for @bannerBookCourtSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите клуб и удобное время'**
  String get bannerBookCourtSubtitle;

  /// No description provided for @restartTournament.
  ///
  /// In ru, this message translates to:
  /// **'Перезапустить турнир'**
  String get restartTournament;

  /// No description provided for @startTournamentMenu.
  ///
  /// In ru, this message translates to:
  /// **'Запустить турнир'**
  String get startTournamentMenu;

  /// No description provided for @restartTournamentConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перезапустить турнир?'**
  String get restartTournamentConfirmTitle;

  /// No description provided for @restartTournamentConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Сетка и результаты будут удалены, участников можно будет изменить. Действие необратимо.'**
  String get restartTournamentConfirmMessage;

  /// No description provided for @restartTournamentConfirmOk.
  ///
  /// In ru, this message translates to:
  /// **'Перезапустить'**
  String get restartTournamentConfirmOk;

  /// No description provided for @restartTournamentSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Турнир перезапущен'**
  String get restartTournamentSuccess;

  /// No description provided for @editClubCard.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать карточку клуба'**
  String get editClubCard;

  /// No description provided for @editClubCardSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Название, контакты, описание'**
  String get editClubCardSubtitle;

  /// No description provided for @clubName.
  ///
  /// In ru, this message translates to:
  /// **'Название клуба'**
  String get clubName;

  /// No description provided for @clubAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get clubAddress;

  /// No description provided for @clubCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get clubCity;

  /// No description provided for @clubPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get clubPhone;

  /// No description provided for @clubEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get clubEmail;

  /// No description provided for @clubDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get clubDescription;

  /// No description provided for @clubPaymentUrl.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка для оплаты'**
  String get clubPaymentUrl;

  /// No description provided for @clubCardSaved.
  ///
  /// In ru, this message translates to:
  /// **'Карточка клуба сохранена'**
  String get clubCardSaved;

  /// No description provided for @clubTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Телеграм-канал'**
  String get clubTelegram;

  /// No description provided for @openTelegramChannel.
  ///
  /// In ru, this message translates to:
  /// **'Открыть телеграм-канал'**
  String get openTelegramChannel;

  /// No description provided for @clubInstagram.
  ///
  /// In ru, this message translates to:
  /// **'Инстаграм'**
  String get clubInstagram;

  /// No description provided for @openInstagram.
  ///
  /// In ru, this message translates to:
  /// **'Открыть инстаграм'**
  String get openInstagram;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
