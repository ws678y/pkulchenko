return {
  [0] = function(c) return c == 1 and 1 or 2 end, -- plural
  ["%d instance"] = {"%d occorrenza", "%d occorrenze"}, -- src\editor\findreplace.lua
  ["%s event failed: %s"] = "L'evento %s è fallito : %s", -- src\editor\package.lua
  ["&About"] = "Informazioni", -- src\editor\menu_help.lua
  ["&Add Watch"] = "&Aggiungi Espressione di Controllo", -- src\editor\debugger.lua
  ["&Break"] = "Interrompi", -- src\editor\menu_project.lua
  ["&Close Page"] = "&Chiudi pagina", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["&Community"] = "&Comunità", -- src\editor\menu_help.lua
  ["&Compile"] = "&Compila", -- src\editor\menu_project.lua
  ["&Copy"] = "&Copia", -- src\editor\menu_edit.lua, src\editor\editor.lua
  ["&Default Layout"] = "Visualizzazione di &Default", -- src\editor\menu_view.lua
  ["&Delete Watch"] = "Elimina Espressione di Controllo", -- src\editor\debugger.lua
  ["&Delete"] = "Elimina", -- src\editor\filetree.lua
  ["&Documentation"] = "Documentazione", -- src\editor\menu_help.lua
  ["&Down"] = "Verso il basso", -- src\editor\findreplace.lua
  ["&Edit Watch"] = "Modifica Espressione di Controllo", -- src\editor\debugger.lua
  ["&Edit"] = "Modifica", -- src\editor\menu_edit.lua
  ["&File"] = "File", -- src\editor\menu_file.lua
  ["&Find All"] = "Trova Tutti", -- src\editor\findreplace.lua
  ["&Find Next"] = "Trova Successivo", -- src\editor\findreplace.lua
  ["&Find"] = "Ricerca", -- src\editor\menu_search.lua
  ["&Fold/Unfold All"] = "Apri/Chiudi tutto", -- src\editor\menu_edit.lua
  ["&Frequently Asked Questions"] = "Domande &Frequenti", -- src\editor\menu_help.lua
  ["&Getting Started Guide"] = "&Guida Introduttiva", -- src\editor\menu_help.lua
  ["&Goto Line"] = "Vai a riga", -- src\editor\menu_search.lua
  ["&Help"] = "Aiuto", -- src\editor\menu_help.lua
  ["&New Directory"] = "&Nuova Directory", -- src\editor\filetree.lua
  ["&New"] = "&Nuovo", -- src\editor\menu_file.lua
  ["&Open..."] = "&Apri...", -- src\editor\menu_file.lua
  ["&Output/Console Window"] = "Finestra di Output/Console", -- src\editor\menu_view.lua
  ["&Paste"] = "Incolla", -- src\editor\menu_edit.lua, src\editor\editor.lua
  ["&Project Page"] = "&Pagina di Progetto", -- src\editor\menu_help.lua
  ["&Project"] = "&Progetto", -- src\editor\inspect.lua, src\editor\menu_project.lua
  ["&Redo"] = "&Ripeti", -- src\editor\menu_edit.lua, src\editor\editor.lua
  ["&Rename"] = "&Rinomina", -- src\editor\filetree.lua
  ["&Replace All"] = "Sostituisci Tutti", -- src\editor\findreplace.lua
  ["&Replace"] = "Sostituisci", -- src\editor\findreplace.lua, src\editor\menu_search.lua
  ["&Run"] = "Lancia", -- src\editor\menu_project.lua
  ["&Save"] = "&Salva", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["&Search"] = "Ricerca", -- src\editor\menu_search.lua
  ["&Sort"] = "Ordina", -- src\editor\menu_edit.lua
  ["&Stack Window"] = "Stack di chiamate", -- src\editor\menu_view.lua
  ["&Start Debugger Server"] = "Avvia Debugger Server", -- src\editor\menu_project.lua
  ["&Subdirectories"] = "Sotto Directory", -- src\editor\findreplace.lua
  ["&Tutorials"] = "Guide", -- src\editor\menu_help.lua
  ["&Undo"] = "Annulla", -- src\editor\menu_edit.lua, src\editor\editor.lua
  ["&Up"] = "Verso l'alto", -- src\editor\findreplace.lua
  ["&View"] = "Visualizza", -- src\editor\menu_view.lua
  ["&Watch Window"] = "Finestra Espressioni di Controllo", -- src\editor\menu_view.lua
  [".&bak on Replace"] = ".bak su Sostituisci", -- src\editor\findreplace.lua
  ["About %s"] = "Informazioni su %s", -- src\editor\menu_help.lua
  ["Add To Scratchpad"] = "Aggiungi a Scratchpad ", -- src\editor\editor.lua
  ["Add Watch Expression"] = "Aggiungi Espressione di Controllo", -- src\editor\editor.lua
  ["All files"] = "Tutti i files", -- src\editor\commands.lua
  ["Allow external process to start debugging"] = "Permetti a processi esterni di avviare il debug", -- src\editor\menu_project.lua
  ["Analyze the source code"] = "Analizza il codice", -- src\editor\inspect.lua
  ["Analyze"] = "Analizza", -- src\editor\inspect.lua
  ["Auto Complete Identifiers"] = "Autocompletamento identificatori", -- src\editor\menu_edit.lua
  ["Auto complete while typing"] = "Autocompletamento in linea", -- src\editor\menu_edit.lua
  ["Break execution at the next executed line of code"] = "Interrompi l'esecuzione alla successiva riga di codice ", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["C&lear Output Window"] = "Pulisci finestra di output", -- src\editor\menu_project.lua
  ["C&omment/Uncomment"] = "Commenta/Scommenta", -- src\editor\menu_edit.lua
  ["Can't debug the script in the active editor window."] = "Impossibile farte debug dello script nella finestra attiva", -- src\editor\debugger.lua
  ["Can't find file '%s' in the current project to activate for debugging. Update the project or open the file in the editor before debugging."] = "File '%s' non trovato nel progetto per attivare il debug. Modificare il progetto o apire il file prima di lanciare il debug.", -- src\editor\debugger.lua
  ["Can't process auto-recovery record; invalid format: %s."] = "Impossibile procedere all'auto-recovery; Formato non valido: %s.", -- src\editor\commands.lua
  ["Can't run the entry point script ('%s')."] = "Impossibile eseguire il punto di ingresos dello script (%s).", -- src\editor\debugger.lua
  ["Can't start debugger server at %s:%d: %s."] = "Impossibile lanciare il server debugger a %s:%d: %s.", -- src\editor\debugger.lua
  ["Can't start debugging session due to internal error '%s'."] = "Impossibile lanciare la sessione di debug: errore interno '%s'.'", -- src\editor\debugger.lua
  ["Can't start debugging without an opened file or with the current file not being saved ('%s')."] = "Impossibile lanciare il debug senza aver aperto un file o se il file corrente non è stato salvato ('%s').", -- src\editor\debugger.lua
  ["Cancel"] = "Annulla", -- src\editor\findreplace.lua
  ["Cancelled by the user."] = "Annullato dall'utente", -- src\editor\findreplace.lua
  ["Choose..."] = "Scegli...", -- src\editor\menu_project.lua
  ["Choose a project directory"] = "Scegli la directory di un progetto", -- src\editor\findreplace.lua, src\editor\menu_project.lua
  ["Clear &Dynamic Words"] = "Elimina le &Dynamic Words", -- src\editor\menu_edit.lua
  ["Clear the output window before compiling or debugging"] = "Pulisci la finestra di output prima di compilare o lanciare debug", -- src\editor\menu_project.lua
  ["Close &Other Pages"] = "Chidi le Altre Pagine", -- src\editor\gui.lua
  ["Close A&ll Pages"] = "Chiudi Tutte le Pagine", -- src\editor\gui.lua
  ["Close the current editor window"] = "Chiude la finestra dell'edit corrente", -- src\editor\menu_file.lua
  ["Co&ntinue"] = "Co&ntinua", -- src\editor\menu_project.lua
  ["Col: %d"] = "Col: %d", -- src\editor\editor.lua
  ["Command Line Parameters..."] = "Parametri Riga di Comando...", -- src\editor\menu_project.lua
  ["Command line parameters"] = "Parametri Riga di Comando", -- src\editor\menu_project.lua
  ["Comment or uncomment current or selected lines"] = "Commenta o scommenta la linea corrente o selezionat", -- src\editor\menu_edit.lua
  ["Compilation error"] = "Errore di compilazione", -- src\editor\commands.lua, src\editor\debugger.lua
  ["Compilation successful; %.0f%% success rate (%d/%d)."] = "Compilazione riuscita; tasso di successo : %.0f%% (%d/%d).", -- src\editor\commands.lua
  ["Compile the current file"] = "Compila il file corrente", -- src\editor\menu_project.lua
  ["Complete &Identifier"] = "Completa l'&Identificatore", -- src\editor\menu_edit.lua
  ["Complete the current identifier"] = "Completa l'identificatore corrente", -- src\editor\menu_edit.lua
  ["Consider removing backslash from escape sequence '%s'."] = "Prova a rimuovere i backslash dalla sequenza di escape '%s'.", -- src\editor\commands.lua
  ["Copy Full Path"] = "Copia Path Completo", -- src\editor\filetree.lua
  ["Copy selected text to clipboard"] = "Copia il testo selezionato negli appunti", -- src\editor\menu_edit.lua
  ["Couldn't activate file '%s' for debugging; continuing without it."] = "Impossibile attivare il file '%s' per debug; si prosegue senza.", -- src\editor\debugger.lua
  ["Create an empty document"] = "Crea un documento vuoto", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["Cu&t"] = "&Taglia", -- src\editor\menu_edit.lua, src\editor\editor.lua
  ["Cut selected text to clipboard"] = "Taglia il testo selezionato e mette negli appunti", -- src\editor\menu_edit.lua
  ["Debugger server started at %s:%d."] = "Server Debugger iniziato %s:%s", -- src\editor\debugger.lua
  ["Debugging session completed (%s)."] = "Sessione di debug completata (%s).", -- src\editor\debugger.lua
  ["Debugging session started in '%s'."] = "Sessione di debug iniziata da '%s'.", -- src\editor\debugger.lua
  ["Debugging suspended at %s:%s (couldn't activate the file)."] = "Debug sospeso a %s:%s (impossibile attivare il file).", -- src\editor\debugger.lua
  ["Directory"] = "Directory", -- src\editor\findreplace.lua
  ["Do you want to delete '%s'?"] = "Vuoi eliminare '%s'?", -- src\editor\filetree.lua
  ["Do you want to overwrite it?"] = "Vuoi sovrascrivere '%s'?", -- src\editor\commands.lua
  ["Do you want to reload it?"] = "Vuoi ricaricarlo?", -- src\editor\editor.lua
  ["Do you want to save the changes to '%s'?"] = "Vuoi salvare le modifiche a '%s'?", -- src\editor\commands.lua
  ["E&xit"] = "Uscita", -- src\editor\menu_file.lua
  ["Enter Lua code and press Enter to run it."] = "Inserisci codice Lua e premi <Enter> per eseguirlo.", -- src\editor\shellbox.lua
  ["Enter command line parameters (use Cancel to clear)"] = "Inserisci i parametri riga di comando (Annulla per pulire)", -- src\editor\menu_project.lua
  ["Enter line number"] = "Inserisci il numero di linea", -- src\editor\menu_search.lua
  ["Error while loading API file: %s"] = "Errore durante il caricamento del file API: %s", -- src\editor\autocomplete.lua
  ["Error while loading configuration file: %s"] = "Errore nel caricamento del file di configurazione: %s", -- src\editor\style.lua
  ["Error while processing API file: %s"] = "Errore durante l'elaborazione del file API: %s", -- src\editor\autocomplete.lua
  ["Error while processing configuration file: %s"] = "Errore durante l'elaborazione del file di configurazione: %s", -- src\editor\style.lua
  ["Error"] = "Errore", -- src\editor\commands.lua
  ["Evaluate In Console"] = "Elabora in console", -- src\editor\editor.lua
  ["Execute the current project/file and keep updating the code to see immediate results"] = "Esegue il progetto/file corrente e permette di modificare il codice per vedere i risultati in tempo reale", -- src\editor\menu_project.lua
  ["Execute the current project/file"] = "Esegue il progetto/file corrente", -- src\editor\menu_project.lua
  ["Execution error"] = "Errore di esecuzione", -- src\editor\debugger.lua
  ["Exit program"] = "Uscita dal programma", -- src\editor\menu_file.lua
  ["Expr"] = "Expr.", -- src\editor\debugger.lua
  ["Expression"] = "Espressione", -- src\editor\debugger.lua
  ["File '%s' has been modified on disk."] = "Il file '%s' e' stato modificato sul disco.", -- src\editor\editor.lua
  ["File '%s' has more recent timestamp than restored '%s'; please review before saving."] = "Il file '%s' ha un timestamp più recente di quello ripristinato '%s'; verificare prima di salvare.", -- src\editor\commands.lua
  ["File '%s' no longer exists."] = "Il file '%s' non esiste piu'.", -- src\editor\menu_file.lua, src\editor\editor.lua
  ["File Type"] = "File Type", -- src\editor\findreplace.lua
  ["File already exists."] = "Il file esiste già.", -- src\editor\commands.lua
  ["File history"] = "Storia del file", -- src\editor\menu_file.lua
  ["Find &In Files"] = "Ricerca nei files", -- src\editor\menu_search.lua
  ["Find &Next"] = "Cerca il successivo", -- src\editor\menu_search.lua
  ["Find &Previous"] = "Cerca il precedente", -- src\editor\menu_search.lua
  ["Find In Files"] = "Ricerca nei Files", -- src\editor\findreplace.lua
  ["Find and replace text in files"] = "Cerca e sostituisci testo nei files", -- src\editor\menu_search.lua
  ["Find and replace text"] = "Cerca e sostituisci testo", -- src\editor\gui.lua, src\editor\menu_search.lua
  ["Find text in files"] = "Cerca testo nei files", -- src\editor\menu_search.lua
  ["Find text"] = "Cerca testo", -- src\editor\gui.lua, src\editor\menu_search.lua
  ["Find the earlier text occurence"] = "Cerca la precedente occorrenza nel testo", -- src\editor\menu_search.lua
  ["Find the next text occurrence"] = "Cerca la successiva occorrenza nel testo", -- src\editor\menu_search.lua
  ["Find"] = "Ricerca", -- src\editor\findreplace.lua
  ["Fold or unfold all code folds"] = "Apri o chiudi tutti i blocchi di codice", -- src\editor\menu_edit.lua
  ["Found auto-recovery record and restored saved session."] = "Trovato punto di auto-revcovery e ripristinata la sessione salvata", -- src\editor\commands.lua
  ["Found"] = "Occorrenze trovate:", -- src\editor\findreplace.lua
  ["Full &Screen"] = "Schermo intero", -- src\editor\menu_view.lua
  ["Go To Definition"] = "Vai a Definizione", -- src\editor\editor.lua
  ["Go to a selected line"] = "Vai alla riga selezionata", -- src\editor\menu_search.lua
  ["Goto Line"] = "Vai alla riga", -- src\editor\menu_search.lua
  ["INS"] = "INS", -- src\editor\editor.lua
  ["In Files"] = "Nei Files", -- src\editor\findreplace.lua
  ["Jump to a function definition..."] = "Salta alla definizione della funzione...", -- src\editor\editor.lua
  ["Known Files"] = "Files conosciuti", -- src\editor\commands.lua
  ["Ln: %d"] = "Ln: %d", -- src\editor\editor.lua
  ["Local console"] = "Console locale", -- src\editor\gui.lua, src\editor\shellbox.lua
  ["Lua &Interpreter"] = "&Interprete Lua", -- src\editor\menu_project.lua
  ["Mapped remote request for '%s' to '%s'."] = "Richiesta remota '%s' mappata su '%s'.", -- src\editor\debugger.lua
  ["Match &case"] = "Maiuscole/Minuscole", -- src\editor\findreplace.lua
  ["Match &whole word"] = "Intera parola", -- src\editor\findreplace.lua
  ["Mixed end-of-line encodings detected."] = "Trovata codifica Fine-Riga mista.", -- src\editor\commands.lua
  ["New &File"] = "Nuovo &File", -- src\editor\filetree.lua
  ["OVR"] = "OVR", -- src\editor\editor.lua
  ["Open With Default Program"] = "Apri con programma predefinito", -- src\editor\filetree.lua
  ["Open an existing document"] = "Apri un documento esistente", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["Open file"] = "Apri un file", -- src\editor\commands.lua
  ["Options"] = "Opzioni", -- src\editor\findreplace.lua
  ["Output (running)"] = "Output (in corso d'esecuzione)", -- src\editor\output.lua
  ["Output"] = "Output", -- src\editor\gui.lua, src\editor\output.lua, src\editor\settings.lua
  ["Paste text from the clipboard"] = "Incolla testo dagli appunti", -- src\editor\menu_edit.lua
  ["Preferences"] = "Preferenze", -- src\editor\menu_edit.lua
  ["Prepend '=' to show complex values on multiple lines."] = "Prefissa '=' per visualizzare valori complessi su piu` righe", -- src\editor\shellbox.lua
  ["Press cancel to abort."] = "Premi cancel per bloccare.", -- src\editor\commands.lua
  ["Program '%s' started in '%s' (pid: %d)."] = "Programma '%s' partito da '%s' (pid: %d).", -- src\editor\output.lua
  ["Program can't start because conflicting process is running as '%s'."] = "Il programma non puo' partire perchè in conflitto con il processo in esecuzione '%s'.", -- src\editor\output.lua
  ["Program completed in %.2f seconds (pid: %d)."] = "Programma completato in %.2f secondi (pid: %d).", -- src\editor\output.lua
  ["Program starting as '%s'."] = "Programma partito da '%s'.", -- src\editor\output.lua
  ["Program stopped (pid: %d)."] = "Programma fermato (pid: %d).", -- src\editor\debugger.lua
  ["Program unable to run as '%s'."] = "Il programma non puo' partire '%s'.", -- src\editor\output.lua
  ["Project Directory"] = "Directory del Progetto", -- src\editor\menu_project.lua
  ["Project"] = "Progetto", -- src\editor\gui.lua, src\editor\settings.lua
  ["Project/&FileTree Window"] = "Progetto/Explorer", -- src\editor\menu_view.lua
  ["Provide command line parameters"] = "Fornire parametri riga di comando", -- src\editor\menu_project.lua
  ["R/O"] = "R/O", -- src\editor\editor.lua
  ["R/W"] = "R/W", -- src\editor\editor.lua
  ["Re&place In Files"] = "Sostituisci nei files", -- src\editor\menu_search.lua
  ["Recent Files"] = "Files recenti", -- src\editor\menu_file.lua
  ["Redo last edit undone"] = "Ripeti l'ultima azione annullata", -- src\editor\menu_edit.lua
  ["Refused a request to start a new debugging session as there is one in progress already."] = "Impossibile aprire una nuova sessione di debug in quanto ne esiste una in corso", -- src\editor\debugger.lua
  ["Regular &expression"] = "Regular &expression", -- src\editor\findreplace.lua
  ["Remote console"] = "Console remota", -- src\editor\shellbox.lua
  ["Rename All Instances"] = "Rinomina tutte le occorrenze", -- src\editor\editor.lua
  ["Replace A&ll"] = "Sostituisci Tutto", -- src\editor\findreplace.lua
  ["Replace"] = "Sostituisci", -- src\editor\findreplace.lua
  ["Replaced an invalid UTF8 character with %s."] = "Sostituito un carattere UTF8 invalido con %s.", -- src\editor\commands.lua
  ["Replaced"] = "Sostituiti :", -- src\editor\findreplace.lua
  ["Replacing"] = "Sostituzione", -- src\editor\findreplace.lua
  ["Reset to default layout"] = "Ritorna al default layout", -- src\editor\menu_view.lua
  ["Resets the dynamic word list for autocompletion"] = "Azzera la lista di dynamic words per l'autocompletamento", -- src\editor\menu_edit.lua
  ["Run as Scratchpad"] = "Esegui in Scratchpad (Live coding)", -- src\editor\menu_project.lua
  ["S&top Debugging"] = "Ferma il debugger", -- src\editor\menu_project.lua
  ["S&top Process"] = "Ferma il processo", -- src\editor\menu_project.lua
  ["Save &As..."] = "S&alva con nome...", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["Save A&ll"] = "Sa&lva tutto", -- src\editor\menu_file.lua
  ["Save Changes?"] = "Vuoi salvare le modifiche?", -- src\editor\commands.lua
  ["Save all open documents"] = "Salva tutti i documenti aperti", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["Save file as"] = "Salva il file con nome", -- src\editor\commands.lua
  ["Save file?"] = "Vuoi salvare il file?", -- src\editor\commands.lua
  ["Save the current document to a file with a new name"] = "Salva il documento corrente in un file con un nuovo nome", -- src\editor\menu_file.lua
  ["Save the current document"] = "Salva il documento corrente", -- src\editor\gui.lua, src\editor\menu_file.lua
  ["Saved auto-recover at %s."] = "Salvato auto-recover a %s.", -- src\editor\commands.lua
  ["Scope"] = "Direzione", -- src\editor\findreplace.lua
  ["Scratchpad error"] = "Errore durente Scratchpad", -- src\editor\debugger.lua
  ["Searching for"] = "Ricerca di", -- src\editor\findreplace.lua
  ["Select &All"] = "Selezion&a Tutto", -- src\editor\menu_edit.lua, src\editor\editor.lua
  ["Select all text in the editor"] = "Seleziona tutto il testo nell'editor", -- src\editor\menu_edit.lua
  ["Select and Find Next"] = "Seleziona e trova successivo", -- src\editor\menu_search.lua
  ["Select and Find Previous"] = "Seleziona e trova precedente", -- src\editor\menu_search.lua
  ["Select the word under cursor and find its next occurrence"] = "Seleziona la parola e trova successivo", -- src\editor\menu_search.lua
  ["Select the word under cursor and find its previous occurrence"] = "Seleziona la parola e trova precedente", -- src\editor\menu_search.lua
  ["Set From Current File"] = "Impostato da file corrente", -- src\editor\menu_project.lua
  ["Set project directory from current file"] = "Definisci la directory del progeetto dal file corrente", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["Set the interpreter to be used"] = "Definisci l'interprete da utilizzare", -- src\editor\menu_project.lua
  ["Set the project directory to be used"] = "Imposta la directory di progetto da usare", -- src\editor\menu_project.lua
  ["Settings: System"] = "Impostazioni: Sistema", -- src\editor\menu_edit.lua
  ["Settings: User"] = "Impostazioni: Utente", -- src\editor\menu_edit.lua
  ["Show &Tooltip"] = "Mos&tra i consigli", -- src\editor\menu_edit.lua
  ["Show Location"] = "Mostra posizione", -- src\editor\gui.lua, src\editor\filetree.lua
  ["Show tooltip for current position; place cursor after opening bracket of function"] = "Mostra i consigli per la posizione corrente; muovi il cursore dopo la parentesi o la funzione", -- src\editor\menu_edit.lua
  ["Sort selected lines"] = "Ordina le righe selezionate", -- src\editor\menu_edit.lua
  ["Stack"] = "Stack", -- src\editor\debugger.lua, src\editor\gui.lua
  ["Start &Debugging"] = "Inizia il &Debug", -- src\editor\menu_project.lua
  ["Start or Continue debugging"] = "Inizia o continua il debug", -- src\editor\gui.lua
  ["Start or continue debugging"] = "Inizia o continua il debug", -- src\editor\menu_project.lua
  ["Step &Into"] = "Step &Into", -- src\editor\menu_project.lua
  ["Step &Over"] = "Step &Over", -- src\editor\menu_project.lua
  ["Step O&ut"] = "Step O&ut", -- src\editor\menu_project.lua
  ["Step into"] = "Step into", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["Step out of the current function"] = "Contina fino all'uscita della funzione", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["Step over"] = "Continua senza entrare nella funzione", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["Stop the currently running process"] = "Ferma il processo in esecuzione", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["Switch to or from full screen mode"] = "Passa da tutto schermo a finestra", -- src\editor\menu_view.lua
  ["Text not found."] = "Testo non trovato.", -- src\editor\findreplace.lua
  ["The API file must be located in a subdirectory of the API directory."] = "Il file API deve essere presente in una sottodirectory o nella direcotory API.", -- src\editor\autocomplete.lua
  ["Toggle Break&point"] = "Attiva/Disattiva Break&point", -- src\editor\menu_project.lua
  ["Toggle breakpoint"] = "Attiva/Disattiva Breakpoint", -- src\editor\gui.lua, src\editor\menu_project.lua
  ["Tr&ace"] = "Tr&ace", -- src\editor\menu_project.lua
  ["Trace execution showing each executed line"] = "Traccia l'esecuzione mostrando le righe eseguite", -- src\editor\menu_project.lua
  ["Unable to create directory '%s'."] = "Impossibile creare la directory '%s'.", -- src\editor\filetree.lua
  ["Unable to create file '%s'."] = "Impossibile creare il file '%s'.", -- src\editor\filetree.lua
  ["Unable to load file '%s'."] = "Impossibile aprire il file '%s'.", -- src\editor\commands.lua
  ["Unable to rename file '%s'."] = "Impossibile rinominare il file '%s'.", -- src\editor\filetree.lua
  ["Unable to save file '%s': %s"] = "Impossibile salvare il file '%s': %s", -- src\editor\commands.lua
  ["Unable to stop program (pid: %d), code %d."] = "Impossibile fermare il programma (pid: %d), code %d.", -- src\editor\debugger.lua
  ["Undo last edit"] = "Annulla l'ultima azione di edit", -- src\editor\menu_edit.lua
  ["Use '%s' to see full description."] = "Utilizza '%s' per vedere la descrizione completa.", -- src\editor\editor.lua
  ["Use '%s' to show line endings and '%s' to convert them."] = "Utilizza '%s' per vedere la fine della riga e '%s' per convertirli.", -- src\editor\commands.lua
  ["Use 'clear' to clear the shell output and the history."] = "Utilizza 'clear' per pulire l`output e lo storico.", -- src\editor\shellbox.lua
  ["Use Shift-Enter for multiline code."] = "Premi <Shift-Invio> per inserire piu` righe di codice.", -- src\editor\shellbox.lua
  ["Value"] = "Valore", -- src\editor\debugger.lua
  ["View the output/console window"] = "Mostra la finestra di output/console", -- src\editor\menu_view.lua
  ["View the project/filetree window"] = "Mostra la finestra di progetto/explorer", -- src\editor\menu_view.lua
  ["View the stack window"] = "Mostra la finestra dello Stack", -- src\editor\gui.lua, src\editor\menu_view.lua
  ["View the watch window"] = "Mostra la finestra delle Espressioni di Controllo", -- src\editor\gui.lua, src\editor\menu_view.lua
  ["Watch"] = "Watch", -- src\editor\debugger.lua, src\editor\gui.lua
  ["Welcome to the interactive Lua interpreter."] = "Benvenuti nell`interprete interattivo Lua.", -- src\editor\shellbox.lua
  ["Wrap ar&ound"] = "Wrap ar&ound", -- src\editor\findreplace.lua
  ["You must save the program first."] = "Devi prima salvare il programma", -- src\editor\commands.lua
  ["on line %d"] = "alla linea %d", -- src\editor\debugger.lua, src\editor\editor.lua, src\editor\commands.lua
  ["traced %d instruction"] = {"tracciata %d istruzione", "%d istruzioni tracciate"}, -- src\editor\debugger.lua
  ["unknown error"] = "errore sconosciuto", -- src\editor\debugger.lua
}
