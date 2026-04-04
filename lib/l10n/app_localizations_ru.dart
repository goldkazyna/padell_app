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
  String get challenge => 'Поединок';

  @override
  String get challengeOpenTab => 'Открытые';

  @override
  String get challengeMyTab => 'Мои';

  @override
  String get noOpenChallenges => 'Нет открытых поединков';

  @override
  String get noMyChallenges => 'У вас нет поединков';

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
  String get challengeCancelTitle => 'Отменить поединок?';

  @override
  String get challengeCancelConfirm =>
      'Вы уверены, что хотите отменить поединок?';

  @override
  String get challengeYesCancel => 'Да, отменить';

  @override
  String get challengeEnterScore => 'Введите счёт хотя бы в одном сете';

  @override
  String get challengeNotFound => 'Поединок не найден';

  @override
  String get challengeScore => 'СЧЁТ';

  @override
  String get challengeAddSet => 'Добавить сет';

  @override
  String get challengeFinish => 'Завершить поединок';

  @override
  String get challengeScoreCreatorHint =>
      'Счёт вводит создатель поединка. После завершения вы сможете подтвердить результат.';

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
  String get challengeStart => 'Начать поединок';

  @override
  String get challengeCancelButton => 'Отменить поединок';

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
  String get challengeNewTitle => 'Новый поединок';

  @override
  String get challengeDatePlaceholder => 'Дата';

  @override
  String get challengeTimePlaceholder => 'Время';

  @override
  String get challengeType => 'Тип поединка';

  @override
  String get challengeMinLevel => 'Мин. уровень';

  @override
  String get challengeMaxLevel => 'Макс. уровень';

  @override
  String get challengeCourtLayout => 'РАССТАНОВКА НА КОРТЕ';

  @override
  String get challengeCreateButton => 'Создать поединок';

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
}
