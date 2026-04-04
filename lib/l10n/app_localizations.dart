import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
  /// **'Поединок'**
  String get navChallenges;

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
  /// **'Активный турнир'**
  String get activeTournament;

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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
