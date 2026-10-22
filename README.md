<div align="center">

# 43PR Desktop for Windows

**A simple, aesthetic, lightweight tiling desktop setup for Windows, replicated and adapted from [43PR/dotfiles](https://github.com/43PR/dotfiles).**

![Windows 10 / 11](https://img.shields.io/badge/Windows-10%20%7C%2011-0078d4?style=for-the-badge&logo=windows)
![GlazeWM](https://img.shields.io/badge/GlazeWM-3.10-8b9aaf?style=for-the-badge)
![Zebar](https://img.shields.io/badge/Zebar-3.3-7289a8?style=for-the-badge)
![Starship](https://img.shields.io/badge/Starship-1.27-b05a63?style=for-the-badge)

</div>

---

## 🌟 Panoramica

Questo progetto replica l'esperienza, l'estetica minimalista e il workflow orientato alla produttività della configurazione Linux **43PR Desktop** (originariamente basata su Hyprland e Quickshell) portandola su **Windows 10 / 11**:

- 🪟 **Tiling Window Manager (GlazeWM)**: Gestione delle finestre a piastrelle, workspace multipli, gaps personalizzati e bordi colorati.
- 🏝️ **Floating Island Status Bar (Zebar)**: Barra superiore a pillole flottanti con indicatori interattivi di workspace, titolo finestra attiva, orologio/data e sensori hardware (CPU, RAM, Rete, Batteria).
- 🎨 **Motore Temi Dinamico (`theme.ps1`)**: 27 preset tematici integrati (Tokyo Night, Catppuccin Mocha/Latte, Nord, Gruvbox, Dracula, Everforest, ecc.) con ricarica a caldo e selettore wallpaper nativo Windows.
- ⚡ **Shell & Prompt (PowerShell + Starship + Fastfetch)**: Prompt Starship minimal identico a 43PR Linux, autosuggestioni con PSReadLine e schermata di benvenuto Fastfetch.

---

## ⌨️ Scorciatoie da Tastiera (Keybinds)

Su Windows, il tasto `Alt` agisce come tasto principale `Super/Mod`:

| Scorciatoia | Azione | Equivalente 43PR Linux |
| :--- | :--- | :--- |
| `Alt + T` | Apri Terminale | `Super + T` |
| `Alt + Q` | Chiudi Finestra Attiva | `Super + Q` |
| `Alt + D` | Launcher Applicazioni | `Super + D` |
| `Alt + Space` | Alterna Finestra Flottante | `Super + Space` |
| `Alt + F` | Alterna Schermo Intero | `Super + F` |
| `Alt + 1 .. 9` | Cambia Workspace | `Super + 1 .. 9` |
| `Alt + Shift + 1 .. 9` | Sposta Finestra nel Workspace | `Super + Shift + 1 .. 9` |
| `Alt + H / J / K / L` | Sposta il Focus (Vim keys) | Tasti direzionali |
| `Alt + Shift + H / J / K / L` | Sposta Finestra nella Direzione | `Super + Shift + Arrows` |
| `Alt + E` | Esplora Risorse (File Manager) | `Super + E` |
| `Alt + B` | Browser Web Predefinito | `Super + B` |
| `Alt + S` | Alterna Direzione di Tiling (Orizzontale/Verticale) | `Super + X` |
| `Alt + Shift + R` | Ricarica Configurazione GlazeWM | `Super + Shift + W` |
| `Alt + Shift + Q` | Chiudi GlazeWM | `Super + Grave` |

---

## 🚀 Installazione Rapida

Apri PowerShell ed esegui l'installer unificato:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Avvio dell'Ambiente

Per avviare il window manager e la status bar:
```powershell
glazewm.exe start
```

*(Suggerimento: Puoi aggiungere un collegamento a `glazewm.exe start` nella cartella Esecuzione automatica `shell:startup` per farlo partire automaticamente all'avvio di Windows).*

---

## 🎨 Personalizzazione Temi e Wallpaper

Il comando `theme.ps1` permette di cambiare tema e sfondo in qualsiasi momento:

```powershell
# Mostra tutti i 27 temi disponibili
.\scripts\theme.ps1 -List

# Applica un tema (es. Catppuccin Mocha, Nord, Dracula, Tokyo Night)
.\scripts\theme.ps1 -Theme catppuccin-mocha

# Imposta uno sfondo personalizzato
.\scripts\theme.ps1 -Wallpaper .\wallpapers\wallhaven-k8jvm7.jpg
```

---

## 📁 Struttura del Progetto

```
D:\Progetto/
├── config/
│   ├── glazewm/
│   │   └── config.yaml            # Configurazione Tiling WM e keybinds
│   ├── zebar/
│   │   ├── 43pr-bar/              # Widget pack Quickshell per Zebar
│   │   │   ├── index.html
│   │   │   ├── style.css
│   │   │   └── zpack.json
│   │   └── settings.json
│   ├── 43pr/
│   │   └── themes/*.toml          # 27 palette colori sincronizzate
│   ├── fastfetch/
│   │   └── config.jsonc           # Layout hardware/software Fastfetch
│   ├── powershell/
│   │   └── Microsoft.PowerShell_profile.ps1
│   └── starship.toml              # Configurazione Starship prompt
├── scripts/
│   ├── setup-glzr.ps1             # Symlink e sync per GlazeWM e Zebar
│   ├── setup-terminal.ps1         # Configurazione prompt, fastfetch e shell
│   └── theme.ps1                  # Motore di cambio tema e wallpaper live
├── wallpapers/
│   └── wallhaven-k8jvm7.jpg       # Sfondo ufficiale 43PR
├── install.ps1                    # Installer one-click
└── README.md
```
