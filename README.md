# ⚔️ Belagerungs-Atlas

Interaktiver Atlas für historische und Fantasy-Festungen — mit KI-gestützten Belagerungssimulationen, Kampagnenmodus, detaillierten Grundrissen und weltweiter Kartierung.

**Live:** [belagerungs-atlas.vercel.app](https://belagerungs-atlas.vercel.app)

---

## 🏰 Features

### Burgen & Karten
- **85 Festungen** — historisch (Europa, Nahost, Asien, Amerika, Afrika) und Fantasy (Mittelerde, Westeros, Sorrowland)
- **Querformat-Übersichtskarten** mit Stat-Balken, Score-Ring, Typ-Badge
- **Karten-Tab** mit zwei Unter-Tabs:
  - **Grundriss** — zoombare SVG-Karte (0.8×–2.5×), klickbare Zonen mit Verteidigungswert-Balken, Angriffsmodus
  - **Historische Lage** — Mini-Leaflet-Karte zentriert auf Burg, Terrain-Beschreibung, Lagebewertung, benachbarte Festungen
- **Leaflet-Weltkarte** mit Epochen-Filter, Verbindungslinien, Zoom/Pan
- **Entfernungsrechner** — Luftlinie, Marschzeit, Kavalleriezeit
- **Sorrowland-Minikarte** — eigene Karte der 3 Ordensburgen mit Signalfeuer-Linien
- **Mittelerde & Westeros** — Fantasy-Karte mit Terrain

### Gameplay
- **🎭 Rollenspiel-Belagerung** — KI als Verteidiger (5 Persönlichkeitstypen), ⚡ Helden-Spezialfähigkeiten pro General
- **⚔️ Belagerungssimulator** — 14 Ressourcentypen, General- und Jahreszeitenboni
- **⛅ Wetter-System** — 7 Typen mit Kampf-Modifikatoren
- **50 Belagerungsereignisse** — Seuchen, Erdbeben, Verräter, Griechisches Feuer...
- **📜 Dynamische Chroniken** nach jeder Belagerung

### Kampagnenmodus
- **5 Kampagnen** mit je 3–5 Burgen und eigener Geschichte
  - ✝️ Der Kreuzfahrer-Pfad
  - ⬛ Chroniken von Sorrowland (Legendär)
  - 👑 Edwards Eiserner Ring
  - ✦ Das Dritte Zeitalter (Mittelerde)
  - 🌙 Die Mongolische Welle
- **Choose-your-own-Adventure** — Entscheidungen mit echten Konsequenzen für den Belagerungsausgang

### Analyse & Tools
- **🧠 KI-Berater** — 4 Kategorien (Angriff/Verteidigung/Geschichte/Analyse), 9 Offline-Fallback-Typen
- **📊 Radar-Charts** — Dualvergleich zweier Burgen
- **🌀 Was wäre wenn?** — 7 kontrafaktische Szenarien
- **⚡ Direktvergleich** — animierte Balkendiagramme
- **📜 Geschichte-Tab** — animierter Zeitstrahl

### Burg-Baumeister
- **24 Gold Budget**, 25 Elemente, 10 Synergien
- **📥 Export** — Burg-Steckbrief als HTML

### Fortschritt & Statistiken
- **🏆 38 Achievements** mit Toast-Benachrichtigungen
- **💾 localStorage** Persistenz
- **🎖️ Scores-Tab** — Rekorde, Regionsauswertung, Filter, Export
- **📊 Atlas-Tab** — globale Statistiken

### Der Ordo Custodum Sorrowland
Eigene fiktive Ordensburg-Trilogie:
- ⬛ **Schwarzer Bergfried** (ca. 850) — bewacht verbotene Karten
- 🏰 **Castle Sorrow** (10./11. Jh.) — Hauptsitz, Ordensrat
- ⛰️ **Gravecrest** (12. Jh.) — auf keiner Karte verzeichnet

*Motto: In silentio vigilamus*

---

## 🚀 Schnellstart

```bash
npm install
npm run dev
```
→ http://localhost:3000

---

## 🌐 Deployment (Vercel)

1. Repo auf GitHub pushen
2. [vercel.com/new](https://vercel.com/new) → importieren
3. Environment Variable: `ANTHROPIC_KEY = sk-ant-...`
4. Deploy

---

## ⚠️ API Key

`ANTHROPIC_KEY` (serverside, nicht `VITE_`). Ohne Key greifen lokale Fallbacks — App funktioniert vollständig offline.

---

## 🏗️ Projektstruktur

```
belagerungs-atlas/
├── src/App.jsx          ← Hauptkomponente (85 Burgen, alle Features)
├── api/claude.js        ← Anthropic API Proxy
├── public/
│   ├── manifest.json    ← PWA
│   └── sw.js            ← Service Worker
└── index.html
```

## 🔧 Tech Stack

React 18 + Vite · Leaflet.js · Anthropic Claude API · Vercel

---

## 📋 Burgen nach Region

| Region | Anzahl |
|--------|--------|
| Europa | 18 |
| Naher Osten / Zentralasien | 12 |
| Japan | 5 |
| Indien / Sri Lanka | 4 |
| Südostasien | 5 |
| Amerika (Nord/Süd/Mittel) | 8 |
| Afrika | 4 |
| Mittelerde | 10 |
| Westeros | 5 |
| Sorrowland | 3 |
