enum AchievementType {
  // Unngåtte kjøp - Grunnleggende
  firstAvoid('first_avoid', 'Første unngåelse! 🎯',
      'Du unngikk ditt første impulsive kjøp!', 'check_circle', 1),
  fiveAvoided('five_avoided', 'Smart shopper 🌟', 'Unngikk 5 impulsive kjøp',
      'star', 5),
  tenAvoided('ten_avoided', 'Selvkontroll mester ⭐',
      'Unngikk 10 impulsive kjøp', 'stars', 10),
  twentyFiveAvoided('twentyfive_avoided', 'Spareekspert 💎',
      'Unngikk 25 impulsive kjøp', 'workspace_premium', 25),
  fiftyAvoided('fifty_avoided', 'Sparelegende 🏆', 'Unngikk 50 impulsive kjøp',
      'military_tech', 50),
  hundredAvoided('hundred_avoided', 'Sparemester 👑',
      'Unngikk 100 impulsive kjøp!', 'emoji_events', 100),

  // Streak achievements
  threeDayStreak('three_day_streak', 'På riktig vei 🔥',
      '3 dager på rad med gode beslutninger', 'local_fire_department', 3),
  weekStreak(
      'week_streak', 'Uke-kriger 💪', '7 dager streak oppnådd!', 'whatshot', 7),
  twoWeekStreak('two_week_streak', 'Utstoppelig 🚀', '14 dagers streak!',
      'trending_up', 14),
  monthStreak('month_streak', 'Månedens helt 🎖️',
      '30 dagers streak - fantastisk!', 'emoji_events', 30),
  fiftyDayStreak('fifty_day_streak', 'Dedikert sparer 💫', '50 dager på rad!',
      'auto_awesome', 50),
  hundredDayStreak('hundred_day_streak', 'Ustanselig ⚡',
      '100 dagers streak - legendarisk!', 'bolt', 100),

  // Spare achievements
  fiveHundredSaved('five_hundred_saved', 'Første sparemål 💰',
      'Spart 500 kr totalt', 'account_balance_wallet', 500),
  thousandSaved('thousand_saved', 'Tusenlappen 💵', 'Spart 1000 kr totalt',
      'savings', 1000),
  fiveThousandSaved('five_thousand_saved', 'Seriøs sparer 💸',
      'Spart 5000 kr totalt', 'payments', 5000),
  tenThousandSaved('ten_thousand_saved', 'Sparegris 🐷',
      'Spart 10 000 kr totalt', 'account_balance', 10000),
  twentyFiveThousandSaved('twentyfive_thousand_saved', 'Sparemester 🎯',
      'Spart 25 000 kr totalt', 'attach_money', 25000),
  fiftyThousandSaved('fifty_thousand_saved', 'Sparelegende 👑',
      'Spart 50 000 kr totalt', 'monetization_on', 50000),

  // Impulskontroll
  perfectWeek('perfect_week', 'Perfekt uke ✨',
      '7 beslutninger uten impulsiv kjøp', 'shield', 7),
  noImpulse('no_impulse', 'Jernvilje 🛡️', '20 beslutninger uten impulsiv kjøp',
      'verified', 20),
  fiftyDecisions('fifty_decisions', 'Beslutningstaker 🎓',
      'Tok 50 beslutninger totalt', 'psychology', 50),

  // Varierte prestasjoner
  firstPlanned('first_planned', 'Planlagt kjøp 📝',
      'Ditt første planlagte kjøp', 'event_available', 1),
  tenPlanned('ten_planned', 'Planlegger 📅', '10 planlagte kjøp',
      'calendar_month', 10),
  expensiveAvoided('expensive_avoided', 'Store beslutninger 💎',
      'Unngikk kjøp over 5000 kr', 'diamond', 5000),
  quickWin('quick_win', 'Rask beslutning ⚡', 'Tok beslutning innen 1 time',
      'flash_on', 1),
  patientSaver('patient_saver', '⏰ Tålmodig sparer',
      'Ventet fullt ut på et produkt over 2000 kr', 'schedule', 1),
  categoryMaster('category_master', 'Kategori-mester 🎯',
      'Lagt til produkter i 5+ kategorier', 'category', 5),
  earlyBird('early_bird', 'Morgenfugl 🌅', 'Tok beslutning før kl. 08:00',
      'wb_twilight', 1),
  nightOwl('night_owl', 'Nattugle 🦉', 'Tok beslutning etter kl. 22:00',
      'nightlight', 1);

  const AchievementType(
    this.id,
    this.titleKey,
    this.descriptionKey,
    this.iconName,
    this.targetValue,
  );

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String iconName;
  final int targetValue;
}
