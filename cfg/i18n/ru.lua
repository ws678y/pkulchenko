return {
  [0] = function(c) return (c%10 == 1 and c%100 ~= 11) and 1 or (c%10 >= 2 and c%10 <= 4 and (c%100 < 10 or c%100 >= 20) and 2) or 3 end, -- plural
  ["&About"] = "&О программе", -- src\editor\menu_help.lua
  ["&Add Watch"] = "&Добавить выражение", -- src\editor\debugger.lua
  ["&Break"] = "Пр&ервать", -- src\editor\menu_project.lua
  ["&Close Page"] = "&Закрыть", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["&Compile"] = "&Компилировать", -- src\editor\menu_project.lua
  ["&Copy"] = "&Копировать", -- src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Default Layout"] = "Вид по &умолчанию", -- src\editor\menu_view.lua
  ["&Delete Watch"] = "&Удалить выражение", -- src\editor\debugger.lua
  ["&Edit Watch"] = "&Редактировать выражение", -- src\editor\debugger.lua
  ["&Edit"] = "&Правка", -- src\editor\menu_edit.lua
  ["&File"] = "&Файл", -- src\editor\menu_file.lua
  ["&Find"] = "&Найти", -- src\editor\menu_search.lua
  ["&Fold/Unfold All"] = "Св&ернуть/развернуть все", -- src\editor\menu_edit.lua
  ["&Goto Line"] = "&Перейти к строке", -- src\editor\menu_search.lua
  ["&Help"] = "&Справка", -- src\editor\menu_help.lua
  ["&New"] = "Соз&дать", -- src\editor\menu_file.lua
  ["&Open..."] = "&Открыть...", -- src\editor\menu_file.lua
  ["&Output/Console Window"] = "Окно &вывода/консоли", -- src\editor\menu_view.lua
  ["&Paste"] = "В&ставить", -- src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Project"] = "Пр&оект", -- src\editor\menu_project.lua, src\editor\inspect.lua
  ["&Redo"] = "Верну&ть", -- src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Replace"] = "За&менить", -- src\editor\menu_search.lua
  ["&Run"] = "За&пустить", -- src\editor\menu_project.lua
  ["&Save"] = "&Сохранить", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["&Search"] = "По&иск", -- src\editor\menu_search.lua
  ["&Sort"] = "&Cортировать", -- src\editor\menu_search.lua
  ["&Stack Window"] = "Окно &стека", -- src\editor\menu_view.lua
  ["&Start Debugger Server"] = "Запустить сервер отла&дки", -- src\editor\menu_project.lua
  ["&Undo"] = "&Отменить", -- src\editor\editor.lua, src\editor\menu_edit.lua
  ["&View"] = "&Вид", -- src\editor\menu_view.lua
  ["&Watch Window"] = "Окно &выражений", -- src\editor\menu_view.lua
  ["About %s"] = "О %s", -- src\editor\menu_help.lua
  ["Add Watch Expression"] = "Добавить выражение", -- src\editor\editor.lua
  ["Add to Scratchpad"] = "Добавить в черновик", -- src\editor\editor.lua
  ["All files"] = "Все файлы", -- src\editor\commands.lua
  ["Allow external process to start debugging"] = "Разрешить внешнему процессу начать отладку", -- src\editor\menu_project.lua
  ["Analyze the source code"] = "Проанализировать исходный код", -- src\editor\inspect.lua
  ["Analyze"] = "Анализировать", -- src\editor\inspect.lua
  ["Auto Complete Identifiers"] = "Автодополнение идентификаторов", -- src\editor\menu_edit.lua
  ["Auto complete while typing"] = "Автоматически дополнять идентификаторы при наборе", -- src\editor\menu_edit.lua
  ["Break execution at the next executed line of code"] = "Прервать выполнение на следующей строке", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["C&lear Output Window"] = "Очистка ок&на вывода", -- src\editor\menu_project.lua
  ["C&omment/Uncomment"] = "Зако&мментировать/раскомментировать", -- src\editor\menu_edit.lua
  ["Can't debug the script in the active editor window."] = "Невозможно отладить скрипт в текущем окне редактирования.", -- src\editor\debugger.lua
  ["Can't find file '%s' in the current project to activate for debugging. Update the project or open the file in the editor before debugging."] = "Файл '%s', необходимый для отладки, не найден в текущем проекте. Обновите проект или откройте файл в редакторе перед началом отладки.", -- src\editor\debugger.lua
  ["Can't process auto-recovery record; invalid format: %s."] = "Ошибка обработки записи автоматического восстановления; неверный формат: %s.", -- src\editor\commands.lua
  ["Can't run the entry point script ('%s')."] = "Ошибка выполнения стартового скрипта ('%s').", -- src\editor\debugger.lua
  ["Can't start debugging session due to internal error '%s'."] = "Невозможно начать отладочную сессию из-за внутренней ошибки '%s'.", -- src\editor\debugger.lua
  ["Can't start debugging without an opened file or with the current file not being saved ('%s')."] = "Невозможно начать отладку без открытого файла или с несохраненным текущим файлом ('%s').", -- src\editor\debugger.lua
  ["Choose ..."] = "Выбрать ...", -- src\editor\menu_project.lua
  ["Choose a project directory"] = "Выберите каталог проекта", -- src\editor\menu_project.lua
  ["Clear &Dynamic Words"] = "Очистить &динамические слова", -- src\editor\menu_edit.lua
  ["Clear the output window before compiling or debugging"] = "Очистить окно вывода перед компиляцией или отладкой", -- src\editor\menu_project.lua
  ["Close &Other Pages"] = "Закрыть &остальные вкладки", -- src\editor\gui.lua
  ["Close A&ll Pages"] = "Закрыть &все вкладки", -- src\editor\gui.lua
  ["Close the current editor window"] = "Закрыть текущее окно редактирования", -- src\editor\menu_file.lua
  ["Co&ntinue"] = "Пр&одолжить", -- src\editor\menu_project.lua
  ["Col: %d"] = "Стб: %d", -- src\editor\editor.lua
  ["Comment or uncomment current or selected lines"] = "Закомментировать или раскомментировать текущую или выделенные строки", -- src\editor\menu_edit.lua
  ["Compilation error"] = "Ошибка компиляции", -- src\editor\debugger.lua, src\editor\commands.lua
  ["Compilation successful; %.0f%% success rate (%d/%d)."] = "Компиляция завершена успешно; процент успеха: %.0f%% (%d/%d).", -- src\editor\commands.lua
  ["Compile the current file"] = "Скомпилировать текущий файл", -- src\editor\menu_project.lua
  ["Complete &Identifier"] = "Дополнить &идентификатор", -- src\editor\menu_edit.lua
  ["Complete the current identifier"] = "Дополнить текущий идентификатор", -- src\editor\menu_edit.lua
  ["Copy selected text to clipboard"] = "Скопировать выделенный текст в буфер обмена", -- src\editor\menu_edit.lua
  ["Couldn't activate file '%s' for debugging; continuing without it."] = "Невозможно открыть файл '%s' для отладки; выполнение будет продолжено без него.", -- src\editor\debugger.lua
  ["Create an empty document"] = "Создать новый документ", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["Cu&t"] = "Вы&резать", -- src\editor\editor.lua, src\editor\menu_edit.lua
  ["Cut selected text to clipboard"] = "Вырезать выделенный текст в буфер обмена", -- src\editor\menu_edit.lua
  ["Debugger server started at %s:%d."] = "Сервер отладки запущен на %s:%d.", -- src\editor\debugger.lua
  ["Debugging session completed (%s)."] = "Отладочная сессия завершена (%s).", -- src\editor\debugger.lua
  ["Debugging session started in '%s'."] = "Отладочная сессия запущена в '%s'.", -- src\editor\debugger.lua
  ["Debugging suspended at %s:%s (couldn't activate the file)."] = "Отладка остановлена на %s:%s (невозможно открыть файл).", -- src\editor\debugger.lua
  ["Do you want to reload it?"] = "Перезагрузить его?", -- src\editor\editor.lua
  ["Do you want to save the changes to '%s'?"] = "Сохранить изменения в '%s'?", -- src\editor\commands.lua
  ["E&xit"] = "Вы&ход", -- src\editor\menu_file.lua
  ["Enter Lua code and press Enter to run it."] = "Введите код на Lua и нажмите Enter для выполнения.", -- src\editor\shellbox.lua
  ["Enter line number"] = "Введите номер строки", -- src\editor\menu_search.lua
  ["Error while loading API file: %s"] = "Ошибка загрузки файла определений API: %s", -- src\editor\autocomplete.lua
  ["Error while loading configuration file: %s"] = "Ошибка загрузки файла конфигурации: %s", -- src\editor\style.lua
  ["Error while processing API file: %s"] = "Ошибка обработки файла определений API: %s", -- src\editor\autocomplete.lua
  ["Error while processing configuration file: %s"] = "Ошибка обработки файла конфигурации: %s", -- src\editor\style.lua
  ["Error"] = "Ошибка", -- src\editor\commands.lua
  ["Evaluate in Console"] = "Выполнить в консоли", -- src\editor\editor.lua
  ["Execute the current project/file and keep updating the code to see immediate results"] = "Запустить текущий проект/файл и продолжать вносить изменения в код с немедленным выводом результатов", -- src\editor\menu_project.lua
  ["Execute the current project/file"] = "Запустить текущий проект/файл", -- src\editor\menu_project.lua
  ["Execution error"] = "Ошибка выполнения", -- src\editor\debugger.lua
  ["Exit program"] = "Выйти из программы", -- src\editor\menu_file.lua
  ["Expr"] = "Выр.", -- src\editor\debugger.lua
  ["Expression"] = "Выражение", -- src\editor\debugger.lua
  ["File '%s' has been modified on disk."] = "Файл '%s' был изменен на диске.", -- src\editor\editor.lua
  ["File '%s' has more recent timestamp than restored '%s'; please review before saving."] = "Файл '%s' имеет более позднее время модификации, чем восстановленный '%s'; пожалуйста просмотрите его перед сохранением.", -- src\editor\commands.lua
  ["File '%s' no longer exists."] = "Файл '%s' больше не существует.", -- src\editor\editor.lua
  ["File history"] = "История файлов", -- src\editor\menu_file.lua
  ["Find &In Files"] = "Н&айти в файлах", -- src\editor\menu_search.lua
  ["Find &Next"] = "Найти &далее", -- src\editor\menu_search.lua
  ["Find &Previous"] = "Найти &ранее", -- src\editor\menu_search.lua
  ["Find and replace text in files"] = "Найти и заменить текст в файлах", -- src\editor\menu_search.lua
  ["Find and replace text"] = "Найти и заменить текст", -- src\editor\menu_search.lua, src\editor\gui.lua
  ["Find text in files"] = "Найти текст в файлах", -- src\editor\menu_search.lua
  ["Find text"] = "Найти текст", -- src\editor\menu_search.lua, src\editor\gui.lua
  ["Find the earlier text occurence"] = "Найти предыдущее вхождение текста", -- src\editor\menu_search.lua
  ["Find the next text occurrence"] = "Найти следующее вхождение текста", -- src\editor\menu_search.lua
  ["Fold or unfold all code folds"] = "Свернуть или развернуть все блоки кода", -- src\editor\menu_edit.lua
  ["Found auto-recovery record and restored saved session."] = "Найдена запись авто-восстановления и восстановлена сохраненная сессия.", -- src\editor\commands.lua
  ["Full &Screen"] = "Во весь экр&ан", -- src\editor\menu_view.lua
  ["Go to a selected line"] = "Перейти к заданной строке", -- src\editor\menu_search.lua
  ["Goto Line"] = "Перейти к строке", -- src\editor\menu_search.lua
  ["INS"] = "ВСТ", -- src\editor\editor.lua
  ["Jump to a function definition..."] = "Перейти к определению функции...", -- src\editor\editor.lua
  ["Known Files"] = "Файлы Lua", -- src\editor\commands.lua
  ["Ln: %d"] = "Стр: %d", -- src\editor\editor.lua
  ["Local console"] = "Локальная консоль", -- src\editor\shellbox.lua, src\editor\gui.lua
  ["Lua &Interpreter"] = "&Интерпретатор Lua", -- src\editor\menu_project.lua
  ["Mapped remote request for '%s' to '%s'."] = "Удаленный запрос для '%s' отображен на '%s'.", -- src\editor\debugger.lua
  ["Mixed end-of-line encodings detected."] = "Обнаружены смешанные символы конца строки.", -- src\editor\commands.lua
  ["OVR"] = "ЗАМ", -- src\editor\editor.lua
  ["Open an existing document"] = "Открыть существующий документ", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["Open file"] = "Открыть файл", -- src\editor\commands.lua
  ["Output (running)"] = "Вывод (запущен)", -- src\editor\output.lua
  ["Output"] = "Вывод", -- src\editor\output.lua, src\editor\settings.lua, src\editor\gui.lua
  ["Paste text from the clipboard"] = "Вставить текст из буфера обмена", -- src\editor\menu_edit.lua
  ["Prepend '=' to show complex values on multiple lines."] = "Укажите '=' в начале выражения для отображения сложных значений на нескольких строках.", -- src\editor\shellbox.lua
  ["Press cancel to abort."] = "Нажмите Отмена для завершения.", -- src\editor\commands.lua
  ["Program '%s' started in '%s' (pid: %d)."] = "Программа '%s' запущена в '%s' (pid: %d).", -- src\editor\output.lua
  ["Program can't start because conflicting process is running as '%s'."] = "Программа не может быть запущена из-за конфликтующего процесса, выполняющегося как '%s'.", -- src\editor\output.lua
  ["Program completed in %.2f seconds (pid: %d)."] = "Программа завершена за %.2f секунд (pid: %d).", -- src\editor\output.lua
  ["Program starting as '%s'."] = "Программа запускается как '%s'.", -- src\editor\output.lua
  ["Program stopped (pid: %d)."] = "Программа завершена (pid: %d).", -- src\editor\debugger.lua
  ["Program unable to run as '%s'."] = "Программа не может быть запущена как '%s'.", -- src\editor\output.lua
  ["Project Directory"] = "Каталог проекта", -- src\editor\menu_project.lua
  ["Project"] = "Проект", -- src\editor\settings.lua, src\editor\gui.lua
  ["Project/&FileTree Window"] = "Окно &проекта/списка файлов", -- src\editor\menu_view.lua
  ["R/O"] = "R/O", -- src\editor\editor.lua
  ["R/W"] = "R/W", -- src\editor\editor.lua
  ["Re&place In Files"] = "Замени&ть в файлах", -- src\editor\menu_search.lua
  ["Recent Files"] = "Недавние файлы", -- src\editor\menu_file.lua
  ["Redo last edit undone"] = "Вернуть последнее отмененное изменение", -- src\editor\menu_edit.lua
  ["Refused a request to start a new debugging session as there is one in progress already."] = "Отказано в запросе на запуск новой отладочной сессии, поскольку одна сессия уже выполняется.", -- src\editor\debugger.lua
  ["Remote console"] = "Удаленная консоль", -- src\editor\shellbox.lua
  ["Replaced an invalid UTF8 character with %s."] = "Некорректный символ UTF8 заменен на %s.", -- src\editor\commands.lua
  ["Reset to default layout"] = "Установить расположение окон по умолчанию", -- src\editor\menu_view.lua
  ["Resets the dynamic word list for autocompletion"] = "Очистить список динамических слов для автодополнения", -- src\editor\menu_edit.lua
  ["Run as Scratchpad"] = "Запустить как черновик", -- src\editor\menu_project.lua
  ["S&top Debugging"] = "&Завершить отладку", -- src\editor\menu_project.lua
  ["S&top Process"] = "&Завершить процесс", -- src\editor\menu_project.lua
  ["Save &As..."] = "Сохранить &как...", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["Save A&ll"] = "Сохранить &все", -- src\editor\menu_file.lua
  ["Save Changes?"] = "Сохранить изменения?", -- src\editor\commands.lua
  ["Save all open documents"] = "Сохранить все открытые документы", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["Save file as"] = "Сохранить файл как", -- src\editor\commands.lua
  ["Save file?"] = "Сохранить файл?", -- src\editor\commands.lua
  ["Save the current document to a file with a new name"] = "Сохранить текущий документ в файл под новым именем", -- src\editor\menu_file.lua
  ["Save the current document"] = "Сохранить текущий документ", -- src\editor\menu_file.lua, src\editor\gui.lua
  ["Saved auto-recover at %s."] = "Сохранено авто-восст в %s.", -- src\editor\commands.lua
  ["Scratchpad error"] = "Ошибка в черновике", -- src\editor\debugger.lua
  ["Select &All"] = "Выделить &все", -- src\editor\editor.lua, src\editor\menu_edit.lua
  ["Select all text in the editor"] = "Выделить весь текст в редакторе", -- src\editor\menu_edit.lua
  ["Set From Current File"] = "Установить по текущему файлу", -- src\editor\menu_project.lua
  ["Set project directory from current file"] = "Установить каталог проекта по текущему файлу", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Set the interpreter to be used"] = "Установить используемый интерпретатор", -- src\editor\menu_project.lua
  ["Set the project directory to be used"] = "Установить используемый каталог проекта", -- src\editor\menu_project.lua
  ["Show &Tooltip"] = "Показать &подсказку", -- src\editor\menu_edit.lua
  ["Show tooltip for current position; place cursor after opening bracket of function"] = "Показать подсказку в текущей позиции; переместите курсор в позицию после открывающей скобки функции", -- src\editor\menu_edit.lua
  ["Sort selected lines"] = "Отсортировать выделенные строки", -- src\editor\menu_search.lua
  ["Stack"] = "Стек", -- src\editor\debugger.lua
  ["Start &Debugging"] = "Начать &отладку", -- src\editor\menu_project.lua
  ["Start debugging"] = "Начать отладку", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Step &Into"] = "&Войти", -- src\editor\menu_project.lua
  ["Step &Over"] = "&Следующая строка", -- src\editor\menu_project.lua
  ["Step O&ut"] = "В&ыйти", -- src\editor\menu_project.lua
  ["Step into"] = "Войти в функцию", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Step out of the current function"] = "Выйти из текущей функции", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Step over"] = "Перейти на следующую строку", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Stop the currently running process"] = "Завершить текущий процесс", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Switch to or from full screen mode"] = "Переключить полноэкранный режим", -- src\editor\menu_view.lua
  ["The API file must be located in a subdirectory of the API directory."] = "Файл определений API должен быть расположен в подкаталоге каталога API.", -- src\editor\autocomplete.lua
  ["Toggle Break&point"] = "&Точка останова", -- src\editor\menu_project.lua
  ["Toggle breakpoint"] = "Переключить точку останова", -- src\editor\menu_project.lua, src\editor\gui.lua
  ["Tr&ace"] = "Т&рассировка", -- src\editor\menu_project.lua
  ["Trace execution showing each executed line"] = "Отслеживать выполнение, показывая каждую выполненную строку", -- src\editor\menu_project.lua
  ["Unable to load file '%s'."] = "Ошибка загрузки файла '%s'.", -- src\editor\commands.lua
  ["Unable to save file '%s': %s"] = "Ошибка сохранения файла '%s': %s", -- src\editor\commands.lua
  ["Unable to stop program (pid: %d), code %d."] = "Невозможно завершить программу (pid: %d), код %d.", -- src\editor\debugger.lua
  ["Undo last edit"] = "Отменить последнее действие", -- src\editor\menu_edit.lua
  ["Use '%s' to see full description."] = "Используйте '%s' для полного описания.", -- src\editor\editor.lua
  ["Use '%s' to show line endings and '%s' to convert them."] = "Используйте '%s' для отображения символов конца строки и '%s' для их преобразования.", -- src\editor\commands.lua
  ["Use 'clear' to clear the shell output and the history."] = "Используйте команду 'clear' для очистки содержимого окна и истории.", -- src\editor\shellbox.lua
  ["Use Shift-Enter for multiline code."] = "Используйте Shift-Enter для многострочного кода.", -- src\editor\shellbox.lua
  ["Value"] = "Значение", -- src\editor\debugger.lua
  ["View the output/console window"] = "Показать окно вывода/консоли", -- src\editor\menu_view.lua
  ["View the project/filetree window"] = "Показать окно проекта/списка файлов", -- src\editor\menu_view.lua
  ["View the stack window"] = "Показать окно стека", -- src\editor\menu_view.lua, src\editor\gui.lua
  ["View the watch window"] = "Показать окно выражений", -- src\editor\menu_view.lua, src\editor\gui.lua
  ["Watch"] = "Выражение", -- src\editor\debugger.lua
  ["Welcome to the interactive Lua interpreter."] = "Добро пожаловать в интерактивный интерпретатор Lua.", -- src\editor\shellbox.lua
  ["You must save the program first."] = "Вы должны сначала сохранить программу.", -- src\editor\commands.lua
  ["on line %d"] = "в строке %d", -- src\editor\debugger.lua, src\editor\commands.lua
  ["traced %d instruction"] = {"выполнена %d инструкция", "выполнено %d инструкции", "выполнено %d инструкций"}, -- src\editor\debugger.lua
}
