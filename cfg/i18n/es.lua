-- Traducción realiazada por Iñigo Sola
return {
  [0] = function(c) return c == 1 and 1 or 2 end, -- plural
  ["%d instance"] = nil, -- src\editor\findreplace.lua
  ["%s event failed: %s"] = nil, -- src\editor\package.lua
  ["&About"] = "&Acerca de...", -- src\editor\menu_help.lua
  ["&Add Watch"] = "Añadir observación", -- src\editor\debugger.lua
  ["&Break"] = "Ruptura", -- src\editor\menu_project.lua
  ["&Close Page"] = "Cerrar página", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["&Community"] = nil, -- src\editor\menu_help.lua
  ["&Compile"] = "Compilar", -- src\editor\menu_project.lua
  ["&Copy"] = "Copiar", -- src\editor\gui.lua, src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Default Layout"] = "Diseño por defecto", -- src\editor\menu_view.lua
  ["&Delete Watch"] = "Eliminar observación", -- src\editor\debugger.lua
  ["&Delete"] = nil, -- src\editor\filetree.lua
  ["&Documentation"] = nil, -- src\editor\menu_help.lua
  ["&Down"] = nil, -- src\editor\findreplace.lua
  ["&Edit Project Directory"] = nil, -- src\editor\filetree.lua
  ["&Edit Value"] = nil, -- src\editor\debugger.lua
  ["&Edit Watch"] = "Editar observación", -- src\editor\debugger.lua
  ["&Edit"] = "Editar", -- src\editor\menu_edit.lua
  ["&File"] = "Archivo", -- src\editor\menu_file.lua
  ["&Find All"] = nil, -- src\editor\findreplace.lua
  ["&Find Next"] = nil, -- src\editor\findreplace.lua
  ["&Find"] = "Buscar", -- src\editor\menu_search.lua
  ["&Fold/Unfold All"] = "Plegar/desplegar todo", -- src\editor\menu_edit.lua
  ["&Frequently Asked Questions"] = nil, -- src\editor\menu_help.lua
  ["&Getting Started Guide"] = nil, -- src\editor\menu_help.lua
  ["&Help"] = "Ayuda", -- src\editor\menu_help.lua
  ["&New Directory"] = nil, -- src\editor\filetree.lua
  ["&New"] = "&Nuevo", -- src\editor\menu_file.lua
  ["&Open..."] = "&Abrir...", -- src\editor\menu_file.lua
  ["&Output/Console Window"] = "Salida/Consola", -- src\editor\menu_view.lua
  ["&Paste"] = "Pegar", -- src\editor\gui.lua, src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Project Page"] = nil, -- src\editor\menu_help.lua
  ["&Project"] = "Proyecto", -- src\editor\menu_project.lua
  ["&Redo"] = "Rehacer", -- src\editor\gui.lua, src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Rename"] = nil, -- src\editor\filetree.lua
  ["&Replace All"] = nil, -- src\editor\findreplace.lua
  ["&Replace"] = "Remplazar", -- src\editor\findreplace.lua, src\editor\menu_search.lua
  ["&Run"] = "Ejecutar", -- src\editor\menu_project.lua
  ["&Save"] = "Guardar", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["&Search"] = "Buscar", -- src\editor\menu_search.lua
  ["&Sort"] = "Clasificar", -- src\editor\menu_edit.lua
  ["&Stack Window"] = "Ventana de la pila de ejecución", -- src\editor\menu_view.lua
  ["&Start Debugger Server"] = "Lanzar servidor de depuración", -- src\editor\menu_project.lua
  ["&Status Bar"] = nil, -- src\editor\menu_view.lua
  ["&Subdirectories"] = nil, -- src\editor\findreplace.lua
  ["&Tool Bar"] = nil, -- src\editor\menu_view.lua
  ["&Tutorials"] = nil, -- src\editor\menu_help.lua
  ["&Undo"] = "Deshacer", -- src\editor\gui.lua, src\editor\editor.lua, src\editor\menu_edit.lua
  ["&Up"] = nil, -- src\editor\findreplace.lua
  ["&View"] = "Ver", -- src\editor\menu_view.lua
  ["&Watch Window"] = "Ventana de observaciones", -- src\editor\menu_view.lua
  [".bak on replace"] = nil, -- src\editor\findreplace.lua
  ["About %s"] = "Acerca de %s", -- src\editor\menu_help.lua
  ["Add To Scratchpad"] = "Añadir al borrador", -- src\editor\editor.lua
  ["Add Watch Expression"] = "Añadir expresión de observación", -- src\editor\editor.lua
  ["All files"] = "Todos los archivos", -- src\editor\commands.lua
  ["Allow external process to start debugging"] = "Permitir proceso externo para iniciar depuración", -- src\editor\menu_project.lua
  ["Analyze the source code"] = "Analizar el código fuente", -- src\editor\inspect.lua
  ["Analyze"] = "Analizar", -- src\editor\inspect.lua
  ["Auto Complete Identifiers"] = "Autocompletar identificadores", -- src\editor\menu_edit.lua
  ["Auto complete while typing"] = "Autocompletar mientras se escribe", -- src\editor\menu_edit.lua
  ["Bookmark"] = nil, -- src\editor\menu_edit.lua
  ["Break execution at the next executed line of code"] = "Parar ejecución en la siguiente línea de código", -- src\editor\menu_project.lua
  ["C&lear Output Window"] = "Limpiar ventana de Salida", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["C&omment/Uncomment"] = "Comentar/descomentar", -- src\editor\menu_edit.lua
  ["Can't debug the script in the active editor window."] = "No se puede depurar el script en la ventana activa del editor", -- src\editor\debugger.lua
  ["Can't evaluate the expression while the application is running."] = nil, -- src\editor\debugger.lua
  ["Can't find file '%s' in the current project to activate for debugging. Update the project or open the file in the editor before debugging."] = "No se puede encontrar el archivo '%s' en el proyecto actual para activar la depuración. Actualiza el proyecto o abre el archivo en el editor antes de depurar.", -- src\editor\debugger.lua
  ["Can't open file '%s': %s"] = nil, -- src\editor\singleinstance.lua
  ["Can't process auto-recovery record; invalid format: %s."] = "No se puede procesar la autorrecuperación; formato inválido: %s.", -- src\editor\commands.lua
  ["Can't run the entry point script ('%s')."] = "No se pude ejecutar el punto de entrada del script (%s).", -- src\editor\debugger.lua
  ["Can't start debugger server at %s:%d: %s."] = nil, -- src\editor\debugger.lua
  ["Can't start debugging session due to internal error '%s'."] = "No se puede iniciar la sesión de depuración debido a un error interno '%s'.'", -- src\editor\debugger.lua
  ["Can't start debugging without an opened file or with the current file not being saved ('%s')."] = "No se puede iniciar la depuración sin abrir un archivo o si no ha sido guardado ('%s').", -- src\editor\debugger.lua
  ["Can't stop debugger server as it is not started."] = nil, -- src\editor\debugger.lua
  ["Cancel"] = nil, -- src\editor\findreplace.lua
  ["Cancelled by the user."] = nil, -- src\editor\findreplace.lua
  ["Choose a project directory"] = "Elegir el directorio del proyecto", -- src\editor\findreplace.lua, src\editor\menu_project.lua, src\editor\filetree.lua
  ["Choose..."] = nil, -- src\editor\menu_project.lua, src\editor\filetree.lua
  ["Clear Items"] = nil, -- src\editor\menu_file.lua
  ["Clear items from this list"] = nil, -- src\editor\menu_file.lua
  ["Clear the output window before compiling or debugging"] = "Limpiar la ventana de salida antes de compilar o depurar", -- src\editor\menu_project.lua
  ["Close &Other Pages"] = nil, -- src\editor\gui.lua
  ["Close A&ll Pages"] = nil, -- src\editor\gui.lua
  ["Close the current editor window"] = "Cerrar la ventana actual del editor", -- src\editor\menu_file.lua
  ["Co&ntinue"] = "Continuar", -- src\editor\menu_project.lua
  ["Col: %d"] = "Col: %d", -- src\editor\editor.lua
  ["Command Line Parameters..."] = nil, -- src\editor\menu_project.lua
  ["Command line parameters"] = nil, -- src\editor\menu_project.lua
  ["Comment or uncomment current or selected lines"] = {"Comentar o descomentar la línea activa (seleccionada)","Comentar o descomentar las líneas activas (seleccionadas)"}, -- src\editor\menu_edit.lua
  ["Compilation error"] = "Error de compilación", -- src\editor\commands.lua, src\editor\debugger.lua
  ["Compilation successful; %.0f%% success rate (%d/%d)."] = "Compilación exitosa; factor de éxito: %.0f%% (%d/%d).", -- src\editor\commands.lua
  ["Compile the current file"] = "Compilar el archivo actual", -- src\editor\menu_project.lua
  ["Complete &Identifier"] = "Completar identificador", -- src\editor\menu_edit.lua
  ["Complete the current identifier"] = "Completar el actual identificador", -- src\editor\menu_edit.lua
  ["Consider removing backslash from escape sequence '%s'."] = nil, -- src\editor\commands.lua
  ["Copy Full Path"] = nil, -- src\editor\gui.lua, src\editor\filetree.lua
  ["Copy selected text to clipboard"] = "Copiar el texto seleccionado al portapapeles", -- src\editor\menu_edit.lua
  ["Correct &Indentation"] = nil, -- src\editor\menu_edit.lua
  ["Couldn't activate file '%s' for debugging; continuing without it."] = "No se pudo activar el archivo '%s' para la depuración; continuar sin él.", -- src\editor\debugger.lua
  ["Create an empty document"] = "Crear un documento en blanco", -- src\editor\menu_file.lua
  ["Cu&t"] = "Cortar", -- src\editor\gui.lua, src\editor\editor.lua, src\editor\menu_edit.lua
  ["Cut selected text to clipboard"] = "Cortar el texto selecionado al portapapeles", -- src\editor\menu_edit.lua
  ["Debugger server started at %s:%d."] = "Servidor de depuración inciado en %s:%s", -- src\editor\debugger.lua
  ["Debugger server stopped at %s:%d."] = nil, -- src\editor\debugger.lua
  ["Debugging session completed (%s)."] = "Sesión de depuración completada (%s).", -- src\editor\debugger.lua
  ["Debugging session started in '%s'."] = "Sesión de depuración iniciada en '%s'.", -- src\editor\debugger.lua
  ["Debugging suspended at '%s:%s' (couldn't activate the file)."] = nil, -- src\editor\debugger.lua
  ["Detach &Process"] = nil, -- src\editor\menu_project.lua
  ["Directory"] = nil, -- src\editor\findreplace.lua
  ["Do you want to delete '%s'?"] = nil, -- src\editor\filetree.lua
  ["Do you want to overwrite it?"] = nil, -- src\editor\commands.lua
  ["Do you want to reload it?"] = "¿Quieres recargarlo?", -- src\editor\editor.lua
  ["Do you want to save the changes to '%s'?"] = "¿Quieres guardar los cambios en '%s'?", -- src\editor\commands.lua
  ["E&xit"] = "Salir", -- src\editor\menu_file.lua
  ["Enter Lua code and press Enter to run it."] = "Introduce código Lua y pulsa <Entrer> para ejecutarlo.", -- src\editor\shellbox.lua
  ["Enter command line parameters (use Cancel to clear)"] = nil, -- src\editor\menu_project.lua
  ["Enter replacement text"] = nil, -- src\editor\editor.lua
  ["Error while loading API file: %s"] = "Error mientras se cargaba el archivo de API: %s", -- src\editor\autocomplete.lua
  ["Error while loading configuration file: %s"] = nil, -- src\editor\style.lua
  ["Error while processing API file: %s"] = "Error mientras se procesaba el archivo de API: %s", -- src\editor\autocomplete.lua
  ["Error while processing configuration file: %s"] = nil, -- src\editor\style.lua
  ["Error"] = "Error", -- src\editor\commands.lua
  ["Evaluate In Console"] = "Evaluar en consola", -- src\editor\editor.lua
  ["Execute the current project/file and keep updating the code to see immediate results"] = "Ejecutar el proyecto/archivo actual y manteniendo actualizado el código para ver resultados en tiempo real", -- src\editor\menu_project.lua
  ["Execute the current project/file"] = "Ejecutar el proyecto/archivo actual", -- src\editor\menu_project.lua
  ["Execution error"] = "Error de ejecución", -- src\editor\debugger.lua
  ["Exit program"] = "Salir del programa", -- src\editor\menu_file.lua
  ["File '%s' has been modified on disk."] = "El archivo '%s' ha sido modificado en el disco.", -- src\editor\editor.lua
  ["File '%s' has more recent timestamp than restored '%s'; please review before saving."] = "El archivo '%s' tiene una fecha más reciente que el restaurado '%s'; por favor, revísalo antes de guardar.", -- src\editor\commands.lua
  ["File '%s' is missing and can't be recovered."] = nil, -- src\editor\commands.lua
  ["File '%s' no longer exists."] = "El archivo '%s' no existe.", -- src\editor\menu_file.lua, src\editor\editor.lua
  ["File Type"] = nil, -- src\editor\findreplace.lua
  ["File already exists."] = nil, -- src\editor\commands.lua
  ["File history"] = "Historial de archivos", -- src\editor\menu_file.lua
  ["Find &In Files"] = "Buscar en archivos", -- src\editor\menu_search.lua
  ["Find &Next"] = "Buscar siguiente", -- src\editor\menu_search.lua
  ["Find &Previous"] = "Buscar anterior", -- src\editor\menu_search.lua
  ["Find In Files"] = nil, -- src\editor\findreplace.lua
  ["Find and insert library function"] = nil, -- src\editor\menu_search.lua
  ["Find and replace text in files"] = "Buscar y remplazar texto en archivos", -- src\editor\menu_search.lua
  ["Find and replace text"] = "Buscar y rempleazar texto", -- src\editor\menu_search.lua
  ["Find text in files"] = "Buscar texto en archivos", -- src\editor\menu_search.lua
  ["Find text"] = "Buscar texto", -- src\editor\menu_search.lua
  ["Find the earlier text occurence"] = "Buscar la anterior aparición del texto", -- src\editor\menu_search.lua
  ["Find the next text occurrence"] = "Buscar la siguiente aparecición del texto", -- src\editor\menu_search.lua
  ["Find"] = nil, -- src\editor\findreplace.lua
  ["Fold or unfold all code folds"] = "Plegar o desplegar todo el código plegado", -- src\editor\menu_edit.lua
  ["Found auto-recovery record and restored saved session."] = "Encontrada autorrecuperación y sesión restaurada.", -- src\editor\commands.lua
  ["Found"] = nil, -- src\editor\findreplace.lua
  ["Full &Screen"] = "Pantalla completa", -- src\editor\menu_view.lua
  ["Go To Definition"] = nil, -- src\editor\editor.lua
  ["Go To File..."] = nil, -- src\editor\menu_search.lua
  ["Go To Line..."] = "Ir a línea...", -- src\editor\menu_search.lua
  ["Go To Next Bookmark"] = nil, -- src\editor\menu_edit.lua
  ["Go To Previous Bookmark"] = nil, -- src\editor\menu_edit.lua
  ["Go To Symbol..."] = nil, -- src\editor\menu_search.lua
  ["Go to file"] = nil, -- src\editor\menu_search.lua
  ["Go to line"] = "Ir a línea", -- src\editor\menu_search.lua
  ["Go to symbol"] = nil, -- src\editor\menu_search.lua
  ["Hide '.%s' Files"] = nil, -- src\editor\filetree.lua
  ["INS"] = "INS", -- src\editor\editor.lua
  ["Ignored error in debugger initialization code: %s."] = nil, -- src\editor\debugger.lua
  ["In Files"] = nil, -- src\editor\findreplace.lua
  ["Insert Library Function..."] = nil, -- src\editor\menu_search.lua
  ["Known Files"] = "Archivos conocidos", -- src\editor\commands.lua
  ["Ln: %d"] = "Ln: %d", -- src\editor\editor.lua
  ["Local console"] = "Consola local", -- src\editor\gui.lua, src\editor\shellbox.lua
  ["Lua &Interpreter"] = "Intérprete Lua", -- src\editor\menu_project.lua
  ["Mapped remote request for '%s' to '%s'."] = nil, -- src\editor\debugger.lua
  ["Match case"] = nil, -- src\editor\findreplace.lua
  ["Match whole word"] = nil, -- src\editor\findreplace.lua
  ["Mixed end-of-line encodings detected."] = nil, -- src\editor\commands.lua
  ["Navigate"] = nil, -- src\editor\menu_search.lua
  ["New &File"] = nil, -- src\editor\filetree.lua
  ["OVR"] = "OVR", -- src\editor\editor.lua
  ["Open With Default Program"] = nil, -- src\editor\filetree.lua
  ["Open an existing document"] = "Abrir un documento existente", -- src\editor\menu_file.lua
  ["Open file"] = "Abrir archivo", -- src\editor\commands.lua
  ["Options"] = nil, -- src\editor\findreplace.lua
  ["Outline Window"] = nil, -- src\editor\menu_view.lua
  ["Outline"] = nil, -- src\editor\outline.lua
  ["Output (running)"] = "Salida (en ejecución)", -- src\editor\debugger.lua, src\editor\output.lua
  ["Output (suspended)"] = nil, -- src\editor\debugger.lua
  ["Output"] = "Salida", -- src\editor\debugger.lua, src\editor\output.lua, src\editor\gui.lua, src\editor\settings.lua
  ["Paste text from the clipboard"] = "Pegar texto desde el portapapeles", -- src\editor\menu_edit.lua
  ["Preferences"] = nil, -- src\editor\menu_edit.lua
  ["Prepend '!' to force local execution."] = nil, -- src\editor\shellbox.lua
  ["Prepend '=' to show complex values on multiple lines."] = "Antepón '=' para ver valores complejos en líneas múltiples", -- src\editor\shellbox.lua
  ["Press cancel to abort."] = "Presiona cancelar para abortar.", -- src\editor\commands.lua
  ["Program '%s' started in '%s' (pid: %d)."] = "Programa '%s' iniciado en '%s' (pid: %d).", -- src\editor\output.lua
  ["Program can't start because conflicting process is running as '%s'."] = "El programa no puede iniciarse porque hay un proceso conflictivo en ejecución como '%s'.", -- src\editor\output.lua
  ["Program completed in %.2f seconds (pid: %d)."] = "Programa completado en %.2f segundos (pid: %d).", -- src\editor\output.lua
  ["Program starting as '%s'."] = "Programa iniciado como '%s'.", -- src\editor\output.lua
  ["Program stopped (pid: %d)."] = "Programa parado (pid: %d).", -- src\editor\debugger.lua
  ["Program unable to run as '%s'."] = "No se puede ejecutar el programa como '%s'.", -- src\editor\output.lua
  ["Project Directory"] = nil, -- src\editor\menu_project.lua, src\editor\filetree.lua
  ["Project history"] = nil, -- src\editor\menu_file.lua
  ["Project"] = "Proyecto", -- src\editor\filetree.lua
  ["Project/&FileTree Window"] = "Ventana de proyecto/árbol de archivos", -- src\editor\menu_view.lua
  ["Provide command line parameters"] = nil, -- src\editor\menu_project.lua
  ["R/O"] = "R/O", -- src\editor\editor.lua
  ["R/W"] = "R/W", -- src\editor\editor.lua
  ["Re&place In Files"] = "Remplazar en archivos", -- src\editor\menu_search.lua
  ["Re-indent selected lines"] = nil, -- src\editor\menu_edit.lua
  ["Recent &Projects"] = nil, -- src\editor\menu_file.lua
  ["Recent Files"] = "Archivos recientes", -- src\editor\menu_file.lua
  ["Redo last edit undone"] = "Rehacer la última edición deshecha", -- src\editor\menu_edit.lua
  ["Refused a request to start a new debugging session as there is one in progress already."] = "No se pudo lanzar una nueva sesión de depuración porque ya hay una en curso.", -- src\editor\debugger.lua
  ["Regular expression"] = nil, -- src\editor\findreplace.lua
  ["Remote console"] = "Consola remota", -- src\editor\shellbox.lua
  ["Rename All Instances"] = nil, -- src\editor\editor.lua
  ["Replace all"] = nil, -- src\editor\findreplace.lua
  ["Replace All Selections"] = nil, -- src\editor\editor.lua
  ["Replace"] = nil, -- src\editor\findreplace.lua
  ["Replaced an invalid UTF8 character with %s."] = nil, -- src\editor\commands.lua
  ["Replaced"] = nil, -- src\editor\findreplace.lua
  ["Replacing"] = nil, -- src\editor\findreplace.lua
  ["Reset to default layout"] = "Restablecer el diseño por defecto", -- src\editor\menu_view.lua
  ["Run As Scratchpad"] = "Ejecutar como borrador", -- src\editor\menu_project.lua
  ["Run as Scratchpad"] = "Ejecutar como borrador", -- src\editor\menu_project.lua
  ["S&top Debugging"] = "Parar depuración", -- src\editor\menu_project.lua
  ["S&top Process"] = "Parar proceso", -- src\editor\menu_project.lua
  ["Save &As..."] = "Guardar como...", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["Save A&ll"] = "Guardar todo", -- src\editor\menu_file.lua
  ["Save Changes?"] = "¿Guardar cambios?", -- src\editor\commands.lua
  ["Save all open documents"] = "Guardar todos los documentos abiertos", -- src\editor\menu_file.lua
  ["Save file as"] = "Guardar archivo como", -- src\editor\commands.lua
  ["Save file?"] = "¿Guardar archivo?", -- src\editor\commands.lua
  ["Save the current document to a file with a new name"] = "Guardar el documento actual en un archivo con un nombre nuevo", -- src\editor\menu_file.lua
  ["Save the current document"] = "Guardar el documento actual", -- src\editor\menu_file.lua
  ["Saved auto-recover at %s."] = "Guardar autorrecuperación en %s.", -- src\editor\commands.lua
  ["Scope"] = nil, -- src\editor\findreplace.lua
  ["Scratchpad error"] = "Error en el borrador", -- src\editor\debugger.lua
  ["Searching for"] = nil, -- src\editor\findreplace.lua
  ["Sel: %d/%d"] = nil, -- src\editor\editor.lua
  ["Select &All"] = "Seleccionar todo", -- src\editor\gui.lua, src\editor\editor.lua, src\editor\menu_edit.lua
  ["Select all text in the editor"] = "Seleccionar todo el texto en el editor", -- src\editor\menu_edit.lua
  ["Select And Find Next"] = nil, -- src\editor\menu_search.lua
  ["Select And Find Previous"] = nil, -- src\editor\menu_search.lua
  ["Select the word under cursor and find its next occurrence"] = nil, -- src\editor\menu_search.lua
  ["Select the word under cursor and find its previous occurrence"] = nil, -- src\editor\menu_search.lua
  ["Set From Current File"] = nil, -- src\editor\menu_project.lua
  ["Set project directory from current file"] = "Establecer el directorio del proyecto del archivo actual", -- src\editor\menu_project.lua
  ["Set the interpreter to be used"] = "Establecer el intérprete a ser usado", -- src\editor\menu_project.lua
  ["Set the project directory to be used"] = nil, -- src\editor\menu_project.lua, src\editor\filetree.lua
  ["Settings: System"] = nil, -- src\editor\menu_edit.lua
  ["Settings: User"] = nil, -- src\editor\menu_edit.lua
  ["Show &Tooltip"] = "Ver tooltip", -- src\editor\menu_edit.lua
  ["Show All Files"] = nil, -- src\editor\filetree.lua
  ["Show Hidden Files"] = nil, -- src\editor\filetree.lua
  ["Show Location"] = nil, -- src\editor\gui.lua, src\editor\filetree.lua
  ["Show all files"] = nil, -- src\editor\filetree.lua
  ["Show files previously hidden"] = nil, -- src\editor\filetree.lua
  ["Show tooltip for current position; place cursor after opening bracket of function"] = "Ver tooltip para la posición actual; posicionar el cursor después de abrir el paréntisis de los argumentos de la función", -- src\editor\menu_edit.lua
  ["Show/Hide the status bar"] = nil, -- src\editor\menu_view.lua
  ["Show/Hide the toolbar"] = nil, -- src\editor\menu_view.lua
  ["Sort selected lines"] = "Clasificar las líneas seleccionadas", -- src\editor\menu_edit.lua
  ["Source"] = nil, -- src\editor\menu_edit.lua
  ["Stack"] = nil, -- src\editor\debugger.lua
  ["Start &Debugging"] = "Comenzar depuración", -- src\editor\menu_project.lua
  ["Start or continue debugging"] = nil, -- src\editor\menu_project.lua
  ["Step &Into"] = "Paso dentro", -- src\editor\menu_project.lua
  ["Step &Over"] = "Paso sin entrar", -- src\editor\menu_project.lua
  ["Step O&ut"] = "Paso fuera", -- src\editor\menu_project.lua
  ["Step into"] = "Paso dentro", -- src\editor\menu_project.lua
  ["Step out of the current function"] = "Hasta salir de la función actual", -- src\editor\menu_project.lua
  ["Step over"] = "Paso sin entrar", -- src\editor\menu_project.lua
  ["Stop debugging and continue running the process"] = nil, -- src\editor\menu_project.lua
  ["Stop the currently running process"] = "Parar el proceso en ejecución", -- src\editor\menu_project.lua
  ["Switch to or from full screen mode"] = "Conmutar el modo de pantalla completa", -- src\editor\menu_view.lua
  ["Text not found."] = nil, -- src\editor\findreplace.lua
  ["The API file must be located in a subdirectory of the API directory."] = "El archivo de API debe ser almacenado en un subdirectorio del directorio de API.", -- src\editor\autocomplete.lua
  ["Toggle Bookmark"] = nil, -- src\editor\menu_edit.lua
  ["Toggle Break&point"] = "Conmutar punto de ruptura", -- src\editor\menu_project.lua
  ["Toggle bookmark"] = nil, -- src\editor\menu_edit.lua
  ["Toggle breakpoint"] = "Conmutar punto de ruptura", -- src\editor\menu_project.lua
  ["Tr&ace"] = "Traza", -- src\editor\menu_project.lua
  ["Trace execution showing each executed line"] = "Traza de ejecución mostrando cada línea ejecutada", -- src\editor\menu_project.lua
  ["Unable to create directory '%s'."] = nil, -- src\editor\filetree.lua
  ["Unable to create file '%s'."] = nil, -- src\editor\filetree.lua
  ["Unable to delete directory '%s': %s"] = nil, -- src\editor\filetree.lua
  ["Unable to load file '%s'."] = "No se pudo cargar el archivo '%s'.", -- src\editor\commands.lua
  ["Unable to rename file '%s'."] = nil, -- src\editor\filetree.lua
  ["Unable to save file '%s': %s"] = "No se pudo guardar el archivo '%s': %s", -- src\editor\commands.lua
  ["Unable to stop program (pid: %d), code %d."] = "No se puedo parar el programa (pid: %d), código %d.", -- src\editor\debugger.lua
  ["Undo last edit"] = "Deshacer la última edición", -- src\editor\menu_edit.lua
  ["Use '%s' to see full description."] = nil, -- src\editor\editor.lua
  ["Use '%s' to show line endings and '%s' to convert them."] = nil, -- src\editor\commands.lua
  ["Use 'clear' to clear the shell output and the history."] = "Usa 'clear' para limpiar la consola de salida y el historial.", -- src\editor\shellbox.lua
  ["Use Shift-Enter for multiline code."] = "Usa <Shift-Enter> para código multilínea.", -- src\editor\shellbox.lua
  ["View the outline window"] = nil, -- src\editor\menu_view.lua
  ["View the output/console window"] = "Ver ventana de salida/consola", -- src\editor\menu_view.lua
  ["View the project/filetree window"] = "Ver la ventana de proyecto/árbol de archivos", -- src\editor\menu_view.lua
  ["View the stack window"] = "Ver la ventana de la pila de ejecución", -- src\editor\menu_view.lua
  ["View the watch window"] = "Ver la ventana de observación", -- src\editor\menu_view.lua
  ["Watch"] = nil, -- src\editor\debugger.lua
  ["Welcome to the interactive Lua interpreter."] = "Bienvenido al intérprete interactico de Lua.", -- src\editor\shellbox.lua
  ["Wrap around"] = nil, -- src\editor\findreplace.lua
  ["You must save the program first."] = "Debes guardar el programa primero", -- src\editor\commands.lua
  ["Zoom In"] = nil, -- src\editor\menu_view.lua
  ["Zoom Out"] = nil, -- src\editor\menu_view.lua
  ["Zoom to 100%"] = nil, -- src\editor\menu_view.lua
  ["Zoom"] = nil, -- src\editor\menu_view.lua
  ["on line %d"] = "en la línea %d", -- src\editor\debugger.lua, src\editor\editor.lua, src\editor\commands.lua
  ["traced %d instruction"] = {"%d instrucción trazada", "%d instrucciones trazadas"}, -- src\editor\debugger.lua
  ["unknown error"] = nil, -- src\editor\debugger.lua
}
