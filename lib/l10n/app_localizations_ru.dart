// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Padel KZ';

  @override
  String get navHome => 'Главная';

  @override
  String get navTournaments => 'Турниры';

  @override
  String get navChallenges => 'Поединок';

  @override
  String get navRating => 'Рейтинг';

  @override
  String get navProfile => 'Профиль';

  @override
  String hello(String name) {
    return 'Привет, $name!';
  }

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get bookCourt => 'Забронировать корт';

  @override
  String get bookCourtSubtitle => 'Выберите клуб и удобное время';

  @override
  String get nearestTournament => 'Ближайший турнир';

  @override
  String get activeTournament => 'Активный турнир';

  @override
  String get upcoming => 'Скоро';

  @override
  String get all => 'Все';

  @override
  String get rating => 'РЕЙТИНГ';

  @override
  String get level => 'УРОВЕНЬ';

  @override
  String get place => 'МЕСТО';

  @override
  String get matches => 'МАТЧЕЙ';

  @override
  String get wins => 'ПОБЕД';

  @override
  String get winrate => 'ВИНРЕЙТ';

  @override
  String get selectClub => 'Выберите клуб';

  @override
  String get searchClub => 'Поиск клуба...';

  @override
  String get allCities => 'Все';

  @override
  String courtsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'кортов',
      few: 'корта',
      one: 'корт',
    );
    return '$count $_temp0';
  }

  @override
  String priceFrom(String price) {
    return 'от $price ₸';
  }

  @override
  String get noClubsFound => 'Клубов не найдено';

  @override
  String get booking => 'Бронирование';

  @override
  String get court => 'Корт';

  @override
  String get date => 'Дата';

  @override
  String get time => 'Время';

  @override
  String get start => 'Начало';

  @override
  String get duration => 'Длительность';

  @override
  String get total => 'Итого';

  @override
  String get coach => 'Тренер';

  @override
  String get coachOptional => 'Тренер (необязательно)';

  @override
  String get yourName => 'Имя';

  @override
  String get phone => 'Телефон';

  @override
  String get comment => 'Комментарий';

  @override
  String get optional => 'Необязательно';

  @override
  String get enterName => 'Введите имя';

  @override
  String bookButton(String price) {
    return 'Забронировать — $price ₸';
  }

  @override
  String get bookingConfirmed => 'Бронь подтверждена!';

  @override
  String get bookingConfirmedSubtitle => 'Вы успешно забронировали корт';

  @override
  String get myBookings => 'Мои бронирования';

  @override
  String get goHome => 'На главную';

  @override
  String get upcomingBookings => 'Предстоящие';

  @override
  String get pastBookings => 'Прошедшие';

  @override
  String get noUpcomingBookings => 'Нет предстоящих бронирований';

  @override
  String get noPastBookings => 'Нет прошедших бронирований';

  @override
  String get statusPending => 'Новая заявка';

  @override
  String get statusConfirmed => 'Подтверждено';

  @override
  String get statusCancelled => 'Отменено';

  @override
  String get cancel => 'Отменить';

  @override
  String get cancelBooking => 'Отменить бронирование?';

  @override
  String get areYouSure => 'Вы уверены?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get yesCancelIt => 'Да, отменить';

  @override
  String get bookingCancelled => 'Бронирование отменено';

  @override
  String get cancelError => 'Ошибка отмены';

  @override
  String get occupied => 'Занято';

  @override
  String get blocked => 'Заблок.';

  @override
  String get free => 'Свободен';

  @override
  String get noCourtsAvailable => 'Нет доступных кортов';

  @override
  String get noSlotsForDay => 'Нет слотов на этот день';

  @override
  String get today => 'Сегодня';

  @override
  String get hourOne => 'час';

  @override
  String get hourFew => 'часа';

  @override
  String get hourMany => 'часов';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationSettings => 'Настройки уведомлений';

  @override
  String get bookedCourts => 'Забронированные корты';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutSubtitle => 'Выйти из аккаунта';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountSubtitle => 'Безвозвратное удаление';

  @override
  String get retry => 'Повторить';

  @override
  String get error => 'Ошибка';

  @override
  String get networkError => 'Ошибка сети. Проверьте подключение к интернету.';

  @override
  String get loadError => 'Ошибка загрузки данных';

  @override
  String get language => 'Язык';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';
}
