# 43PR Rice per Windows 10 / 11

> 🇬🇧 **Available in English:** [English Documentation](README.md)

![43PR Desktop Showcase](assets/desktop-showcase.png)

Un ambiente desktop tiling minimalista, fluido e performante per Windows, basato su **GlazeWM**, **Zebar** e utilità native **WPF / C#**.

Progettato per la massima produttività, navigazione totale da tastiera ed estetica moderna. Include 27 temi colore integrati, sincronizzazione giorno/notte circadiana, una suite completa di finestre HUD native e latenza zero senza popup o finestre nere di console.

---

## ⚡ Installazione Rapida (Unico Comando)

Apri **PowerShell** (non servono permessi di amministratore) e incolla:

```powershell
irm https://raw.githubusercontent.com/amedello/43pr-rice-windows/master/install.ps1 | iex
```

L'installer si occuperà automaticamente di:
1. Verificare e installare i prerequisiti via `winget` (GlazeWM, Zebar, Starship, Fastfetch, JetBrains Mono Nerd Font).
2. Compilare il controller nativo ad alte prestazioni (`media-ctl.exe`) sfruttando il compilatore .NET integrato di serie in Windows (`csc.exe`).
3. Distribuire le configurazioni e i widget personalizzati di GlazeWM e Zebar in `~/.glzr`.
4. Configurare Windows Terminal, i profili PowerShell per Starship, la Dark Mode globale di sistema e l'accento Tokyo Night.
5. Nascondere automaticamente le icone del desktop per un'interfaccia pulita.
6. Creare il collegamento di avvio automatico in `shell:startup` per avviare il desktop al login.

---

## 💻 Installazione Manuale (Clone Locale)

Se preferisci clonare manualmente il repository Git:

```powershell
# Clona il repository
git clone https://github.com/amedello/43pr-rice-windows.git
cd 43pr-rice-windows

# Avvia l'installer
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

---

## ✨ Funzionalità Principali

- **Gestione Finestre a Tiling**: Basato su [GlazeWM](https://github.com/glzr-io/glazewm) (flusso di lavoro in stile i3wm/bspwm nativo per Windows).
- **Barra Superiore Zebar**: Barra di stato minimalista con workspace, titolo della finestra attiva, controlli multimediali interattivi, monitoraggio CPU/RAM, stato batteria, rete e orologio.
- **27 Temi Preconfigurati**: Tokyo Night, Catppuccin (Mocha & Latte), Nord, Gruvbox, Dracula, Everforest, Kanagawa, Rose Pine, One Dark, Monokai, Matrix, Solarized e molti altri.
- **Switch Giorno / Notte Automatico**: Passa automaticamente dal tema giorno (es. Catppuccin Latte) alle 07:00 al tema notte (Tokyo Night) alle 19:00, con possibilità di forzatura manuale o pausa via <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>.
- **Zero Finestre Nere**: Tutti gli helper e i menu compilati in sottosistema Windows nativo (`winexe`) o eseguiti con `-WindowStyle Hidden`, eliminando qualsiasi sfarfallio di finestre console.
- **Suite di HUD e Finestre Native Fluent**:
  - **Cheatsheet HUD** (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>/</kbd>): Finestra di aiuto con tutte le scorciatoie da tastiera.
  - **Selettore Temi** (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>): Navigatore visivo dei 27 temi con anteprima live e gestione switch circadiano.
  - **Window Switcher** (<kbd>Alt</kbd> + <kbd>Tab</kbd> o <kbd>Alt</kbd> + <kbd>J</kbd>): Ricerca rapida e salto istantaneo tra finestre aperte.
  - **Gestore Appunti** (<kbd>Alt</kbd> + <kbd>V</kbd>): Cronologia copia/incolla con ricerca integrata.
  - **HUD Sensori Hardware** (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd>): Telemetria in tempo reale di CPU, RAM, dischi, batteria e uptime.
  - **Calcolatrice Rapida** (<kbd>Alt</kbd> + <kbd>C</kbd>): Valutatore di espressioni matematiche al volo con cronologia.
  - **Pipetta Colore (Color Picker)** (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd>): Cattura il colore di qualsiasi pixel dello schermo e copia il codice HEX.
  - **Menu Spegnimento (Power Menu)** (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd>): Blocca, sospendi, riavvia, spegni o disconnetti.

---

## 🖼️ Galleria HUD e Anteprime Visive

| Cheatsheet Scorciatoie (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>/</kbd>) | Selettore Temi (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>) |
| :---: | :---: |
| ![Cheatsheet HUD](assets/hud-cheatsheet.png) | ![Selettore Temi](assets/hud-theme-picker.png) |

| HUD Sensori Hardware (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd>) | Calcolatrice Rapida (<kbd>Alt</kbd> + <kbd>C</kbd>) |
| :---: | :---: |
| ![HUD Sensori](assets/hud-sensors.png) | ![Calcolatrice Rapida](assets/hud-calc.png) |

| Menu Spegnimento (<kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd>) |
| :---: |
| ![Menu Spegnimento](assets/hud-power-menu.png) |

---

## ⌨️ Scorciatoie da Tastiera (Hotkeys)

### Gestione Finestre e Tiling

| Scorciatoia | Azione |
| :--- | :--- |
| <kbd>Alt</kbd> + <kbd>Q</kbd> | Chiudi la finestra attiva |
| <kbd>Alt</kbd> + <kbd>F</kbd> | Attiva / disattiva Schermo Intero (Fullscreen) |
| <kbd>Alt</kbd> + <kbd>Spazio</kbd> | Alterna modalità Fluttuante / Tiling (Floating) |
| <kbd>Alt</kbd> + <kbd>S</kbd> | Alterna direzione di divisione (Orizzontale / Verticale) |
| <kbd>Alt</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Sposta il focus: Sinistra / Basso / Alto / Destra |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Sposta la finestra attiva: Sinistra / Basso / Alto / Destra |
| <kbd>Alt</kbd> + <kbd>R</kbd> | Entra in modalità ridimensionamento (<kbd>Esc</kbd> per uscire) |

### Spazi di Lavoro (Workspaces)

| Scorciatoia | Azione |
| :--- | :--- |
| <kbd>Alt</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Passa allo Spazio di Lavoro 1 .. 9 |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Sposta la finestra attiva nello Spazio di Lavoro 1 .. 9 |

### Strumenti e Applicazioni

| Scorciatoia | Azione |
| :--- | :--- |
| <kbd>Alt</kbd> + <kbd>T</kbd> | Apri Windows Terminal |
| <kbd>Alt</kbd> + <kbd>U</kbd> | Terminale Quake a discesa (Scratchpad al volo) |
| <kbd>Alt</kbd> + <kbd>D</kbd> | Avvia Flow Launcher (ricerca file, app, web) |
| <kbd>Alt</kbd> + <kbd>E</kbd> | Apri Esplora Risorse |
| <kbd>Alt</kbd> + <kbd>B</kbd> | Apri il Browser Web predefinito |
| <kbd>Alt</kbd> + <kbd>V</kbd> | Apri il Gestore Cronologia Appunti |
| <kbd>Alt</kbd> + <kbd>Tab</kbd> / <kbd>Alt</kbd> + <kbd>J</kbd> | Apri il Selettore Finestre (Window Switcher) |
| <kbd>Alt</kbd> + <kbd>C</kbd> | Calcolatrice Rapida & Convertitore |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd> | Pipetta Colore pixel schermo (HEX) |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd> | HUD Sensori Hardware (CPU, RAM, Dischi) |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Strumento di Cattura Schermo |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> | Mostra / Nascondi barra delle applicazioni di Windows |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>A</kbd> | Cambia periferica di uscita audio (Cuffie / Casse) |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | Menu Spegnimento & Alimentazione (Power Menu) |

### Temi e Personalizzazione

| Scorciatoia | Azione |
| :--- | :--- |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd> | Apri il Selettore Grafico dei Temi |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | Cambia sfondo con il successivo della galleria |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd> | Apri finestra di dialogo per scegliere lo sfondo da file |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>/</kbd> | Mostra il Cheatsheet completo delle scorciatoie |

---

## 🚀 Avvio e Arresto Manuale

Puoi avviare o fermare l'ambiente in qualunque momento:

- **Avvio**: Esegui `start-43pr.bat` oppure premi <kbd>Win</kbd> + <kbd>R</kbd> e digita `glazewm`.
- **Arresto**: Esegui `stop-43pr.bat` oppure digita in PowerShell:
  ```powershell
  taskkill /IM glazewm.exe /F
  taskkill /IM zebar.exe /F
  ```

---

## 🗑️ Disinstallazione

Per rimuovere completamente 43PR Rice e ripristinare il desktop standard di Windows (icone, barra delle applicazioni, avvio predefinito):

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Per disinstallare anche i pacchetti installati via winget (GlazeWM, Zebar):

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1 -Full
```

---

## 📄 Licenza

Rilasciato sotto licenza MIT. Realizzato per offrire la migliore esperienza tiling su Windows.

