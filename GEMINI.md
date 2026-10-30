# 43PR Project Core Engineering Rules & Guidelines

Queste regole sono vincolanti per qualsiasi modifica, aggiunta, script o manutenzione all'interno di questo repository. Devono essere sempre rispettate senza eccezioni.

---

## 1. Codifica Caratteri, Font e Prevenzione Mojibake
- **MAI inserire caratteri Unicode non-ASCII a 3/4 byte come testo puro nei file `.ps1` o XAML**:
  - Simboli come bullet `•`, frecce `→`, emojii o icone speciali non devono essere incollati come caratteri raw perché PowerShell 5.1 li interpreta in codepage Windows-1252, provocando artefatti grafici (es. `â€¢`, `ï€£`).
  - Nello XAML usare **sempre** le entità numeriche XML standard (es. `&#x2022;` per il pallino separatore, `&#x2192;` per la freccia).
  - Negli script PowerShell usare `[char]0x2022` o entità numeriche.
- **Nessuna dipendenza da font esterni non di sistema nelle finestre desktop**:
  - `Nerd Font` è caricato localmente solo dentro la barra Zebar (via CSS `@font-face` di WebView2). Nelle finestre WPF/PowerShell native di Windows (`power-menu`, `clipboard-manager`, `window-switcher`, `sensors-hud`), usare **esclusivamente** font nativi garantiti su qualsiasi installazione Windows 10/11:
    `FontFamily="Segoe Fluent Icons, Segoe MDL2 Assets, Segoe UI Symbol"`
  - Utilizzare i codepoint ufficiali Microsoft Segoe:
    - 🔒 Lucchetto: `&#xE72E;`
    - 🌙 Sospendi/Notte: `&#xE708;`
    - 🔄 Riavvia/Sync: `&#xE777;`
    - ⏻ Spegni/Power: `&#xE7E8;`
    - 🚪 Disconnetti/Exit: `&#xE8F8;`
    - 🔍 Cerca: `&#xE721;`
    - 📋 Clipboard: `&#xE77F;`
    - 🪟 Switcher: `&#xE737;`
    - 🧮 Calcolatrice: `&#xE8EF;`
    - 📊 Sensori/Chip: `&#xE950;`
    - ❌ Chiudi: `&#xE711;`

---

## 2. Sincronizzazione Rigorosa `.glzr` ↔ `config`
- I file di runtime reali utilizzati da GlazeWM e Zebar risiedono in:
  - `~/.glzr/glazewm/config.yaml`
  - `~/.glzr/zebar/starter/` (HTML, CSS, JSON, fonts)
  - `~/.glzr/zebar/43pr-bar/`
- I file tracciati nel repository Git risiedono in:
  - `D:\Progetto\config\glazewm\`
  - `D:\Progetto\config\zebar\`
- **Regola**: Qualsiasi modifica, bugfix o aggiornamento stilistico deve essere applicato **in entrambi i percorsi contemporaneamente** prima di effettuare qualsiasi commit e push su Git.

---

## 3. UI/UX e Progettazione delle Finestre Native WPF
- **Dimensionamento adattivo**: Non impostare altezze rigide statiche su finestre che ospitano elenchi a lunghezza variabile. Usare sempre:
  ```xml
  SizeToContent="Height" MinHeight="..." MaxHeight="..."
  ```
  in modo che la finestra sia compatta ed elegante se c'è poco contenuto, e si espanda con scrollbar quando il contenuto aumenta.
- **Placeholder ed usabilità dei campi di testo**:
  - Ogni casella di ricerca deve avere un placeholder descrittivo ben visibile quando il campo è vuoto.
  - Rimuovere il bordo tratteggiato predefinito con `FocusVisualStyle="{x:Null}"`.
- **Navigazione da tastiera garantita**:
  - <kbd>Esc</kbd> deve **sempre** chiudere la finestra senza eseguire azioni distruttive.
  - <kbd>Invio</kbd> deve confermare/eseguire l'azione selezionata.
  - Le frecce <kbd>Su</kbd> / <kbd>Giù</kbd> devono scorrere la lista anche se il focus è nella casella di ricerca.

---

## 4. Prestazioni e Zero Console Popup
- **Nessuna finestra terminale nera**:
  - Nessun comando in background o evento rapido deve aprire popup o finestre di console cmd/powershell.
  - `media-ctl.cs` deve essere compilato come applicazione Windows nativa senza console:
    `csc.exe /target:winexe /out:media-ctl.exe media-ctl.cs`
  - I lanci di PowerShell devono utilizzare `-WindowStyle Hidden -CreateNoWindow`.

---

## 5. Gestione Processi, Startup e Offline Resiliency
- In `zpack.json`, la proprietà `"zOrder"` della barra deve rimanere `"normal"` (standard ufficiale Glzr per GlazeWM): lo spazio della barra in tiling è protetto da `outer_gap.top: 46px`, consentendo al contempo a qualsiasi app a tutto schermo (video, giochi, F11) di coprire la barra in modo deterministico e senza conflitti Win32 TopMost.
- Nell'inizializzazione di avvio (`StartupZebar`):
  - Applicare il tema / aggiornamento CSS **prima** di avviare il processo grafico.
  - Pulire preventivamente eventuali istanze zombie prima dello spawn di una nuova barra per evitare il lock della porta socket `10048` o conflitti WebView2 `0x800700AA`.
  - Mantenere tutte le dipendenze essenziali locali in modo che l'ambiente funzioni al 100% anche senza connessione internet.

---

## 6. Sicurezza, Credenziali e Confini del Repository
- **Mai salvare token segreti o PAT nei file di codice o nella cronologia Git**:
  - L'autenticazione remota deve appoggiarsi al Windows Credential Manager (`git credential approve`).
- **Separazione dei repository**:
  - `D:\Progetto` traccia esclusivamente la configurazione del desktop Windows (`43pr-rice-windows`).
  - La cartella `junsun-ambient-light/` è un progetto Android separato con il suo repository Git dedicato (`amedello/junsun-ambient-light`). Non mescolare mai i file tra i due progetti.

