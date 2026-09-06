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

  /// No description provided for @filterCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get filterCity;

  /// No description provided for @filterCityWithCount.
  ///
  /// In ru, this message translates to:
  /// **'Город · {count}'**
  String filterCityWithCount(int count);

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

  /// No description provided for @prizeTournament.
  ///
  /// In ru, this message translates to:
  /// **'Призовой'**
  String get prizeTournament;

  /// No description provided for @prizesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Призы'**
  String get prizesLabel;

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

  /// No description provided for @documentsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Документы'**
  String get documentsTitle;

  /// No description provided for @documentsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Юридические документы приложения'**
  String get documentsSubtitle;

  /// No description provided for @docTitleOffer.
  ///
  /// In ru, this message translates to:
  /// **'Договор оферты'**
  String get docTitleOffer;

  /// No description provided for @docTitlePrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get docTitlePrivacy;

  /// No description provided for @docTitleGoods.
  ///
  /// In ru, this message translates to:
  /// **'Описание товаров и услуг'**
  String get docTitleGoods;

  /// No description provided for @docTitleCard.
  ///
  /// In ru, this message translates to:
  /// **'Условия оплаты картой'**
  String get docTitleCard;

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

  /// No description provided for @paymentNotCompletedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оплата не завершена'**
  String get paymentNotCompletedTitle;

  /// No description provided for @paymentNotCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Вы не завершили оплату. Бронь сохранена как неоплаченная — оплатить можно позже в разделе «Мои брони» или на месте в клубе.'**
  String get paymentNotCompleted;

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

  /// No description provided for @statusNotConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'Не подтверждено'**
  String get statusNotConfirmed;

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

  /// No description provided for @themeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Светлая, тёмная или как в системе'**
  String get themeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системная'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

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

  /// No description provided for @liveShareText.
  ///
  /// In ru, this message translates to:
  /// **'Смотри трансляцию турнира'**
  String get liveShareText;

  /// No description provided for @shareFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть «Поделиться»'**
  String get shareFailed;

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

  /// No description provided for @tournamentUnrated.
  ///
  /// In ru, this message translates to:
  /// **'БЕЗ РЕЙТИНГА'**
  String get tournamentUnrated;

  /// No description provided for @tournamentVerifiedBadge.
  ///
  /// In ru, this message translates to:
  /// **'ВЕРИФ.'**
  String get tournamentVerifiedBadge;

  /// No description provided for @tournamentVerifiedOnly.
  ///
  /// In ru, this message translates to:
  /// **'Только для верифицированных'**
  String get tournamentVerifiedOnly;

  /// No description provided for @unratedBadge.
  ///
  /// In ru, this message translates to:
  /// **'Нерейтинговый'**
  String get unratedBadge;

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

  /// No description provided for @leaguesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лиги'**
  String get leaguesTitle;

  /// No description provided for @leaguesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Лиг пока нет'**
  String get leaguesEmpty;

  /// No description provided for @leaguesEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Когда клуб запустит лигу, она появится здесь'**
  String get leaguesEmptyHint;

  /// No description provided for @sectionTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Турниры'**
  String get sectionTournaments;

  /// No description provided for @payParticipation.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить участие'**
  String get payParticipation;

  /// No description provided for @payAmount.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить {amount}'**
  String payAmount(String amount);

  /// No description provided for @payForTwo.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить за двоих'**
  String get payForTwo;

  /// No description provided for @payMethodsHint.
  ///
  /// In ru, this message translates to:
  /// **'Картой онлайн · Apple Pay · Google Pay'**
  String get payMethodsHint;

  /// No description provided for @payAfterHint.
  ///
  /// In ru, this message translates to:
  /// **'После оплаты вы сразу в списке участников — без модерации'**
  String get payAfterHint;

  /// No description provided for @paySecureNote.
  ///
  /// In ru, this message translates to:
  /// **'Безопасная оплата, данные карты остаются у банка'**
  String get paySecureNote;

  /// No description provided for @payFailedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оплата не завершена'**
  String get payFailedTitle;

  /// No description provided for @payFailedBody.
  ///
  /// In ru, this message translates to:
  /// **'Вы не записаны — оплата не прошла. Место придержано 20 минут: можно оплатить ещё раз, потом оно освободится'**
  String get payFailedBody;

  /// No description provided for @payDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы в турнире'**
  String get payDoneTitle;

  /// No description provided for @payDoneBody.
  ///
  /// In ru, this message translates to:
  /// **'Оплата прошла, место в основном списке'**
  String get payDoneBody;

  /// No description provided for @payTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оплата участия'**
  String get payTitle;

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

  /// No description provided for @enterNameOrPhone.
  ///
  /// In ru, this message translates to:
  /// **'Имя или номер телефона'**
  String get enterNameOrPhone;

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

  /// No description provided for @notifyAllCities.
  ///
  /// In ru, this message translates to:
  /// **'Все города'**
  String get notifyAllCities;

  /// No description provided for @notifyAllClubs.
  ///
  /// In ru, this message translates to:
  /// **'Все клубы'**
  String get notifyAllClubs;

  /// No description provided for @notifyClubsChosen.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано {count} из {total}'**
  String notifyClubsChosen(int count, int total);

  /// No description provided for @notifyCitiesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Города'**
  String get notifyCitiesTitle;

  /// No description provided for @notifyCitiesDesc.
  ///
  /// In ru, this message translates to:
  /// **'Снимите город — и объявления о турнирах его клубов приходить не будут'**
  String get notifyCitiesDesc;

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
  /// **'Рейтинг подтвердится автоматически после турнира в клубе, который может подтверждать уровни.'**
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

  /// No description provided for @tournamentInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'О турнирах'**
  String get tournamentInfoTitle;

  /// No description provided for @tournamentInfoMenuSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Правила и форматы'**
  String get tournamentInfoMenuSubtitle;

  /// No description provided for @tournamentInfoHeader.
  ///
  /// In ru, this message translates to:
  /// **'Какие бывают форматы и как в них играют. Уровень и место в каждом считаются по-своему.'**
  String get tournamentInfoHeader;

  /// No description provided for @tournamentInfoAmericanoName.
  ///
  /// In ru, this message translates to:
  /// **'Американо'**
  String get tournamentInfoAmericanoName;

  /// No description provided for @tournamentInfoAmericanoBody.
  ///
  /// In ru, this message translates to:
  /// **'Самый популярный и дружелюбный формат. Подходит, когда собралась компания разного уровня и хочется поиграть со всеми, а не одной фиксированной парой.\n\nКак играется. Турнир идёт раундами. В каждом раунде участников разбивают на пары и ставят на корты 2×2. После раунда пары перемешиваются — следующую игру вы проводите с новым партнёром и против новых соперников.\n\nЗачёт — личный. Считаются набранные очки (геймы): сколько ваша пара набрала в раунде — столько идёт лично вам. Партнёр каждый раз новый, поэтому результат зависит в первую очередь от вашей игры.\n\nКто победил. Чемпион — тот, кто набрал больше всего очков за весь турнир. Таблица индивидуальная, каждый сам за себя.\n\nГруппы и плей-офф. На усмотрение организатора участников могут разбить на несколько групп — тогда зачёт идёт внутри своей группы. Также может быть добавлен плей-офф: после группового этапа лучшие разыгрывают призовые места в матчах на вылет.\n\nПример. 8 игроков, раунд до 21 очка. Раунд 1: вы с Денисом выиграли 21:14 → вам +21. Раунд 2: вы с Айгуль проиграли 16:21 → вам +16. В конце суммируем все очки — у кого больше, тот и первый.\n\nКому подходит. Смешанные компании, новички и опытные вместе, корпоративы, «поиграть со всеми и познакомиться».'**
  String get tournamentInfoAmericanoBody;

  /// No description provided for @tournamentInfoMexicanoName.
  ///
  /// In ru, this message translates to:
  /// **'Мексикано'**
  String get tournamentInfoMexicanoName;

  /// No description provided for @tournamentInfoMexicanoBody.
  ///
  /// In ru, this message translates to:
  /// **'«Умная» ротация: соперников и партнёра подбирает не жребий, а текущая таблица. После каждого раунда вы играете с теми, кто рядом с вами по очкам — поэтому матчи всё время равные и напряжённые.\n\nКак играется. Первый раунд — случайные пары 2×2. Дальше после каждого раунда игроки сортируются по очкам, делятся на четвёрки по местам, и внутри четвёрки пары составляются по схеме 1+4 против 2+3 (сильнейший со слабейшим против двух средних) — для максимального баланса. Партнёр меняется каждый раунд; система помнит, кто с кем уже играл, и старается не повторять.\n\nСостав. Игроков кратно 4 (минимум 8). Раунды генерирует организатор и завершает турнир в любой момент.\n\nЗачёт — личный, по очкам. Сумма набранных мячей во всех матчах. Таблица: 1) очки; 2) разница (забил − пропустил); 3) процент побед.\n\nЧем отличается от Американо. В Американо расклад по сути фиксированная ротация «каждый с каждым». В Мексикано пары на каждый раунд зависят от текущих мест — лидеры играют против лидеров, оторваться сложнее.\n\nКто победил. Первый — у кого больше всего очков в итоговой таблице.\n\nПример. После 2-го раунда вы 3-й по очкам — в следующем раунде попадёте в четвёрку с 1, 2 и 4 местами и сыграете 1+4 vs 2+3. Идёте ровно с равными — каждый матч решает.\n\nКому подходит. Кто хочет всегда равных соперников и интриги до конца: чем лучше идёте, тем сильнее оппоненты.'**
  String get tournamentInfoMexicanoBody;

  /// No description provided for @tournamentInfoRoundRobinName.
  ///
  /// In ru, this message translates to:
  /// **'Round Robin'**
  String get tournamentInfoRoundRobinName;

  /// No description provided for @tournamentInfoRoundRobinBody.
  ///
  /// In ru, this message translates to:
  /// **'Похож на Американо, но более «спортивный»: каждый играет с каждым по круговой системе, а в зачёте важны победы, а не сумма очков.\n\nКак играется. Раунды на кортах 2×2, партнёры каждый раунд меняются по круговой раскладке. За полный круг (для 8 игроков — 7 раундов) вы успеваете побыть в паре с каждым и сыграть против каждого. Игроков кратно 4, минимум 8.\n\nЧем отличается от Американо. Главное — зачёт. В Американо считают сумму набранных очков, а в Round Robin — число выигранных матчей. Важно именно выигрывать партии, а не «доколачивать» очки в проигранных.\n\nТаблица (как считается место). 1) число побед; 2) при равенстве — разница геймов (забил минус пропустил); 3) если снова равенство — личная встреча. Ничьих нет, играем до победы.\n\nКто победил. Первый — у кого больше всего побед за турнир (с учётом тай-брейков выше).\n\nПример. У вас 5 побед из 7 — вы выше тех, у кого 4. Если у двоих по 5 побед, выше тот, у кого лучше разница геймов; если равна и она — кто обыграл соперника в очной встрече.\n\nРаунды. Организатор генерирует следующий раунд по ходу и может завершить турнир в любой момент. Полный круг для 8 игроков — 7 раундов, дальше можно продолжать.\n\nКому подходит. Когда хочется честного «каждый с каждым», и чтобы итог отражал именно победы. Чуть длиннее и спортивнее Американо.'**
  String get tournamentInfoRoundRobinBody;

  /// No description provided for @tournamentInfoKingOfCourtName.
  ///
  /// In ru, this message translates to:
  /// **'Король корта'**
  String get tournamentInfoKingOfCourtName;

  /// No description provided for @tournamentInfoKingOfCourtBody.
  ///
  /// In ru, this message translates to:
  /// **'Динамичный формат с движением по кортам. Цель — подняться на корт №1 («королевский») и удержаться там против сильнейших.\n\nКак играется. Корты выстроены лестницей: корт 1 — верхний, последний — нижний. Каждый раунд на корте играют 2×2, после раунда: на верхнем корте победители остаются, проигравшие опускаются; на средних — победители поднимаются, проигравшие опускаются; на нижнем победители поднимаются, проигравшие остаются. Пары на корте каждый раунд перемешиваются — партнёр новый.\n\nСостав. Игроков кратно 4 (минимум 8). Кортов = игроков ÷ 4. Первый раунд раскидывается случайно. Раунды генерирует организатор и завершает турнир, когда захочет.\n\nЗачёт — личный. Очки — это набранные мячи во всех ваших матчах. Таблица: 1) сумма очков; 2) разница (забил − пропустил); 3) процент побед. Ничьих нет.\n\nКто победил. Чемпион — у кого больше всего очков за турнир. На корте 1 соперники сильнее, и набрать там «дороже».\n\nПарный вариант. Король корта можно проводить и с фиксированными парами — тогда по лестнице кортов двигается пара целиком: выиграли — поднимаетесь вдвоём, проиграли — опускаетесь вдвоём. Партнёр на весь турнир один, а зачёт ведётся по парам.\n\nПример. 8 игроков = 2 корта. Выиграли наверху — остаётесь против сильных. Проиграли внизу — остаётесь внизу. Постепенно сильнейшие собираются на корте 1.\n\nКому подходит. Любителям динамики и борьбы за вершину: каждый раунд новый расклад. Отличие от Американо — не просто ротация, а лестница кортов с борьбой за верхний.'**
  String get tournamentInfoKingOfCourtBody;

  /// No description provided for @tournamentInfoBaliKocName.
  ///
  /// In ru, this message translates to:
  /// **'Король Корта (Bali Format)'**
  String get tournamentInfoBaliKocName;

  /// No description provided for @tournamentInfoBaliKocBody.
  ///
  /// In ru, this message translates to:
  /// **'Версия Короля корта с фиксированными парами и начислением очков в зависимости от корта. Весь турнир вы играете с одним партнёром.\n\nКак играется. Пары распределяются по кортам-лестнице (корт 1 — верхний). Каждый раунд пара играет матч по геймам, после раунда пары двигаются: победители — выше, проигравшие — ниже. По лестнице двигается пара целиком, партнёр не меняется.\n\nОчки за матч (главная фишка). Очки получает только победитель матча, и их размер зависит от корта:\n— 1-й раунд: за победу 1 очко (стартовый расклад);\n— дальше: победа на корте K из N даёт (N + 2 − K) очков. То есть на верхнем корте победа «дороже всего», на нижнем — минимум.\nПоэтому выигрывать на королевском корте выгоднее, чем внизу.\n\nТаблица (по парам). Место: 1) очки; 2) личная встреча; 3) больше выигранных геймов; 4) разница геймов (6:0 выше, чем 6:2).\n\nСостав. Регистрация парами, пары фиксированы. Раунды генерирует организатор и завершает турнир, когда захочет.\n\nКто победил. Чемпион — пара с наибольшим числом очков. Мало просто побеждать — важно побеждать на верхних кортах.\n\nПример. 12 игроков = 6 пар = 3 корта (N=3). Победа на корте 1 = 3+2−1 = 4 очка, на корте 2 = 3, на корте 3 = 2. Пара, что доберётся до корта 1 и будет там выигрывать, быстро уйдёт в отрыв.\n\nКому подходит. Парам, которые хотят сыграть вместе весь турнир, и тем, кому нравится «весовая» система очков с борьбой за топовый корт.'**
  String get tournamentInfoBaliKocBody;

  /// No description provided for @tournamentInfoTeamName.
  ///
  /// In ru, this message translates to:
  /// **'Групповой + Плей-офф'**
  String get tournamentInfoTeamName;

  /// No description provided for @tournamentInfoTeamBody.
  ///
  /// In ru, this message translates to:
  /// **'Командный формат с фиксированными парами: вы регистрируетесь парой (или организатор собирает пары), и эта пара играет весь турнир вместе. Два этапа — групповой и плей-офф.\n\nКак играется.\n1) Групповой этап. Команды распределяются по группам «змейкой» по рейтингу (чтобы группы были примерно равными). Внутри группы — круговая система: каждая пара играет с каждой. За победу +1 очко, за поражение 0, ничьих нет.\n2) Плей-офф. Лучшие команды из групп выходят в сетку на вылет (полуфиналы → финал, при необходимости — матч за 3-е место). Проиграл — вылетел.\n\nТаблица группы. Место: 1) очки (победы); 2) разница геймов (забил − пропустил); 3) больше забитых геймов.\n\nСостав. Регистрация парами, партнёр на весь турнир один. Конфигурацию сетки задаёт организатор (число групп, нижняя сетка, матч за бронзу).\n\nКто победил. Чемпион — победитель финала плей-офф. Групповой этап определяет, кто и с какого места попадёт в сетку.\n\nПример. 8 пар → 2 группы по 4. В группе каждый с каждым (по 3 матча), две лучшие пары из каждой группы выходят в полуфиналы крест-накрест, победители — в финал.\n\nКому подходит. Тем, кто хочет играть постоянным напарником и любит классическую турнирную драму: сначала отбор в группе, потом плей-офф навылет.'**
  String get tournamentInfoTeamBody;

  /// No description provided for @tournamentInfoFlexName.
  ///
  /// In ru, this message translates to:
  /// **'Americano Flex'**
  String get tournamentInfoFlexName;

  /// No description provided for @tournamentInfoFlexBody.
  ///
  /// In ru, this message translates to:
  /// **'Гибкий Американо для любого числа игроков. Обычному Американо нужно строго кратно 4; здесь играть может почти любое число — лишние в раунде по очереди отдыхают.\n\nКак играется. Каждый раунд формируются матчи 2×2 с меняющимися партнёрами (как в Американо). Если игроков не хватает на ровные корты, часть садится отдыхать (bye). Отдых распределяется честно: первыми играют те, кто дольше отдыхал и меньше сыграл — со временем у всех примерно поровну матчей.\n\nЗачёт — личный, по среднему. Из-за отдыха число сыгранных матчей у всех разное, поэтому место считается по среднему количеству очков за матч (а не по сумме). Так никто не в плюсе и не в минусе из-за того, что сыграл больше или меньше.\n\nСостав. Подходит для «неудобного» числа участников, когда строгий Американо не собирается. Раунды генерирует организатор и завершает турнир в любой момент.\n\nПарный вариант. Флекс можно проводить и с фиксированными парами: тогда «атом» — пара, ротируются соперники и отдых, а партнёр на весь турнир один.\n\nКто победил. Первый — у кого лучший средний результат за матч.\n\nПример. 10 игроков, 2 корта = 8 играют, 2 отдыхают каждый раунд. Дальше отдыхают другие двое — и так по кругу. Если вы сыграли 6 матчей и набрали 36 очков (среднее 6), вы выше того, у кого 40 за 8 матчей (среднее 5).\n\nКому подходит. Когда собралось «некруглое» число игроков, но хочется честный Американо без простоев и с равными возможностями.'**
  String get tournamentInfoFlexBody;

  /// No description provided for @tournamentInfoEscaleraName.
  ///
  /// In ru, this message translates to:
  /// **'Ladder'**
  String get tournamentInfoEscaleraName;

  /// No description provided for @tournamentInfoEscaleraBody.
  ///
  /// In ru, this message translates to:
  /// **'Лестница из кортов: наверху сильнейшие, внизу те, кто пока проигрывает. Каждый раунд четвёрка на корте играет три коротких матча, после чего двое лучших поднимаются на корт выше, двое последних опускаются ниже.\n\nКак играется. Игроков ровно корты × 4. Стартовая расстановка — по рейтингу: четверо сильнейших на корт 1, следующие четверо на корт 2 и так далее. Внутри корта играются три матча, чтобы каждый побывал в паре с каждым: 1+4 против 2+3, затем 1+3 против 2+4, затем 1+2 против 3+4.\n\nПеремещения. По сумме очков за три матча четвёрка выстраивается по местам. Двое первых уходят на корт выше, двое последних — на корт ниже. С верхнего корта наверх уходить некуда, поэтому пара лидеров там остаётся; на нижнем так же остаются двое последних. Состав корта обновляется каждый раунд целиком.\n\nСчёт. Формат короткого матча организатор объявляет сам — счёт вводится любой, ничья допустима.\n\nТаблица. Зачёт выбирается при создании турнира. По очкам — сумма забитых за все короткие матчи. По баллам за позиции — родной зачёт формата: номер корта встроен в позицию, поэтому подниматься наверх выгоднее, чем набивать очки внизу. При равенстве выше тот, кто выиграл больше матчей, затем — личная встреча, затем — рейтинг на старте.\n\nРейтинг. Начисляется за каждый короткий матч по обычной формуле Elo, то есть за вечер набегает много матчей — рейтинг может заметно качнуться.\n\nКому подходит. Тем, кто хочет играть с равными по силе: лестница сама разводит игроков по уровню за пару раундов.'**
  String get tournamentInfoEscaleraBody;

  /// No description provided for @filterDateCustom.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать даты'**
  String get filterDateCustom;

  /// No description provided for @smsLoginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти по SMS'**
  String get smsLoginButton;

  /// No description provided for @phoneLoginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход по номеру'**
  String get phoneLoginTitle;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите номер телефона — отправим код подтверждения'**
  String get phoneLoginSubtitle;

  /// No description provided for @getCodeButton.
  ///
  /// In ru, this message translates to:
  /// **'Получить код'**
  String get getCodeButton;

  /// No description provided for @registrationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Заполните профиль, чтобы продолжить'**
  String get registrationSubtitle;

  /// No description provided for @fieldBirthDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get fieldBirthDate;

  /// No description provided for @selectBirthDate.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату'**
  String get selectBirthDate;

  /// No description provided for @registrationFillAll.
  ///
  /// In ru, this message translates to:
  /// **'Заполните все поля'**
  String get registrationFillAll;

  /// No description provided for @deleteAccountCodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите код из SMS, чтобы подтвердить удаление. Это действие необратимо.'**
  String get deleteAccountCodeHint;

  /// No description provided for @resendCodeIn.
  ///
  /// In ru, this message translates to:
  /// **'Отправить повторно через {seconds} сек'**
  String resendCodeIn(int seconds);

  /// No description provided for @changePhoneButton.
  ///
  /// In ru, this message translates to:
  /// **'Изменить номер'**
  String get changePhoneButton;

  /// No description provided for @changePhoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Смена номера'**
  String get changePhoneTitle;

  /// No description provided for @changePhoneOldHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите код, отправленный на текущий номер'**
  String get changePhoneOldHint;

  /// No description provided for @changePhoneEnterNew.
  ///
  /// In ru, this message translates to:
  /// **'Введите новый номер телефона'**
  String get changePhoneEnterNew;

  /// No description provided for @changePhoneNewHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите код, отправленный на новый номер'**
  String get changePhoneNewHint;

  /// No description provided for @changePhoneSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Номер изменён'**
  String get changePhoneSuccess;

  /// No description provided for @chatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чат турнира'**
  String get chatTitle;

  /// No description provided for @chatModeAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Только организатор'**
  String get chatModeAdmin;

  /// No description provided for @chatModeParticipants.
  ///
  /// In ru, this message translates to:
  /// **'Участники'**
  String get chatModeParticipants;

  /// No description provided for @chatModeEveryone.
  ///
  /// In ru, this message translates to:
  /// **'Открытый чат'**
  String get chatModeEveryone;

  /// No description provided for @chatInputHint.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение…'**
  String get chatInputHint;

  /// No description provided for @chatLockedOnlyAdmin.
  ///
  /// In ru, this message translates to:
  /// **'Писать может только организатор'**
  String get chatLockedOnlyAdmin;

  /// No description provided for @chatReadOnlyFinished.
  ///
  /// In ru, this message translates to:
  /// **'Чат завершён — только чтение'**
  String get chatReadOnlyFinished;

  /// No description provided for @chatEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сообщений пока нет'**
  String get chatEmpty;

  /// No description provided for @chatDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get chatDelete;

  /// No description provided for @chatOrganizerBadge.
  ///
  /// In ru, this message translates to:
  /// **'Организатор'**
  String get chatOrganizerBadge;

  /// No description provided for @chatSendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить сообщение'**
  String get chatSendFailed;

  /// No description provided for @chatRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get chatRetry;

  /// No description provided for @chatToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get chatYesterday;

  /// No description provided for @notifyBookingReminders.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать о брони'**
  String get notifyBookingReminders;

  /// No description provided for @notifyBookingRemindersDesc.
  ///
  /// In ru, this message translates to:
  /// **'Пуш за сутки, за 2 часа и за час до начала брони корта'**
  String get notifyBookingRemindersDesc;

  /// No description provided for @notifyOrganizerChat.
  ///
  /// In ru, this message translates to:
  /// **'Чат организатора'**
  String get notifyOrganizerChat;

  /// No description provided for @notifyOrganizerChatDesc.
  ///
  /// In ru, this message translates to:
  /// **'Пуш о новых сообщениях организатора в чате турнира'**
  String get notifyOrganizerChatDesc;

  /// No description provided for @sectionSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get sectionSettings;

  /// No description provided for @sectionInfo.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get sectionInfo;

  /// No description provided for @sectionAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get sectionAccount;

  /// No description provided for @coachTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тренер'**
  String get coachTitle;

  /// No description provided for @coachScheduleButton.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get coachScheduleButton;

  /// No description provided for @coachScheduleButtonSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваше расписание занятий'**
  String get coachScheduleButtonSubtitle;

  /// No description provided for @coachBusyToday.
  ///
  /// In ru, this message translates to:
  /// **'Занято сегодня'**
  String get coachBusyToday;

  /// No description provided for @coachSlotFree.
  ///
  /// In ru, this message translates to:
  /// **'Свободно'**
  String get coachSlotFree;

  /// No description provided for @coachSlotBooked.
  ///
  /// In ru, this message translates to:
  /// **'Занято'**
  String get coachSlotBooked;

  /// No description provided for @coachSlotBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировано'**
  String get coachSlotBlocked;

  /// No description provided for @coachDayOff.
  ///
  /// In ru, this message translates to:
  /// **'Рабочих часов на этот день нет'**
  String get coachDayOff;

  /// No description provided for @hoursShort.
  ///
  /// In ru, this message translates to:
  /// **'ч'**
  String get hoursShort;

  /// No description provided for @tournamentDurationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Длительность турнира'**
  String get tournamentDurationTitle;

  /// No description provided for @tournamentDurationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'У турнира не указана длительность. Выберите, на сколько добавить его в календарь.'**
  String get tournamentDurationSubtitle;

  /// No description provided for @aiAnalysisButton.
  ///
  /// In ru, this message translates to:
  /// **'Разбор AI'**
  String get aiAnalysisButton;

  /// No description provided for @aiAnalysisTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разбор турнира'**
  String get aiAnalysisTitle;

  /// No description provided for @aiAnalysisLoading.
  ///
  /// In ru, this message translates to:
  /// **'AI анализирует ваше выступление…'**
  String get aiAnalysisLoading;

  /// No description provided for @aiAnalysisErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить разбор'**
  String get aiAnalysisErrorTitle;

  /// No description provided for @aiAnalysisRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get aiAnalysisRetry;

  /// No description provided for @aiAnalysisFactorsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что повлияло на рейтинг'**
  String get aiAnalysisFactorsTitle;

  /// No description provided for @aiAnalysisBestMatch.
  ///
  /// In ru, this message translates to:
  /// **'Лучший матч'**
  String get aiAnalysisBestMatch;

  /// No description provided for @aiAnalysisWorstMatch.
  ///
  /// In ru, this message translates to:
  /// **'Слабый матч'**
  String get aiAnalysisWorstMatch;

  /// No description provided for @aiAnalysisTipsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Советы, как расти'**
  String get aiAnalysisTipsTitle;

  /// No description provided for @aiAnalysisFootnote.
  ///
  /// In ru, this message translates to:
  /// **'Разбор сгенерирован ИИ на основе ваших матчей'**
  String get aiAnalysisFootnote;

  /// No description provided for @aiMatchesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разбор по матчам'**
  String get aiMatchesTitle;

  /// No description provided for @aiYourPair.
  ///
  /// In ru, this message translates to:
  /// **'Ваша пара'**
  String get aiYourPair;

  /// No description provided for @aiOpponents.
  ///
  /// In ru, this message translates to:
  /// **'Соперники'**
  String get aiOpponents;

  /// No description provided for @aiWinChance.
  ///
  /// In ru, this message translates to:
  /// **'Шанс на победу'**
  String get aiWinChance;

  /// No description provided for @aiResultWin.
  ///
  /// In ru, this message translates to:
  /// **'Победа'**
  String get aiResultWin;

  /// No description provided for @aiResultLoss.
  ///
  /// In ru, this message translates to:
  /// **'Поражение'**
  String get aiResultLoss;

  /// No description provided for @aiMatchNoEffect.
  ///
  /// In ru, this message translates to:
  /// **'Матч не повлиял на рейтинг (0:0)'**
  String get aiMatchNoEffect;

  /// No description provided for @aiMatchWinStrong.
  ///
  /// In ru, this message translates to:
  /// **'Победа над более сильной парой — максимум очков'**
  String get aiMatchWinStrong;

  /// No description provided for @aiMatchWinExpected.
  ///
  /// In ru, this message translates to:
  /// **'Ожидаемая победа — прибавка небольшая'**
  String get aiMatchWinExpected;

  /// No description provided for @aiMatchLossFavorite.
  ///
  /// In ru, this message translates to:
  /// **'Проигрыш фавориту — потеря небольшая'**
  String get aiMatchLossFavorite;

  /// No description provided for @aiMatchLossWeak.
  ///
  /// In ru, this message translates to:
  /// **'Проигрыш более слабой паре — потеря больше'**
  String get aiMatchLossWeak;

  /// No description provided for @servicesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сервисы'**
  String get servicesTitle;

  /// No description provided for @serviceBooking.
  ///
  /// In ru, this message translates to:
  /// **'Бронирование'**
  String get serviceBooking;

  /// No description provided for @serviceClubs.
  ///
  /// In ru, this message translates to:
  /// **'Клубы'**
  String get serviceClubs;

  /// No description provided for @serviceCommunity.
  ///
  /// In ru, this message translates to:
  /// **'Комьюнити'**
  String get serviceCommunity;

  /// No description provided for @serviceShop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get serviceShop;

  /// No description provided for @serviceCreateGame.
  ///
  /// In ru, this message translates to:
  /// **'Создать игру'**
  String get serviceCreateGame;

  /// No description provided for @serviceGames.
  ///
  /// In ru, this message translates to:
  /// **'Игры'**
  String get serviceGames;

  /// No description provided for @serviceClubCards.
  ///
  /// In ru, this message translates to:
  /// **'Клубные карты'**
  String get serviceClubCards;

  /// No description provided for @serviceTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Турниры'**
  String get serviceTournaments;

  /// No description provided for @serviceCertificates.
  ///
  /// In ru, this message translates to:
  /// **'Сертификаты'**
  String get serviceCertificates;

  /// No description provided for @serviceComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Раздел в разработке'**
  String get serviceComingSoon;

  /// No description provided for @certificatesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои сертификаты'**
  String get certificatesTitle;

  /// No description provided for @certActive.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get certActive;

  /// No description provided for @certUsed.
  ///
  /// In ru, this message translates to:
  /// **'Использованные'**
  String get certUsed;

  /// No description provided for @certStatusActive.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get certStatusActive;

  /// No description provided for @certStatusUsed.
  ///
  /// In ru, this message translates to:
  /// **'Использован'**
  String get certStatusUsed;

  /// No description provided for @certDetailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сертификат'**
  String get certDetailTitle;

  /// No description provided for @certOwner.
  ///
  /// In ru, this message translates to:
  /// **'Владелец'**
  String get certOwner;

  /// No description provided for @certBearer.
  ///
  /// In ru, this message translates to:
  /// **'Предъявителю'**
  String get certBearer;

  /// No description provided for @certShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get certShare;

  /// No description provided for @certIssued.
  ///
  /// In ru, this message translates to:
  /// **'Выдан'**
  String get certIssued;

  /// No description provided for @certRedeemed.
  ///
  /// In ru, this message translates to:
  /// **'Использован'**
  String get certRedeemed;

  /// No description provided for @certStamp.
  ///
  /// In ru, this message translates to:
  /// **'ПОГАШЕН'**
  String get certStamp;

  /// No description provided for @certActiveUsable.
  ///
  /// In ru, this message translates to:
  /// **'Активен — можно использовать'**
  String get certActiveUsable;

  /// No description provided for @certActiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Покажите номер администратору клуба при бронировании — он спишет сертификат.'**
  String get certActiveHint;

  /// No description provided for @certUsedHint.
  ///
  /// In ru, this message translates to:
  /// **'Сертификат уже погашен и недоступен для использования.'**
  String get certUsedHint;

  /// No description provided for @certEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сертификатов'**
  String get certEmptyTitle;

  /// No description provided for @certEmptyText.
  ///
  /// In ru, this message translates to:
  /// **'Когда клуб выдаст сертификат на ваш номер телефона — он появится здесь.'**
  String get certEmptyText;

  /// No description provided for @clubCardsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Клубные карты'**
  String get clubCardsTitle;

  /// No description provided for @clubCardsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет клубных карт'**
  String get clubCardsEmptyTitle;

  /// No description provided for @clubCardsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Карта появится здесь автоматически, если клуб оформил её на ваш номер'**
  String get clubCardsEmptyHint;

  /// No description provided for @clubCardsActive.
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get clubCardsActive;

  /// No description provided for @clubCardsArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get clubCardsArchive;

  /// No description provided for @clubCardsNoActive.
  ///
  /// In ru, this message translates to:
  /// **'Нет активных карт'**
  String get clubCardsNoActive;

  /// No description provided for @clubCardsArchiveEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В архиве пусто'**
  String get clubCardsArchiveEmpty;

  /// No description provided for @clubCardActiveTotal.
  ///
  /// In ru, this message translates to:
  /// **'{active} активные · {total} всего'**
  String clubCardActiveTotal(int active, int total);

  /// No description provided for @clubCardRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось {balance} из {initial}'**
  String clubCardRemaining(int balance, int initial);

  /// No description provided for @clubCardBalanceAfter.
  ///
  /// In ru, this message translates to:
  /// **'остаток {balance}'**
  String clubCardBalanceAfter(int balance);

  /// No description provided for @clubCardUnlimited.
  ///
  /// In ru, this message translates to:
  /// **'Бессрочная'**
  String get clubCardUnlimited;

  /// No description provided for @clubCardExpired.
  ///
  /// In ru, this message translates to:
  /// **'Истекла'**
  String get clubCardExpired;

  /// No description provided for @clubCardValidUntilShort.
  ///
  /// In ru, this message translates to:
  /// **'до'**
  String get clubCardValidUntilShort;

  /// No description provided for @clubCardKindVisits.
  ///
  /// In ru, this message translates to:
  /// **'Занятия'**
  String get clubCardKindVisits;

  /// No description provided for @clubCardKindTrainer.
  ///
  /// In ru, this message translates to:
  /// **'Тренер'**
  String get clubCardKindTrainer;

  /// No description provided for @clubCardKindDiscountCourt.
  ///
  /// In ru, this message translates to:
  /// **'Скидка на корт'**
  String get clubCardKindDiscountCourt;

  /// No description provided for @clubCardKindDiscountTrainer.
  ///
  /// In ru, this message translates to:
  /// **'Скидка на тренера'**
  String get clubCardKindDiscountTrainer;

  /// No description provided for @clubCardCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код карты'**
  String get clubCardCodeLabel;

  /// No description provided for @clubCardValidUntilLabel.
  ///
  /// In ru, this message translates to:
  /// **'Действует до'**
  String get clubCardValidUntilLabel;

  /// No description provided for @clubCardBenefitsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что даёт карта'**
  String get clubCardBenefitsTitle;

  /// No description provided for @clubCardHistoryTitle.
  ///
  /// In ru, this message translates to:
  /// **'История операций'**
  String get clubCardHistoryTitle;

  /// No description provided for @clubCardHistoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет операций'**
  String get clubCardHistoryEmpty;

  /// No description provided for @clubCardCharge.
  ///
  /// In ru, this message translates to:
  /// **'Списание'**
  String get clubCardCharge;

  /// No description provided for @clubCardChargeBooking.
  ///
  /// In ru, this message translates to:
  /// **'Списание за бронь'**
  String get clubCardChargeBooking;

  /// No description provided for @clubCardBookingsButton.
  ///
  /// In ru, this message translates to:
  /// **'Записи по карте'**
  String get clubCardBookingsButton;

  /// No description provided for @clubCardBookingsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет предстоящих записей по этой карте'**
  String get clubCardBookingsEmpty;

  /// No description provided for @clubCardBookingCancelHint.
  ///
  /// In ru, this message translates to:
  /// **'Отмена не позднее чем за {hours} ч до начала'**
  String clubCardBookingCancelHint(int hours);

  /// No description provided for @clubCardsCountShort.
  ///
  /// In ru, this message translates to:
  /// **'{count} {count, plural, one{карта} few{карты} many{карт} other{карты}}'**
  String clubCardsCountShort(int count);

  /// No description provided for @minutesShort.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get minutesShort;

  /// No description provided for @bookingToday.
  ///
  /// In ru, this message translates to:
  /// **'сегодня'**
  String get bookingToday;

  /// No description provided for @bookingTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'завтра'**
  String get bookingTomorrow;

  /// No description provided for @bookingInDays.
  ///
  /// In ru, this message translates to:
  /// **'через {days} {days, plural, one{день} few{дня} many{дней} other{дня}}'**
  String bookingInDays(int days);

  /// No description provided for @gameDetailTitle.
  ///
  /// In ru, this message translates to:
  /// **'Детали игры'**
  String get gameDetailTitle;

  /// No description provided for @gameCreateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать игру'**
  String get gameCreateTitle;

  /// No description provided for @gameSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get gameSoon;

  /// No description provided for @gameTitleFallback.
  ///
  /// In ru, this message translates to:
  /// **'Игра'**
  String get gameTitleFallback;

  /// No description provided for @gameTypeRated.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинговая'**
  String get gameTypeRated;

  /// No description provided for @gameTypeFriendly.
  ///
  /// In ru, this message translates to:
  /// **'Товарищеская'**
  String get gameTypeFriendly;

  /// No description provided for @gameFormatSets.
  ///
  /// In ru, this message translates to:
  /// **'По сетам'**
  String get gameFormatSets;

  /// No description provided for @gameFormatPoints.
  ///
  /// In ru, this message translates to:
  /// **'До очков'**
  String get gameFormatPoints;

  /// No description provided for @gameFormatAmericano.
  ///
  /// In ru, this message translates to:
  /// **'Американо'**
  String get gameFormatAmericano;

  /// No description provided for @gameJoinSlot.
  ///
  /// In ru, this message translates to:
  /// **'Занять место'**
  String get gameJoinSlot;

  /// No description provided for @gameDetails.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get gameDetails;

  /// No description provided for @gameScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Игры'**
  String get gameScreenTitle;

  /// No description provided for @gameOpenTab.
  ///
  /// In ru, this message translates to:
  /// **'Открытые'**
  String get gameOpenTab;

  /// No description provided for @gameMyTab.
  ///
  /// In ru, this message translates to:
  /// **'Мои'**
  String get gameMyTab;

  /// No description provided for @gameEmptyOpen.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет открытых игр'**
  String get gameEmptyOpen;

  /// No description provided for @gameEmptyMy.
  ///
  /// In ru, this message translates to:
  /// **'У вас пока нет игр'**
  String get gameEmptyMy;

  /// No description provided for @gameCreateSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get gameCreateSubmit;

  /// No description provided for @gameFieldClub.
  ///
  /// In ru, this message translates to:
  /// **'Клуб'**
  String get gameFieldClub;

  /// No description provided for @gameFieldDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get gameFieldDate;

  /// No description provided for @gameFieldTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get gameFieldTime;

  /// No description provided for @gameFieldDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get gameFieldDuration;

  /// No description provided for @gameFieldType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get gameFieldType;

  /// No description provided for @gameFieldVisibility.
  ///
  /// In ru, this message translates to:
  /// **'Видимость'**
  String get gameFieldVisibility;

  /// No description provided for @gameVisibilityPublic.
  ///
  /// In ru, this message translates to:
  /// **'Открытая'**
  String get gameVisibilityPublic;

  /// No description provided for @gameVisibilityPrivate.
  ///
  /// In ru, this message translates to:
  /// **'Приватная'**
  String get gameVisibilityPrivate;

  /// No description provided for @gameFieldFormat.
  ///
  /// In ru, this message translates to:
  /// **'Формат'**
  String get gameFieldFormat;

  /// No description provided for @gameFieldTiebreak.
  ///
  /// In ru, this message translates to:
  /// **'Тай-брейк'**
  String get gameFieldTiebreak;

  /// No description provided for @gamePointsMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим очков'**
  String get gamePointsMode;

  /// No description provided for @gamePointsFirstTo.
  ///
  /// In ru, this message translates to:
  /// **'До N очков'**
  String get gamePointsFirstTo;

  /// No description provided for @gamePointsTotal.
  ///
  /// In ru, this message translates to:
  /// **'На сумму'**
  String get gamePointsTotal;

  /// No description provided for @gamePointsTarget.
  ///
  /// In ru, this message translates to:
  /// **'Очков до победы'**
  String get gamePointsTarget;

  /// No description provided for @gamePointsCap.
  ///
  /// In ru, this message translates to:
  /// **'Лимит очков'**
  String get gamePointsCap;

  /// No description provided for @gameAmSub.
  ///
  /// In ru, this message translates to:
  /// **'Подформат'**
  String get gameAmSub;

  /// No description provided for @gameAmBySets.
  ///
  /// In ru, this message translates to:
  /// **'По сетам'**
  String get gameAmBySets;

  /// No description provided for @gameAmByTiebreak.
  ///
  /// In ru, this message translates to:
  /// **'По тай-брейку'**
  String get gameAmByTiebreak;

  /// No description provided for @gameAmByPoints.
  ///
  /// In ru, this message translates to:
  /// **'По очкам'**
  String get gameAmByPoints;

  /// No description provided for @gameAmTarget.
  ///
  /// In ru, this message translates to:
  /// **'Значение'**
  String get gameAmTarget;

  /// No description provided for @gameFieldRatingRange.
  ///
  /// In ru, this message translates to:
  /// **'Диапазон уровня'**
  String get gameFieldRatingRange;

  /// No description provided for @gameRatingAny.
  ///
  /// In ru, this message translates to:
  /// **'Любой'**
  String get gameRatingAny;

  /// No description provided for @gameFieldPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена, ₸'**
  String get gameFieldPrice;

  /// No description provided for @gameFieldDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get gameFieldDescription;

  /// No description provided for @gameCreateValidationError.
  ///
  /// In ru, this message translates to:
  /// **'Заполните обязательные поля'**
  String get gameCreateValidationError;

  /// No description provided for @gameDurationMin.
  ///
  /// In ru, this message translates to:
  /// **'{min} мин'**
  String gameDurationMin(int min);

  /// No description provided for @gameStatusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get gameStatusLabel;

  /// No description provided for @gamePlayersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Участники'**
  String get gamePlayersTitle;

  /// No description provided for @gameSlotFree.
  ///
  /// In ru, this message translates to:
  /// **'Свободно'**
  String get gameSlotFree;

  /// No description provided for @gamePlayerYou.
  ///
  /// In ru, this message translates to:
  /// **'вы'**
  String get gamePlayerYou;

  /// No description provided for @gameStatusAccepted.
  ///
  /// In ru, this message translates to:
  /// **'В составе'**
  String get gameStatusAccepted;

  /// No description provided for @gameStatusCandidate.
  ///
  /// In ru, this message translates to:
  /// **'В очереди'**
  String get gameStatusCandidate;

  /// No description provided for @gameStatusInvited.
  ///
  /// In ru, this message translates to:
  /// **'Приглашён'**
  String get gameStatusInvited;

  /// No description provided for @gameShareTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка-приглашение'**
  String get gameShareTitle;

  /// No description provided for @gameShareActive.
  ///
  /// In ru, this message translates to:
  /// **'активна'**
  String get gameShareActive;

  /// No description provided for @gameShareInactive.
  ///
  /// In ru, this message translates to:
  /// **'неактивна'**
  String get gameShareInactive;

  /// No description provided for @gamePriceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get gamePriceLabel;

  /// No description provided for @gameOrganizerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Организатор'**
  String get gameOrganizerLabel;

  /// No description provided for @gameActionAccept.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get gameActionAccept;

  /// No description provided for @gameActionDecline.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить'**
  String get gameActionDecline;

  /// No description provided for @gameActionApply.
  ///
  /// In ru, this message translates to:
  /// **'Присоединиться'**
  String get gameActionApply;

  /// No description provided for @gameActionJoinQueue.
  ///
  /// In ru, this message translates to:
  /// **'Встать в очередь'**
  String get gameActionJoinQueue;

  /// No description provided for @gameApplied.
  ///
  /// In ru, this message translates to:
  /// **'Вы в очереди'**
  String get gameApplied;

  /// No description provided for @gameActionLeave.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get gameActionLeave;

  /// No description provided for @gameActionStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать игру'**
  String get gameActionStart;

  /// No description provided for @gameActionStartCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить старт'**
  String get gameActionStartCancel;

  /// No description provided for @gameActionInvite.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить'**
  String get gameActionInvite;

  /// No description provided for @gameActionApprove.
  ///
  /// In ru, this message translates to:
  /// **'Одобрить'**
  String get gameActionApprove;

  /// No description provided for @gameActionReject.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить'**
  String get gameActionReject;

  /// No description provided for @gameActionRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get gameActionRemove;

  /// No description provided for @gameShareRotate.
  ///
  /// In ru, this message translates to:
  /// **'Обновить ссылку'**
  String get gameShareRotate;

  /// No description provided for @gameShareRevoke.
  ///
  /// In ru, this message translates to:
  /// **'Отозвать'**
  String get gameShareRevoke;

  /// No description provided for @gameShareCopied.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка скопирована'**
  String get gameShareCopied;

  /// No description provided for @gameInviteSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Телефон игрока'**
  String get gameInviteSearchHint;

  /// No description provided for @gameInviteSearchBtn.
  ///
  /// In ru, this message translates to:
  /// **'Найти'**
  String get gameInviteSearchBtn;

  /// No description provided for @gameInviteEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Никого не найдено'**
  String get gameInviteEmpty;

  /// No description provided for @gameLeaveConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из игры?'**
  String get gameLeaveConfirm;

  /// No description provided for @gameRoundsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Счёт по раундам'**
  String get gameRoundsTitle;

  /// No description provided for @gameRoundNo.
  ///
  /// In ru, this message translates to:
  /// **'Раунд {n}'**
  String gameRoundNo(int n);

  /// No description provided for @gameTeamA.
  ///
  /// In ru, this message translates to:
  /// **'Команда A'**
  String get gameTeamA;

  /// No description provided for @gameTeamB.
  ///
  /// In ru, this message translates to:
  /// **'Команда B'**
  String get gameTeamB;

  /// No description provided for @gameAddRound.
  ///
  /// In ru, this message translates to:
  /// **'Добавить раунд'**
  String get gameAddRound;

  /// No description provided for @gameRegenerate.
  ///
  /// In ru, this message translates to:
  /// **'Перегенерировать'**
  String get gameRegenerate;

  /// No description provided for @gameRoundSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get gameRoundSave;

  /// No description provided for @gameRoundScoreA.
  ///
  /// In ru, this message translates to:
  /// **'Счёт A'**
  String get gameRoundScoreA;

  /// No description provided for @gameRoundScoreB.
  ///
  /// In ru, this message translates to:
  /// **'Счёт B'**
  String get gameRoundScoreB;

  /// No description provided for @gamePickTeamA.
  ///
  /// In ru, this message translates to:
  /// **'Выберите команду A (2 игрока)'**
  String get gamePickTeamA;

  /// No description provided for @gameRoundDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить раунд?'**
  String get gameRoundDeleteConfirm;

  /// No description provided for @gameActionFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить'**
  String get gameActionFinish;

  /// No description provided for @gameFinishConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Завершить игру и зафиксировать счёт?'**
  String get gameFinishConfirm;

  /// No description provided for @gameConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение счёта'**
  String get gameConfirmTitle;

  /// No description provided for @gameConfirmBtn.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждаю счёт'**
  String get gameConfirmBtn;

  /// No description provided for @gameConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'подтвердил'**
  String get gameConfirmed;

  /// No description provided for @gameNotConfirmed.
  ///
  /// In ru, this message translates to:
  /// **'ожидает'**
  String get gameNotConfirmed;

  /// No description provided for @gameResultTitle.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get gameResultTitle;

  /// No description provided for @gameRankingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ранжирование'**
  String get gameRankingTitle;

  /// No description provided for @gameRankPlace.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get gameRankPlace;

  /// No description provided for @gameRankPoints.
  ///
  /// In ru, this message translates to:
  /// **'Очки'**
  String get gameRankPoints;

  /// No description provided for @gameRankWins.
  ///
  /// In ru, this message translates to:
  /// **'Победы'**
  String get gameRankWins;

  /// No description provided for @gameRatingChange.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get gameRatingChange;

  /// No description provided for @gameResultPlace.
  ///
  /// In ru, this message translates to:
  /// **'{place} место'**
  String gameResultPlace(int place);

  /// No description provided for @gameInvitationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приглашения'**
  String get gameInvitationsTitle;

  /// No description provided for @gameInvitationsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет приглашений'**
  String get gameInvitationsEmpty;

  /// No description provided for @gameInvitedBy.
  ///
  /// In ru, this message translates to:
  /// **'Пригласил: {name}'**
  String gameInvitedBy(String name);

  /// No description provided for @amigos.
  ///
  /// In ru, this message translates to:
  /// **'Амигос'**
  String get amigos;

  /// No description provided for @amigosMine.
  ///
  /// In ru, this message translates to:
  /// **'Мои'**
  String get amigosMine;

  /// No description provided for @amigosFollowers.
  ///
  /// In ru, this message translates to:
  /// **'Меня добавили'**
  String get amigosFollowers;

  /// No description provided for @amigosFeed.
  ///
  /// In ru, this message translates to:
  /// **'Лента'**
  String get amigosFeed;

  /// No description provided for @amigosMyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои амигос'**
  String get amigosMyTitle;

  /// No description provided for @amigosPlayingNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас играют'**
  String get amigosPlayingNow;

  /// No description provided for @amigosAdd.
  ///
  /// In ru, this message translates to:
  /// **'В амигос'**
  String get amigosAdd;

  /// No description provided for @amigosAdded.
  ///
  /// In ru, this message translates to:
  /// **'В амигос ✓'**
  String get amigosAdded;

  /// No description provided for @amigosAddBack.
  ///
  /// In ru, this message translates to:
  /// **'В ответ'**
  String get amigosAddBack;

  /// No description provided for @amigosRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из амигос'**
  String get amigosRemove;

  /// No description provided for @amigosRemoveConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Убрать {name} из амигос?'**
  String amigosRemoveConfirm(String name);

  /// No description provided for @amigosMutual.
  ///
  /// In ru, this message translates to:
  /// **'взаимно'**
  String get amigosMutual;

  /// No description provided for @amigosEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока никого.\nНачните с тех, с кем уже играли.'**
  String get amigosEmpty;

  /// No description provided for @amigosEmptyFollowers.
  ///
  /// In ru, this message translates to:
  /// **'Вас пока никто не добавил.'**
  String get amigosEmptyFollowers;

  /// No description provided for @amigosEmptyFeed.
  ///
  /// In ru, this message translates to:
  /// **'Пока тихо. Здесь будет видно, кто играет и кто собирается.'**
  String get amigosEmptyFeed;

  /// No description provided for @amigosCandidatesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы часто играете вместе'**
  String get amigosCandidatesTitle;

  /// No description provided for @amigosGamesTogether.
  ///
  /// In ru, this message translates to:
  /// **'{count} матчей вместе'**
  String amigosGamesTogether(int count);

  /// No description provided for @amigosSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по своим'**
  String get amigosSearchHint;

  /// No description provided for @amigoPlaying.
  ///
  /// In ru, this message translates to:
  /// **'играет'**
  String get amigoPlaying;

  /// No description provided for @amigoLooking.
  ///
  /// In ru, this message translates to:
  /// **'ищет игроков'**
  String get amigoLooking;

  /// No description provided for @amigoTournament.
  ///
  /// In ru, this message translates to:
  /// **'турнир'**
  String get amigoTournament;

  /// No description provided for @amigoPlayed.
  ///
  /// In ru, this message translates to:
  /// **'сыграл турнир'**
  String get amigoPlayed;

  /// No description provided for @amigoWatch.
  ///
  /// In ru, this message translates to:
  /// **'смотреть'**
  String get amigoWatch;

  /// No description provided for @amigosProfileEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте тех, с кем играете'**
  String get amigosProfileEmpty;

  /// No description provided for @messages.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get messages;

  /// No description provided for @messagesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Здесь будут переписки.\nНапишите тому, с кем играете — кнопка «Написать» есть в профиле игрока.'**
  String get messagesEmpty;

  /// No description provided for @messageWrite.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
  String get messageWrite;

  /// No description provided for @messageHint.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение…'**
  String get messageHint;

  /// No description provided for @messageYouPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Вы: '**
  String get messageYouPrefix;

  /// No description provided for @messageRules.
  ///
  /// In ru, this message translates to:
  /// **'Пишите по делу. На спам можно пожаловаться.'**
  String get messageRules;

  /// No description provided for @messageToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get messageToday;

  /// No description provided for @messageYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get messageYesterday;

  /// No description provided for @messageDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить сообщение?'**
  String get messageDeleteConfirm;

  /// No description provided for @messageBlockedByMe.
  ///
  /// In ru, this message translates to:
  /// **'Вы заблокировали игрока'**
  String get messageBlockedByMe;

  /// No description provided for @messageBlockedMe.
  ///
  /// In ru, this message translates to:
  /// **'Игрок ограничил переписку'**
  String get messageBlockedMe;

  /// No description provided for @blockUser.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать игрока'**
  String get blockUser;

  /// No description provided for @blockUserConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать {name}?'**
  String blockUserConfirm(String name);

  /// No description provided for @blockUserExplain.
  ///
  /// In ru, this message translates to:
  /// **'Он не сможет писать вам и видеть вашу активность. Вы исчезнете из его амигос, он — из ваших.'**
  String get blockUserExplain;

  /// No description provided for @blockAction.
  ///
  /// In ru, this message translates to:
  /// **'Заблокировать'**
  String get blockAction;

  /// No description provided for @unblockAction.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать'**
  String get unblockAction;

  /// No description provided for @blockedList.
  ///
  /// In ru, this message translates to:
  /// **'Заблокированные'**
  String get blockedList;

  /// No description provided for @blockedEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Никого не блокировали.'**
  String get blockedEmpty;

  /// No description provided for @blockedAt.
  ///
  /// In ru, this message translates to:
  /// **'заблокирован {date}'**
  String blockedAt(String date);

  /// No description provided for @reportUser.
  ///
  /// In ru, this message translates to:
  /// **'Пожаловаться'**
  String get reportUser;

  /// No description provided for @reportSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы посмотрим переписку и ответим в поддержке'**
  String get reportSubtitle;

  /// No description provided for @reportSpam.
  ///
  /// In ru, this message translates to:
  /// **'Спам и реклама'**
  String get reportSpam;

  /// No description provided for @reportAbuse.
  ///
  /// In ru, this message translates to:
  /// **'Оскорбления'**
  String get reportAbuse;

  /// No description provided for @reportFraud.
  ///
  /// In ru, this message translates to:
  /// **'Мошенничество'**
  String get reportFraud;

  /// No description provided for @reportOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get reportOther;

  /// No description provided for @reportComment.
  ///
  /// In ru, this message translates to:
  /// **'Что случилось? (необязательно)'**
  String get reportComment;

  /// No description provided for @reportSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get reportSend;

  /// No description provided for @reportSent.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отправлена'**
  String get reportSent;

  /// No description provided for @reportSentBlockAsk.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отправлена. Заблокировать игрока?'**
  String get reportSentBlockAsk;

  /// No description provided for @notifyAmigos.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления об амигос'**
  String get notifyAmigos;

  /// No description provided for @notifyAmigosHint.
  ///
  /// In ru, this message translates to:
  /// **'кто-то добавил вас, ищет игрока, зовёт на турнир'**
  String get notifyAmigosHint;

  /// No description provided for @notifyMessages.
  ///
  /// In ru, this message translates to:
  /// **'Личные сообщения'**
  String get notifyMessages;

  /// No description provided for @notifyMessagesHint.
  ///
  /// In ru, this message translates to:
  /// **'пуш на новое сообщение'**
  String get notifyMessagesHint;

  /// No description provided for @profileHistory.
  ///
  /// In ru, this message translates to:
  /// **'История турниров'**
  String get profileHistory;

  /// No description provided for @profileHistorySub.
  ///
  /// In ru, this message translates to:
  /// **'Все сыгранные турниры'**
  String get profileHistorySub;

  /// No description provided for @profileMyLeagues.
  ///
  /// In ru, this message translates to:
  /// **'Мои лиги'**
  String get profileMyLeagues;

  /// No description provided for @profileMyLeaguesSub.
  ///
  /// In ru, this message translates to:
  /// **'Место в общей таблице и этапы'**
  String get profileMyLeaguesSub;

  /// No description provided for @profileMyTournaments.
  ///
  /// In ru, this message translates to:
  /// **'Мои турниры'**
  String get profileMyTournaments;

  /// No description provided for @profileMyTournamentsSub.
  ///
  /// In ru, this message translates to:
  /// **'Те, на которые ты записан'**
  String get profileMyTournamentsSub;

  /// No description provided for @profileInvitations.
  ///
  /// In ru, this message translates to:
  /// **'Приглашения на турнир'**
  String get profileInvitations;

  /// No description provided for @profileInvitationsSub.
  ///
  /// In ru, this message translates to:
  /// **'Турниры, куда тебя позвали'**
  String get profileInvitationsSub;

  /// No description provided for @profileMyTrainings.
  ///
  /// In ru, this message translates to:
  /// **'Мои тренировки'**
  String get profileMyTrainings;

  /// No description provided for @profileMyTrainingsSub.
  ///
  /// In ru, this message translates to:
  /// **'Занятия, на которые ты записан'**
  String get profileMyTrainingsSub;

  /// No description provided for @profileSupport.
  ///
  /// In ru, this message translates to:
  /// **'Служба поддержки'**
  String get profileSupport;

  /// No description provided for @profileSupportSub.
  ///
  /// In ru, this message translates to:
  /// **'Задать вопрос или сообщить о проблеме'**
  String get profileSupportSub;

  /// No description provided for @amigoOpenLive.
  ///
  /// In ru, this message translates to:
  /// **'Смотреть трансляцию'**
  String get amigoOpenLive;

  /// No description provided for @amigoOpenTournament.
  ///
  /// In ru, this message translates to:
  /// **'Открыть турнир'**
  String get amigoOpenTournament;

  /// No description provided for @amigoOpenGame.
  ///
  /// In ru, this message translates to:
  /// **'Открыть игру'**
  String get amigoOpenGame;

  /// No description provided for @amigoOpenProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль игрока'**
  String get amigoOpenProfile;

  /// No description provided for @amigosSearchPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Имя или фамилия'**
  String get amigosSearchPlaceholder;

  /// No description provided for @amigosSearchNothing.
  ///
  /// In ru, this message translates to:
  /// **'Никого не нашли. Попробуйте другое написание'**
  String get amigosSearchNothing;

  /// No description provided for @amigosSearchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Найти игрока'**
  String get amigosSearchTitle;
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
