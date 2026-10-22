<div align="center">

# 43PR Desktop for Windows

**A simple, aesthetic, lightweight tiling desktop setup for Windows, replicated and adapted from [43PR/dotfiles](https://github.com/43PR/dotfiles).**

![Windows 10 / 11](https://img.shields.io/badge/Windows-10%20%7C%2011-0078d4?style=for-the-badge&logo=windows)
![GlazeWM](https://img.shields.io/badge/GlazeWM-3.10-8b9aaf?style=for-the-badge)
![Zebar](https://img.shields.io/badge/Zebar-3.3-7289a8?style=for-the-badge)
![Starship](https://img.shields.io/badge/Starship-1.27-b05a63?style=for-the-badge)
![Flow Launcher](https://img.shields.io/badge/Flow%20Launcher-2.1-4c1?style=for-the-badge)

</div>

---

## 🌟 Panoramica

Questo progetto replica al 100% l'esperienza, l'estetica minimalista e il workflow orientato alla produttività della configurazione Linux **43PR Desktop** (originariamente basata su Hyprland e Quickshell) portandola su **Windows 10 / 11**:

- 🪟 **Tiling Window Manager (GlazeWM)**: Gestione delle finestre a piastrelle, workspace multipli, gaps personalizzati e bordi colorati.
- 🏝️ **Floating Island Status Bar (Zebar)**: Barra superiore a pillole flottanti con indicatori interattivi di workspace, titolo finestra attiva, orologio/data e sensori hardware (CPU, RAM, Rete, Batteria).
- 🔍 **App Launcher & Clipboard (Flow Launcher)**: Ricerca rapida app, file, calcoli e appunti (`Alt + D`).
- 🎨 **Motore Temi Dinamico (`theme.ps1`)**: 27 preset tematici integrati (Tokyo Night, Catppuccin Mocha/Latte, Nord, Gruvbox, Dracula, Everforest, ecc.) con ricarica a caldo e selettore wallpaper nativo Windows.
- ⚡ **Shell & Prompt (PowerShell + Starship + Fastfetch + Eza + Btop)**: Prompt Starship minimal identico a 43PR Linux, autosuggestioni Zsh con PSReadLine, icone con Eza e monitoraggio con btop.
- 🖼️ **Selettore Sfondi (`Alt + W`)**: Rotazione sfondi o selezione da finestra di dialogo.
- 🕶️ **Trasparenza Taskbar (TranslucentTB)**: Barra di Windows trasparente per un look minimale a barra singola.

---

## ⌨️ Scorciatoie da Tastiera (Keybinds)

Su Windows, il tasto `Alt` agisce come tasto principale `Super/Mod`:

| Scorciatoia | Azione | Equivalente 43PR Linux |
| :--- | :--- | :--- |
| **`Alt + D`** | **Flow Launcher (App, File, Calcoli)** | `Super + D` (Rofi) |
| **`Alt + T`** | **Terminale Trasparente (Starship)** | `Super + T` (Kitty) |
| **`Alt + Q`** | **Chiudi Finestra Attiva** | `Super + Q` |
| **`Alt + Space`** | **Alterna Finestra Flottante / Tiling** | `Super + Space` |
| **`Alt + F`** | **Alterna Schermo Intero** | `Super + F` |
| **`Alt + 1 .. 9`** | **Cambia Workspace** | `Super + 1 .. 9` |
| **`Alt + Shift + 1 .. 9`** | **Sposta Finestra nel Workspace** | `Super + Shift + 1 .. 9` |
| **`Alt + H / J / K / L`** | **Sposta il Focus (Vim keys)** | Tasti direzionali |
| **`Alt + Shift + H/J/K/L`** | **Sposta Finestra nella Direzione** | `Super + Shift + Arrows` |
| **`Alt + E`** | **Esplora Risorse (File Manager)** | `Super + E` |
| **`Alt + B`** | **Browser Web Predefinito** | `Super + B` |
| **`Alt + S`** | **Alterna Direzione Tiling (Orizzontale/Verticale)** | `Super + X` |
| **`Alt + W`** | **Prossimo Wallpaper (Cicla Sfondo)** | `Super + W` |
| **`Alt + Shift + W`** | **Scegli Wallpaper dalla Finestra di Dialogo** | `Super + W` (Picker) |
| **`Alt + Grave`** | **Menu Spegnimento / Sospensione** | `Super + Grave` (Power) |
| **`Alt + Shift + R`** | **Ricarica Configurazione GlazeWM** | `Super + Shift + W` |
| **`Alt + Shift + Q`** | **Chiudi GlazeWM** | `Super + Grave` |

---

## 🚀 Comandi Terminale Disponibili

Nel tuo terminale PowerShell sono ora attivi i comandi moderni:
- `ls` / `ll` / `tree`: Usa **Eza** con icone a colori e gerarchia cartelle.
- `top`: Apre **Btop** (monitor di sistema con grafici CPU/GPU/RAM).
- `ff`: Mostra la schermata **Fastfetch**.
- `theme.ps1 -Theme <nome>`: Cambia tema al volo tra i 27 disponibili.

---

## 🎨 Personalizzazione Temi e Wallpaper

Il comando `theme.ps1` permette di cambiare tema e sfondo in qualsiasi momento:

```powershell
# Mostra tutti i 27 temi disponibili
.\scripts\theme.ps1 -List

# Applica un tema (es. Catppuccin Mocha, Nord, Dracula, Tokyo Night)
.\scripts\theme.ps1 -Theme catppuccin-mocha

# Cicla o seleziona uno sfondo
.\scripts\wallpaper-picker.ps1          # Prossimo sfondo
.\scripts\wallpaper-picker.ps1 -Select  # Apri finestra selezione
```

---

## 📁 Struttura del Progetto

```
D:\Progetto/
├── config/
│   ├── glazewm/
│   │   └── config.yaml            # Configurazione Tiling WM e keybinds
│   ├── zebar/
│   │   ├── starter/styles.css     # Stile pillole e blur Quickshell
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
│   ├── setup-terminal-theme.ps1   # Trasparenza acrilica e palette Terminal
│   ├── wallpaper-picker.ps1       # Rotazione e selezione sfondi
│   ├── setup-spicetify.ps1        # Theming Spotify
│   └── theme.ps1                  # Motore di cambio tema e wallpaper live
├── wallpapers/                    # Galleria sfondi
├── install.ps1                    # Installer one-click
├── start-43pr.bat                 # Script avvio desktop
├── stop-43pr.bat                  # Script arresto desktop
└── README.md
```
