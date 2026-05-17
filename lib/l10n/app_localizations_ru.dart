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
  String get navChallenges => 'Игра';

  @override
  String get navBooking => 'Бронирование';

  @override
  String get ratingTabRating => 'Рейтинг';

  @override
  String get ratingTabGrowth => 'Рост рейтинга';

  @override
  String get ratingTabTournaments => 'Турниры';

  @override
  String get growthPeriodWeek => 'Неделя';

  @override
  String get growthPeriodMonth => 'Месяц';

  @override
  String get growthPeriodAll => 'Всё время';

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
  String get losses => 'ПОРАЖ.';

  @override
  String levelProgressLabel(String from, String to) {
    return 'Уровень $from → $to';
  }

  @override
  String get weekdayShortMon => 'ПН';

  @override
  String get weekdayShortTue => 'ВТ';

  @override
  String get weekdayShortWed => 'СР';

  @override
  String get weekdayShortThu => 'ЧТ';

  @override
  String get weekdayShortFri => 'ПТ';

  @override
  String get weekdayShortSat => 'СБ';

  @override
  String get weekdayShortSun => 'ВС';

  @override
  String get tournamentTypeAmericano => 'Американо';

  @override
  String get tournamentTypeMexicano => 'Мексикано';

  @override
  String get tournamentTypeKingOfCourt => 'Король корта';

  @override
  String get tournamentTypeBaliKoc => 'Король Корта (Bali Format)';

  @override
  String get tournamentTypeTeam => 'Групповой + Плей-офф';

  @override
  String get tournamentTypeClassic => 'Классический';

  @override
  String get challengeCreateSubtitle => 'Вызвать на игру';

  @override
  String get challengesCardTitle => 'Игры';

  @override
  String get challengesCardSubtitle => 'Все вызовы';

  @override
  String get playerStatRating => 'Рейтинг';

  @override
  String get playerStatGames => 'Игры';

  @override
  String get playerStatWins => 'Побед';

  @override
  String get playerStatTournaments => 'Турниры';

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
  String get notifCategoryGeneral => 'Общие';

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

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsMenuItem => 'Настройки';

  @override
  String get settingsMenuItemSubtitle => 'Отображение рейтинга и уровня';

  @override
  String get preciseRatingTitle => 'Точные значения рейтинга';

  @override
  String get preciseRatingSubtitle =>
      'Показывать рейтинг и уровень с двумя знаками (2.69 вместо 2690)';

  @override
  String get newsChannelTitle => 'Последние новости приложения';

  @override
  String get newsChannelSubtitle => 'Telegram-канал @padelkz_app';

  @override
  String get newsChannelButton => 'Последние новости приложения';

  @override
  String get calendarLink => 'Календарь →';

  @override
  String get calendarTitle => 'Календарь турниров';

  @override
  String get calendarNoTournamentsForDay => 'На этот день турниров нет';

  @override
  String get calendarAllTournaments => 'Все турниры →';

  @override
  String calendarSeats(int filled, int max) {
    return '$filled/$max мест';
  }

  @override
  String calendarSeatsLeft(int n) {
    return 'Осталось $n';
  }

  @override
  String get calendarTodayDow => 'Сегодня';

  @override
  String get calendarEmptyAll => 'В ближайшие 14 дней турниров нет';

  @override
  String get register => 'Записаться';

  @override
  String get registered => 'Вы записаны';

  @override
  String levelShort(String level) {
    return 'Ур. $level';
  }

  @override
  String get noAvailableTournaments => 'Нет доступных турниров';

  @override
  String get notInTournaments => 'Вы не участвуете в турнирах';

  @override
  String get noUpcomingTournaments => 'Нет предстоящих турниров';

  @override
  String get tournaments => 'Турниры';

  @override
  String get openTab => 'Открытые';

  @override
  String get myTab => 'Мои';

  @override
  String get archiveTab => 'Архив';

  @override
  String get cancelledTab => 'Отменённые';

  @override
  String get noCancelledTournaments => 'Нет отменённых турниров';

  @override
  String get noOpenTournaments => 'Нет открытых турниров';

  @override
  String get notRegisteredForTournaments => 'Вы не записаны на турниры';

  @override
  String get noFinishedTournaments => 'Нет завершённых турниров';

  @override
  String get tournamentRegistered => 'Записан';

  @override
  String get noSpotsLeft => 'Мест нет';

  @override
  String clubTournamentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'турниров',
      few: 'турнира',
      one: 'турнир',
    );
    return '$count $_temp0';
  }

  @override
  String get failedToLoadTournament => 'Не удалось загрузить турнир';

  @override
  String shareFreeSpots(int count) {
    return 'Свободных мест: $count';
  }

  @override
  String shareLevel(String level) {
    return 'Уровень: $level';
  }

  @override
  String shareCost(String cost) {
    return 'Стоимость: $cost';
  }

  @override
  String get shareAppPromo =>
      'Padel KZ — скачай приложение и записывайся на турниры!';

  @override
  String get noSpotsLeftUpper => 'МЕСТ НЕТ';

  @override
  String get dateLabel => 'ДАТА';

  @override
  String get timeLabel => 'ВРЕМЯ';

  @override
  String get levelLabel => 'УРОВЕНЬ';

  @override
  String get costLabel => 'СТОИМОСТЬ';

  @override
  String get perPerson => 'за человека';

  @override
  String get pay => 'Оплатить';

  @override
  String get pendingModeration => 'На модерации';

  @override
  String get participants => 'Участники';

  @override
  String countOfMax(int count, int max) {
    return '$count из $max';
  }

  @override
  String get noParticipantsYet => 'Пока нет участников';

  @override
  String spotsLeftCount(int count) {
    return 'Ещё $count свободных мест';
  }

  @override
  String get pendingStatus => 'Ожидание';

  @override
  String get organizer => 'Организатор';

  @override
  String get registerButton => 'Записаться';

  @override
  String get applicationPending => 'Заявка на модерации';

  @override
  String get cancelApplication => 'Отменить заявку';

  @override
  String get cancelRegistration => 'Отменить запись';

  @override
  String get youAreParticipating => 'Вы участвуете';

  @override
  String get ok => 'ОК';

  @override
  String get choosePartner => 'Выбрать партнёра';

  @override
  String get subscriptionActive => 'Подписка активна';

  @override
  String get notifyOnFreeSpot => 'Уведомить о свободном месте';

  @override
  String get matchesLabel => 'МАТЧЕЙ';

  @override
  String get winsLabel => 'ПОБЕДЫ';

  @override
  String get ratingLabel => 'РЕЙТИНГ';

  @override
  String get matchesTitle => 'Матчи';

  @override
  String roundsCount(int count) {
    return '$count раундов';
  }

  @override
  String get resultDraw => 'НИЧЬЯ';

  @override
  String get resultWin => 'ПОБЕДА';

  @override
  String get resultLoss => 'ПОРАЖЕНИЕ';

  @override
  String placeResult(int place) {
    return '$place место';
  }

  @override
  String get teamConfirmed => 'Подтверждена';

  @override
  String get yourTeam => 'Ваша команда';

  @override
  String get teams => 'Команды';

  @override
  String get noTeamsYet => 'Пока нет команд';

  @override
  String get enterPhoneNumber => 'Введите номер телефона';

  @override
  String get playersNotFound => 'Игроки не найдены';

  @override
  String registerWith(String name) {
    return 'Записаться с $name';
  }

  @override
  String get challenge => 'Игра';

  @override
  String get challengeHint =>
      'Находите соперников и играйте рейтинговые или товарищеские матчи';

  @override
  String get challengeOpenTab => 'Открытые';

  @override
  String get challengeMyTab => 'Мои';

  @override
  String get noOpenChallenges => 'Нет открытых игр';

  @override
  String get noMyChallenges => 'У вас нет игр';

  @override
  String get challengeNotSpecified => 'Не указано';

  @override
  String challengeLevel(String level) {
    return 'Уровень $level';
  }

  @override
  String get challengeRated => 'Рейтинговый';

  @override
  String get challengeFriendly => 'Товарищеский';

  @override
  String get challengeJoinSlot => 'Занять место';

  @override
  String get challengeDetails => 'Подробнее';

  @override
  String get challengeChoosePosition => 'Выберите позицию';

  @override
  String get challengePositionHint =>
      'Позиции 1-2 — Команда A, 3-4 — Команда B';

  @override
  String get challengeTeamA => 'Команда A';

  @override
  String get challengeTeamB => 'Команда B';

  @override
  String get challengeCancelTitle => 'Отменить игру?';

  @override
  String get challengeCancelConfirm => 'Вы уверены, что хотите отменить игру?';

  @override
  String get challengeYesCancel => 'Да, отменить';

  @override
  String get challengeEnterScore => 'Введите счёт хотя бы в одном сете';

  @override
  String get challengeNotFound => 'Игра не найдена';

  @override
  String get challengeScore => 'СЧЁТ';

  @override
  String get challengeAddSet => 'Добавить сет';

  @override
  String get challengeFinish => 'Завершить игру';

  @override
  String get challengeScoreCreatorHint =>
      'Счёт вводит создатель игры. После завершения вы сможете подтвердить результат.';

  @override
  String get challengeResult => 'РЕЗУЛЬТАТ';

  @override
  String challengeSetScore(int index, int scoreA, int scoreB) {
    return 'Сет $index    $scoreA : $scoreB';
  }

  @override
  String get challengeConfirmed => 'Подтвердил';

  @override
  String get challengeWaiting => 'Ожидание';

  @override
  String get challengeConfirmScore => 'Подтверждаю счёт';

  @override
  String get challengeScoreConfirmed => 'Вы подтвердили счёт';

  @override
  String get challengeTeamAWin => 'Победа команды A';

  @override
  String get challengeTeamBWin => 'Победа команды B';

  @override
  String get challengeDraw => 'Ничья';

  @override
  String challengeSetLabel(int index) {
    return 'Сет $index';
  }

  @override
  String get challengeAccept => 'Принять';

  @override
  String get challengeDecline => 'Отклонить';

  @override
  String get challengeWaitingInvites =>
      'Ожидание подтверждения приглашённых игроков';

  @override
  String challengeNeedMorePlayers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'игрока',
      one: 'игрок',
    );
    return 'Для начала нужно ещё $count $_temp0';
  }

  @override
  String get challengeStart => 'Начать игру';

  @override
  String get challengeCancelButton => 'Отменить игру';

  @override
  String get challengeLeave => 'Покинуть';

  @override
  String get challengeAddPlayer => 'Добавить игрока';

  @override
  String challengePositionTeam(int position, String team) {
    return 'Позиция $position · $team';
  }

  @override
  String get challengePhoneHint => 'Номер телефона';

  @override
  String get challengeNobodyFound => 'Никого не найдено';

  @override
  String get challengeLeaveOpen => 'Оставить открытым';

  @override
  String get challengeYou => 'Вы';

  @override
  String get challengeSpecifyDateTime => 'Укажите дату и время';

  @override
  String get challengeErrorTitle => 'Ошибка';

  @override
  String get challengeDoneTitle => 'Готово';

  @override
  String get challengeMonthJan => 'января';

  @override
  String get challengeMonthFeb => 'февраля';

  @override
  String get challengeMonthMar => 'марта';

  @override
  String get challengeMonthApr => 'апреля';

  @override
  String get challengeMonthMay => 'мая';

  @override
  String get challengeMonthJun => 'июня';

  @override
  String get challengeMonthJul => 'июля';

  @override
  String get challengeMonthAug => 'августа';

  @override
  String get challengeMonthSep => 'сентября';

  @override
  String get challengeMonthOct => 'октября';

  @override
  String get challengeMonthNov => 'ноября';

  @override
  String get challengeMonthDec => 'декабря';

  @override
  String get challengeNewTitle => 'Новая игра';

  @override
  String get challengeDatePlaceholder => 'Дата';

  @override
  String get challengeTimePlaceholder => 'Время';

  @override
  String get challengeType => 'Тип игры';

  @override
  String get challengeMinLevel => 'Мин. уровень';

  @override
  String get challengeMaxLevel => 'Макс. уровень';

  @override
  String get challengeCourtLayout => 'РАССТАНОВКА НА КОРТЕ';

  @override
  String get challengeCreateButton => 'Создать игру';

  @override
  String get challengeLoadingClubs => 'Загрузка...';

  @override
  String get challengeClubOptional => 'Клуб (необязательно)';

  @override
  String get challengeNoClub => 'Без клуба';

  @override
  String get courtNet => 'СЕТКА';

  @override
  String get courtInvite => 'Пригласить';

  @override
  String get courtFreeSlot => 'Свободно';

  @override
  String get ratingTitle => 'Рейтинг';

  @override
  String get ratingSearchHint => 'Поиск по имени...';

  @override
  String get ratingPlayerHeader => 'ИГРОК';

  @override
  String get ratingPointsHeader => 'ОЧКИ';

  @override
  String get ratingPlayersNotFound => 'Игроки не найдены';

  @override
  String ratingRemainingPlayers(int count) {
    return '$count игроков';
  }

  @override
  String get ratingShowAll => 'Показать всех';

  @override
  String get ratingMyPosition => 'Моя позиция';

  @override
  String ratingLevelPoints(String level, String rating) {
    return 'Уровень $level · $rating очков';
  }

  @override
  String ratingOutOfPlayers(int count) {
    return 'из $count игроков';
  }

  @override
  String get ratingFilterAll => 'Все';

  @override
  String get profileUser => 'Пользователь';

  @override
  String profileLevelLabel(String level) {
    return 'Уровень $level';
  }

  @override
  String get profileMissingCity => 'город';

  @override
  String get profileMissingGender => 'пол';

  @override
  String get profileMissingPhone => 'телефон';

  @override
  String profileMissingFields(String fields) {
    return 'Укажите $fields в настройках профиля';
  }

  @override
  String get profileMissingAnd => ' и ';

  @override
  String get profileBannerTitle => 'Заполните профиль';

  @override
  String get profileBannerDesc =>
      'Без этих данных нельзя записаться на турнир.';

  @override
  String profileBannerMissing(String fields) {
    return 'Не заполнено: $fields';
  }

  @override
  String get profileBannerCta => 'Дозаполнить';

  @override
  String get profileBannerSeparator => ' · ';

  @override
  String get tournamentHistory => 'История турниров';

  @override
  String get allButton => 'Все';

  @override
  String get noFinishedTournamentsYet => 'Пока нет завершённых турниров';

  @override
  String placeLabel(int place) {
    return '$place место';
  }

  @override
  String get matchHistory => 'История матчей';

  @override
  String get noMatchesYet => 'Пока нет матчей';

  @override
  String get loadMore => 'Загрузить ещё';

  @override
  String get winResult => 'Победа';

  @override
  String get lossResult => 'Поражение';

  @override
  String get achievements => 'Достижения';

  @override
  String get achievementFirstWin => 'Первая\nпобеда';

  @override
  String get achievementFiveWins => '5 побед\nподряд';

  @override
  String get achievementTopTen => 'Топ-10\nрейтинга';

  @override
  String get achievementTenTournaments => '10 турниров';

  @override
  String get editProfile => 'Настройки профиля';

  @override
  String get editProfileSubtitle => 'Имя, город, пол';

  @override
  String get saveProfile => 'Сохранить';

  @override
  String get sectionName => 'ФИО';

  @override
  String get fieldName => 'Имя';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get sectionPhone => 'ТЕЛЕФОН';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get phoneHintEdit => '+7 (___) ___-__-__';

  @override
  String get phoneLockedHint => 'Телефон нельзя изменить';

  @override
  String get phoneInvalidFormat => 'Введите корректный номер';

  @override
  String get sectionLocation => 'МЕСТОПОЛОЖЕНИЕ';

  @override
  String get fieldCity => 'Город';

  @override
  String get cityNotSpecified => 'Не указан';

  @override
  String get selectCity => 'Выберите город';

  @override
  String get sectionGender => 'ПОЛ';

  @override
  String get genderMale => 'Мужской';

  @override
  String get genderFemale => 'Женский';

  @override
  String get sectionAge => 'ВОЗРАСТ';

  @override
  String get fieldAge => 'Лет';

  @override
  String get ageNotSpecified => 'Не указан';

  @override
  String get sectionHand => 'ВЕДУЩАЯ РУКА';

  @override
  String get handRight => 'Правша';

  @override
  String get handLeft => 'Левша';

  @override
  String get sectionPosition => 'ПОЗИЦИЯ НА КОРТЕ';

  @override
  String get positionRight => 'Справа';

  @override
  String get positionLeft => 'Слева';

  @override
  String get positionAny => 'Любая';

  @override
  String get photoCamera => 'Камера';

  @override
  String get photoGallery => 'Галерея';

  @override
  String photoUploadError(String error) {
    return 'Ошибка загрузки фото: $error';
  }

  @override
  String saveError(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get logoutTitle => 'Выход';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт';

  @override
  String get deleteAccountWarning =>
      'Это действие необратимо. Все ваши данные будут удалены.';

  @override
  String get deleteAccountPassword => 'Пароль (если есть)';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get notificationSettingsMenu => 'Настройки уведомлений';

  @override
  String get dayMon => 'Пн';

  @override
  String get dayTue => 'Вт';

  @override
  String get dayWed => 'Ср';

  @override
  String get dayThu => 'Чт';

  @override
  String get dayFri => 'Пт';

  @override
  String get daySat => 'Сб';

  @override
  String get daySun => 'Вс';

  @override
  String get monthShortJan => 'янв';

  @override
  String get monthShortFeb => 'фев';

  @override
  String get monthShortMar => 'мар';

  @override
  String get monthShortApr => 'апр';

  @override
  String get monthShortMay => 'май';

  @override
  String get monthShortJun => 'июн';

  @override
  String get monthShortJul => 'июл';

  @override
  String get monthShortAug => 'авг';

  @override
  String get monthShortSep => 'сен';

  @override
  String get monthShortOct => 'окт';

  @override
  String get monthShortNov => 'ноя';

  @override
  String get monthShortDec => 'дек';

  @override
  String courtDefault(int index) {
    return 'Корт $index';
  }

  @override
  String get bookingError => 'Ошибка бронирования';

  @override
  String get summaryClub => 'Клуб';

  @override
  String get summaryCourt => 'Корт';

  @override
  String get summaryDate => 'Дата';

  @override
  String get summaryStart => 'Начало';

  @override
  String get summaryTime => 'Время';

  @override
  String get summaryCoach => 'Тренер';

  @override
  String get summaryTotal => 'Итого';

  @override
  String courtPriceBreakdown(String courtPrice, String coachPrice) {
    return 'Корт $courtPrice + Тренер $coachPrice ₸';
  }

  @override
  String coachPlus(String price) {
    return '+ тренер $price ₸';
  }

  @override
  String get failedToLoadNotifications => 'Не удалось загрузить уведомления';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String minutesAgo(int count) {
    return '$count мин. назад';
  }

  @override
  String hoursAgo(int count) {
    return '$count ч. назад';
  }

  @override
  String daysAgo(int count) {
    return '$count дн. назад';
  }

  @override
  String get failedToLoadSettings => 'Не удалось загрузить настройки';

  @override
  String get settingsSaveError => 'Ошибка сохранения настроек';

  @override
  String get onlyMyLevelTournaments => 'Только турниры моего уровня';

  @override
  String get onlyMyLevelTournamentsDesc =>
      'Получать уведомления только о турнирах, подходящих по вашему уровню';

  @override
  String get notifyClubsTitle => 'Уведомления от клубов';

  @override
  String get notifyClubsDesc =>
      'Выберите клубы, от которых хотите получать уведомления о новых турнирах';

  @override
  String get onboardingTitle1 => 'Участвуйте\nв турнирах';

  @override
  String get onboardingDesc1 =>
      'Находите турниры по падел-теннису\nрядом с вами и регистрируйтесь в\nодин клик';

  @override
  String get onboardingTitle2 => 'Следите за\nрейтингом';

  @override
  String get onboardingDesc2 =>
      'Отслеживайте свой прогресс и\nсравнивайте результаты с другими\nигроками';

  @override
  String get onboardingTitle3 => 'Находите\nпартнёров';

  @override
  String get onboardingDesc3 =>
      'Ищите игроков своего уровня для\nсовместных тренировок и турниров';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get authAcceptHint =>
      'Для продолжения необходимо принять пользовательское соглашение и дать согласие на обработку персональных данных';

  @override
  String get understood => 'Понятно';

  @override
  String get termsOfService => 'Пользовательское соглашение';

  @override
  String get consentToProcessing => 'Согласие на обработку данных';

  @override
  String get enterCode => 'Введите код';

  @override
  String get authCancel => 'Отмена';

  @override
  String get loginTitle => 'Вход';

  @override
  String get enterPhoneForLogin => 'Введите номер телефона для входа';

  @override
  String get loginViaTelegramToContinue =>
      'Войдите через Telegram для продолжения';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get enterValidNumber => 'Введите корректный номер';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get or => 'или';

  @override
  String get loginViaTelegram => 'Войти через Telegram';

  @override
  String get loginViaEmail => 'Войти через Email или телефон';

  @override
  String get consentToProcessPersonalData =>
      'Согласие на обработку персональных данных';

  @override
  String get emailLoginTitle => 'Вход';

  @override
  String get enterEmailAndPassword => 'Введите email или телефон и пароль';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get signIn => 'Войти';

  @override
  String get noAccount => 'Нет аккаунта? ';

  @override
  String get registerLink => 'Зарегистрироваться';

  @override
  String get enterEmail => 'Введите email';

  @override
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get emailOrPhone => 'Email или телефон';

  @override
  String get enterEmailOrPhone => 'Введите email или телефон';

  @override
  String get enterValidEmailOrPhone => 'Введите корректный email или телефон';

  @override
  String get emailOrPhonePlaceholder => 'example@mail.com или +7 777 123 45 67';

  @override
  String get registrationTitle => 'Регистрация';

  @override
  String get createAccountToContinue => 'Создайте аккаунт для продолжения';

  @override
  String get fullName => 'ФИО';

  @override
  String get fullNamePlaceholder => 'Иванов Иван Иванович';

  @override
  String get enterFullName => 'Введите ФИО';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get cityLabel => 'Город';

  @override
  String get selectCityTitle => 'Выберите город';

  @override
  String get minSixChars => 'Минимум 6 символов';

  @override
  String get enterPasswordHint => 'Введите пароль';

  @override
  String get passwordMinLength => 'Пароль должен быть не менее 6 символов';

  @override
  String get confirmPassword => 'Подтверждение пароля';

  @override
  String get repeatPassword => 'Повторите пароль';

  @override
  String get confirmPasswordHint => 'Подтвердите пароль';

  @override
  String get passwordsDontMatch => 'Пароли не совпадают';

  @override
  String get registerAction => 'Зарегистрироваться';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get signInLink => 'Войти';

  @override
  String get passwordRecovery => 'Восстановление пароля';

  @override
  String get enterEmailForResetLink =>
      'Введите email для получения ссылки\nна сброс пароля';

  @override
  String get linkSentToEmail => 'Ссылка отправлена на email';

  @override
  String get backToLogin => 'Вернуться к входу';

  @override
  String get sendLink => 'Отправить ссылку';

  @override
  String get verificationCode => 'Код подтверждения';

  @override
  String codeSentTo(String phone) {
    return 'Код отправлен на $phone';
  }

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String get confirmButton => 'Подтвердить';

  @override
  String get confirmLogin => 'Подтвердите вход';

  @override
  String get pressStartInTelegram =>
      'Нажмите Start в Telegram боте\nи вернитесь в приложение';

  @override
  String get connectionFailed => 'Не удалось подключиться';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get waitingForConfirmation => 'Ожидание подтверждения...';

  @override
  String get openTelegram => 'Открыть Telegram';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get updateRequired =>
      'Для продолжения работы необходимо обновить приложение';

  @override
  String get newVersionAvailable =>
      'Вышла новая версия приложения с улучшениями';

  @override
  String get updateButton => 'Обновить';

  @override
  String get later => 'Позже';

  @override
  String get profileMissingPhoneTitle => 'Укажите номер телефона';

  @override
  String get profileMissingPhoneDesc =>
      'Без него нельзя записаться на турниры и игры.';

  @override
  String get profileMissingCityTitle => 'Укажите город';

  @override
  String get profileMissingCityDesc =>
      'Чтобы видеть актуальные турниры в вашем городе.';

  @override
  String get profileMissingGenderTitle => 'Укажите пол';

  @override
  String get profileMissingGenderDesc =>
      'Нужно для парных турниров и подбора партнёров.';

  @override
  String get verificationNotConfirmedTitle => 'Рейтинг ещё не подтверждён';

  @override
  String get verificationNoAvatarTitle => 'Поставьте аватарку';

  @override
  String get verificationNoAvatarDesc =>
      'Зайдите в «Настройки профиля» и добавьте фото.';

  @override
  String get verificationNoTournamentsTitle => 'Сыграйте хотя бы один турнир';

  @override
  String get verificationNoTournamentsDesc =>
      'После завершения первого турнира рейтинг подтвердится автоматически.';

  @override
  String get verificationSheetTitle => 'Верификация уровня';

  @override
  String get verificationLatestEntry => 'ПОСЛЕДНЕЕ ПОДТВЕРЖДЕНИЕ';

  @override
  String get verificationFieldLevel => 'Установленный уровень';

  @override
  String get verificationFieldVerifiedBy => 'Кто подтвердил';

  @override
  String get verificationFieldClub => 'Клуб';

  @override
  String get verificationFieldWhen => 'Когда';

  @override
  String get verificationConfirmedByClub => 'Уровень подтверждён клубом.';

  @override
  String get verificationToConfirm => 'Чтобы рейтинг подтвердился:';

  @override
  String verificationHistoryRecords(int count) {
    return 'Записей в истории: $count';
  }

  @override
  String verificationLoadFailed(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get verificationNotConfirmedYet => 'Уровень пока не подтверждён.';

  @override
  String get verificationNotChecked =>
      'Уровень этого игрока ещё не подтверждался клубом.';

  @override
  String get tournamentDescription => 'Описание';

  @override
  String get showMore => 'Показать ещё';

  @override
  String get showLess => 'Свернуть';

  @override
  String get registerViaChat => 'Записаться через чат';

  @override
  String get searchClubHint => 'Поиск клуба';

  @override
  String get searchCommunityHint => 'Поиск комьюнити';

  @override
  String get cityAll => 'Все';

  @override
  String get bannerClubsTitle => 'Клубы';

  @override
  String get bannerClubsSubtitle => 'Адреса и контакты';

  @override
  String get bannerCommunityTitle => 'Комьюнити';

  @override
  String get bannerCommunitySubtitle => 'Сообщества игроков';

  @override
  String get bannerCreateTournamentTitle => 'Создать турнир';

  @override
  String get bannerCreateTournamentSubtitle => 'Организуй своё событие';

  @override
  String get bannerBookCourtTitle => 'Забронировать корт';

  @override
  String get bannerBookCourtSubtitle => 'Выберите клуб и удобное время';
}
