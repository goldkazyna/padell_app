// Shared profile data

const PROFILE = {
  name: 'Андрей Кузнецов',
  initials: 'АК',
  phone: '+7 777 422 12 12',
  city: 'Алматы',
  gender: 'Мужской',    // 'Мужской' | 'Женский'
  age: null,            // null = не указан
  hand: 'Правша',       // 'Правша' | 'Левша' | null
  position: null,       // 'Справа' | 'Слева' | 'Любая' | null
  playLevel: 1.00,
  preferredTime: null,  // 'Утро' | 'День' | 'Вечер'
};

// Profile completion % (count filled fields)
function computeCompletion(p) {
  const fields = ['name', 'phone', 'city', 'gender', 'age', 'hand', 'position', 'preferredTime'];
  const filled = fields.filter(k => p[k] != null && p[k] !== '').length;
  return Math.round((filled / fields.length) * 100);
}

Object.assign(window, { PROFILE, computeCompletion });
