# Restaurant Finder 🍽️

Eine iOS-App zum Finden von Restaurants, Cafés, Bars und anderen gastronomischen Einrichtungen in deiner Nähe.

## Features ✨

- 📍 Findet Restaurants im Umkreis von 20km
- 🔍 Durchsuchbare Liste aller Einrichtungen
- 🏪 Verschiedene Kategorien: Restaurants, Cafés, Bars, Pubs, Bistros, etc.
- 📏 Zeigt Entfernung zu jedem Restaurant an
- 🗺️ Integration mit Apple Maps
- 💡 Feature-Request-System mit WishKit

## Setup 🛠️

### 1. Repository klonen

```bash
git clone https://github.com/DEIN_USERNAME/Restaurant_Finder.git
cd Restaurant_Finder
```

### 2. API-Keys einrichten

Die App benötigt einen WishKit API-Key für das Feature-Request-System:

1. Kopiere `APIKeys.swift.template` zu `APIKeys.swift`:
   ```bash
   cp APIKeys.swift.template APIKeys.swift
   ```

2. Öffne `APIKeys.swift` und ersetze `YOUR_WISHKIT_ID_HERE` mit deinem WishKit API-Key

3. Du erhältst deinen WishKit API-Key von [wishkit.io](https://wishkit.io)

**Wichtig:** `APIKeys.swift` wird von Git ignoriert und sollte niemals committed werden!

### 3. Xcode öffnen

```bash
open Restaurant_Finder.xcodeproj
```

### 4. App starten

- Wähle ein Gerät oder Simulator
- Drücke `Cmd + R` zum Starten

## Anforderungen 📱

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Berechtigungen 🔐

Die App benötigt:
- **Standort-Zugriff**: Zum Finden von Restaurants in deiner Nähe
  - Diese Berechtigung wird beim ersten Start abgefragt

## Verwendete Frameworks 📚

- **MapKit**: Für Standort-Dienste und Karten-Integration
- **CoreLocation**: Für Standort-Erfassung
- **WishKit**: Für Feature-Requests und Nutzer-Feedback
- **SwiftUI**: Für die Benutzeroberfläche

## Architektur 🏗️

- **MVVM Pattern**: ViewModel verwaltet Business-Logik
- **Swift Concurrency**: Async/Await für API-Calls
- **Combine**: Für reaktive Daten-Bindings

## Beitragen 🤝

Beiträge sind willkommen! Bitte:

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

**Wichtig:** Niemals API-Keys oder sensible Daten committen!

## Lizenz 📄

[Füge hier deine Lizenz ein, z.B. MIT]

## Kontakt 📧

Jonas Mahlburg - mail@jonas-mahlburg.de

## Danksagungen 🙏

- Apple für MapKit und CoreLocation
- WishKit für das Feature-Request-System
