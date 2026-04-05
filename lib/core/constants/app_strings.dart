enum AppLanguage { ru, tj, en }

abstract final class AppStrings {
  static const Map<String, Map<String, String>> all = {
    'ru': {
      'appName': 'UniBook',
      'appTitle': 'UniBook — Библиотека',
      'login': 'Войти',
      'register': 'Зарегистрироваться',
      'email': 'Email',
      'password': 'Пароль',
      'forgotPassword': 'Забыли пароль?',
      'name': 'Имя',
      'role': 'Роль',
      'student': 'Студент',
      'teacher': 'Учитель',
      'admin': 'Администратор',
      'teacherCode': 'Код учителя',
      'department': 'Кафедра',
      'searchBooks': 'Поиск книг',
      'searchUsers': 'Поиск пользователей',
      'noInternet': 'Нет подключения к интернету',
      'offlineMode': 'Офлайн режим',
      'invalidCredentials': 'Неверный email или пароль',
      'emailExists': 'Пользователь с таким email уже существует',
      'weakPassword': 'Пароль должен содержать минимум 6 символов',
      'invalidTeacherCode': 'Неверный код учителя',
      'fileTooLarge': 'Файл слишком большой. Максимум 50 МБ',
      'uploadFailed': 'Ошибка загрузки. Попробуйте снова',
      'uploadSuccess': 'Книга успешно загружена',
      'logout': 'Выйти',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'delete': 'Удалить',
      'edit': 'Редактировать',
      'myBooks': 'Мои книги',
      'adminPanel': 'Панель администратора',
      'settings': 'Настройки',
      'users': 'Пользователи',
      'departments': 'Кафедры',
      'statistics': 'Статистика',
      'addBook': 'Добавить книгу',
      'title': 'Название',
      'author': 'Автор',
      'year': 'Год',
      'subject': 'Предмет',
      'pickPdf': 'Выбрать PDF',
      'pickCover': 'Выбрать обложку',
      'requiredField': 'Заполните поле',
    },
    'tj': {
      'appName': 'UniBook',
      'appTitle': 'UniBook — Китобхона',
      'login': 'Ворид шудан',
      'register': 'Сабти ном',
      'email': 'Email',
      'password': 'Рамз',
      'forgotPassword': 'Рамзро фаромӯш кардед?',
      'name': 'Ном',
      'role': 'Нақш',
      'student': 'Донишҷӯ',
      'teacher': 'Омӯзгор',
      'admin': 'Администратор',
      'teacherCode': 'Рамзи омӯзгор',
      'department': 'Кафедра',
      'searchBooks': 'Ҷустуҷӯи китобҳо',
      'searchUsers': 'Ҷустуҷӯи корбарон',
      'noInternet': 'Интернет нест',
      'offlineMode': 'Ҳолати офлайн',
      'invalidCredentials': 'Email ё рамз нодуруст аст',
      'emailExists': 'Корбар бо чунин email аллакай ҳаст',
      'weakPassword': 'Рамз бояд ҳадди ақал 6 аломат дошта бошад',
      'invalidTeacherCode': 'Рамзи омӯзгор нодуруст аст',
      'fileTooLarge': 'Файл хеле калон аст. Ҳадди аксар 50 МБ',
      'uploadFailed': 'Хатои боргузорӣ. Боз кӯшиш кунед',
      'uploadSuccess': 'Китоб бомуваффақият боргузорӣ шуд',
      'logout': 'Баромадан',
      'cancel': 'Бекор кардан',
      'save': 'Нигоҳ доштан',
      'delete': 'Ҳазф кардан',
      'edit': 'Таҳрир кардан',
      'myBooks': 'Китобҳои ман',
      'adminPanel': 'Панели админ',
      'settings': 'Танзимот',
      'users': 'Корбарон',
      'departments': 'Кафедраҳо',
      'statistics': 'Омор',
      'addBook': 'Иловаи китоб',
      'title': 'Ном',
      'author': 'Муаллиф',
      'year': 'Сол',
      'subject': 'Фан',
      'pickPdf': 'Интихоби PDF',
      'pickCover': 'Интихоби муқова',
      'requiredField': 'Майдонро пур кунед',
    },
    'en': {
      'appName': 'UniBook',
      'appTitle': 'UniBook — Library',
      'login': 'Log in',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot password?',
      'name': 'Name',
      'role': 'Role',
      'student': 'Student',
      'teacher': 'Teacher',
      'admin': 'Administrator',
      'teacherCode': 'Teacher code',
      'department': 'Department',
      'searchBooks': 'Search books',
      'searchUsers': 'Search users',
      'noInternet': 'No internet connection',
      'offlineMode': 'Offline mode',
      'invalidCredentials': 'Invalid email or password',
      'emailExists': 'A user with this email already exists',
      'weakPassword': 'Password must contain at least 6 characters',
      'invalidTeacherCode': 'Invalid teacher code',
      'fileTooLarge': 'File is too large. Max 50 MB',
      'uploadFailed': 'Upload failed. Please try again',
      'uploadSuccess': 'Book uploaded successfully',
      'logout': 'Log out',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'myBooks': 'My books',
      'adminPanel': 'Admin panel',
      'settings': 'Settings',
      'users': 'Users',
      'departments': 'Departments',
      'statistics': 'Statistics',
      'addBook': 'Add book',
      'title': 'Title',
      'author': 'Author',
      'year': 'Year',
      'subject': 'Subject',
      'pickPdf': 'Pick PDF',
      'pickCover': 'Pick cover',
      'requiredField': 'Fill in the field',
    },
  };

  /// Returns a localized string by key for [languageCode].
  ///
  /// Fallback order:
  /// 1) requested language map
  /// 2) Russian (`ru`) map
  /// 3) the raw key itself
  static String t(String key, {String languageCode = 'ru'}) {
    return all[languageCode]?[key] ?? all['ru']?[key] ?? key;
  }

  static const appName = 'UniBook';
  static const appTitle = 'UniBook — Библиотека';
  static const login = 'Войти';
  static const register = 'Зарегистрироваться';
  static const email = 'Email';
  static const password = 'Пароль';
  static const forgotPassword = 'Забыли пароль?';
  static const name = 'Имя';
  static const role = 'Роль';
  static const student = 'Студент';
  static const teacher = 'Учитель';
  static const admin = 'Администратор';
  static const teacherCode = 'Код учителя';
  static const department = 'Кафедра';
  static const searchBooks = 'Поиск книг';
  static const searchUsers = 'Поиск пользователей';
  static const noInternet = 'Нет подключения к интернету';
  static const offlineMode = 'Офлайн режим';
  static const invalidCredentials = 'Неверный email или пароль';
  static const emailExists = 'Пользователь с таким email уже существует';
  static const weakPassword = 'Пароль должен содержать минимум 6 символов';
  static const invalidTeacherCode = 'Неверный код учителя';
  static const fileTooLarge = 'Файл слишком большой. Максимум 50 МБ';
  static const uploadFailed = 'Ошибка загрузки. Попробуйте снова';
  static const uploadSuccess = 'Книга успешно загружена';
  static const logout = 'Выйти';
  static const cancel = 'Отмена';
  static const save = 'Сохранить';
  static const delete = 'Удалить';
  static const edit = 'Редактировать';
  static const myBooks = 'Мои книги';
  static const adminPanel = 'Панель администратора';
  static const settings = 'Настройки';
  static const users = 'Пользователи';
  static const departments = 'Кафедры';
  static const statistics = 'Статистика';
  static const addBook = 'Добавить книгу';
  static const title = 'Название';
  static const author = 'Автор';
  static const year = 'Год';
  static const subject = 'Предмет';
  static const pickPdf = 'Выбрать PDF';
  static const pickCover = 'Выбрать обложку';
  static const requiredField = 'Заполните поле';
}
