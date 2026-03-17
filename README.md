# ⚔️ Belagerungs-Atlas

Interaktiver Atlas für historische und Fantasy-Festungen — mit KI-gestützten Belagerungssimulationen, Kampagnenmodus und detaillierten Analysen.

**Live:** [belagerungs-atlas.vercel.app](https://belagerungs-atlas.vercel.app)

---

## 🏰 Features

### Burgen & Karten
- **62 Festungen** — historisch (Europa, Nahost, Asien) und Fantasy (Mittelerde, Westeros)
- **Individuelle SVG-Grundrisse** für alle Burgen mit klickbaren Verteidigungszonen
- **Leaflet-Weltkarte** mit historischen Verbindungslinien, Epoche-Filter und Zoom
- **Entfernungsrechner** — Luftlinie, Marschzeit, Kavalleriezeit zwischen beliebigen Burgen
- **Mittelerde & Westeros** — eigene Fantasy-Karte mit Terrain und Regionen

### Gameplay
- **🎭 Rollenspiel-Belagerung** — KI als Verteidiger mit 5 Persönlichkeitstypen (Fanatiker, Stratege, Pragmatiker, Ehrenmann, Feigling)
- **⚔️ Belagerungssimulator** — 14 Ressourcentypen, General- und Jahreszeitenboni
- **⚡ Helden-Spezialfähigkeiten** — jeder General hat eine einmalige Kampfaktion
- **30 Belagerungsereignisse** — Seuchen, Entsatz, Erdbeben, Verräter, Griechisches Feuer...
- **📜 Dynamische Chroniken** — atmosphärischer Belagerungsbericht nach jedem Kampf

### Kampagnenmodus
- **4 Kampagnen** mit je 5 Burgen und eigener Geschichte
  - ✝️ Der Kreuzfahrer-Pfad
  - ⬛ Der Ordo Custodum Sorrowland
  - 👑 Edwards Eiserner Ring
  - ✦ Das Dritte Zeitalter (Mittelerde)
- **Choose-your-own-Adventure** — Entscheidungsmomente mit echten Konsequenzen für den Belagerungsausgang
- **Burg erkunden** — vollständiger Grundriss-Modus vor der Belagerung

### Analyse & Vergleich
- **📊 Radar-Charts** — Dualvergleich zweier Burgen überlagert
- **🌀 Was wäre wenn?** — 7 kontrafaktische Szenarien mit personalisierten Antworten
- **🤖 KI-Berater** — historische Fragen zur aktuellen Burg
- **⚡ Direktvergleich** — animierte Balkendiagramme, Kategorien, Punktevorsprung
- **📜 Geschichte-Tab** — animierter Zeitstrahl, Stat-Balken, Angriffstaktiken

### Burg-Baumeister
- **24 Gold Budget** — über 25 Bauelemente inkl. Drachen & Magie
- **10 Synergie-Kombinationen** — Bonuseffekte bei passenden Kombinationen
- **KI-Analyse** mit lokalem Fallback (funktioniert ohne API)
- **📥 Export** — Burg-Steckbrief als HTML-Datei herunterladen

### Persistenz & Fortschritt
- **💾 localStorage** — Scores und Spielstatistiken bleiben nach Browser-Neustart
- **🏆 22 Achievements** — freigeschaltet durch Belagerungen, Kampagnen, Burgerkundung
- **Toast-Benachrichtigungen** bei Achievement-Freischaltung
- **📊 Atlas-Tab** — globale Statistiken, Top-Wertungen, Siegesbalken
- **🗡️ Turniermodus** — Burgen gegeneinander antreten lassen

### Der Ordo Custodum Sorrowland
Eigene fiktive Ordensburg-Trilogie mit vollständiger Lore:
- **⬛ Schwarzer Bergfried** (ca. 850) — spirituelles Zentrum, Archiv des Ordens
- **🏰 Castle Sorrow** (10./11. Jh.) — Hauptsitz mit Kanonen-Bastionsturm
- **⛰️ Gravecrest** (12. Jh.) — Bergfestung, Sammelpunkt, Signalfeuer-System

---

## 🚀 Schnellstart (lokal)

```bash
npm install
npm run dev
```
→ Öffnet http://localhost:3000

---

## 🌐 Deployment auf Vercel

### Option A — GitHub + Vercel Dashboard (empfohlen)
1. Repository auf GitHub pushen
2. [vercel.com/new](https://vercel.com/new) → Repository importieren
3. **Root Directory:** leer lassen
4. **Framework:** Vite (automatisch erkannt)
5. **Environment Variable:** `ANTHROPIC_KEY = sk-ant-...`
6. Deploy → fertig

### Option B — Vercel CLI
```bash
npm install -g vercel
vercel
```

---

## ⚠️ API Key Setup

Die KI-Features nutzen die Anthropic Claude API über einen serverseitigen Proxy (`api/claude.js`).

**Vercel Environment Variable:**
```
Name:  ANTHROPIC_KEY
Value: sk-ant-api03-...
```

**Wichtig:** `ANTHROPIC_KEY` (nicht `VITE_ANTHROPIC_KEY` — der Key wird serverseitig verwendet).

Ohne API Key greifen automatisch lokale Fallbacks — die App funktioniert vollständig auch offline.

---

## 🏗️ Projektstruktur

```
belagerungs-atlas/
├── src/
│   ├── App.jsx          ← Hauptkomponente (62 Burgen, alle Features)
│   └── main.jsx         ← React Entry Point
├── api/
│   └── claude.js        ← Anthropic API Proxy (Vercel Serverless)
├── public/
│   └── manifest.json    ← PWA Manifest
├── index.html
├── package.json
├── vite.config.js
└── README.md
```

---

## 📦 Build

```bash
npm run build   # Erstellt dist/ für Production
npm run preview # Lokale Preview des Production-Builds
```

---

## 🔧 Tech Stack

- **React 18** + Vite
- **Leaflet.js** — interaktive Weltkarte
- **Anthropic Claude API** — KI-Features (claude-sonnet-4-20250514)
- **Vercel** — Hosting + Serverless API Proxy
- **localStorage** — Persistenz ohne Backend

---

## 📋 Burgen-Übersicht

| Kategorie | Anzahl | Beispiele |
|-----------|--------|---------|
| Europa | 18 | Krak, Carcassonne, Dover, Malbork, Beaumaris |
| Naher Osten / Asien | 14 | Masada, Konstantinopel, Mehrangarh, Angkor |
| Mittelerde | 10 | Minas Tirith, Helms Klamm, Barad-dûr, Gondolin |
| Westeros | 5 | Winterfell, Harrenhal, Königsmund, Sturmkap |
| Sorrowland | 3 | Schwarzer Bergfried, Castle Sorrow, Gravecrest |
| Andere | 12 | Rohtas, Nimrod, Sigiriya, Great Zimbabwe... |

