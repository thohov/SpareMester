# SpareMester 🛍️💰

**App for å forhindre spontankjøp i hverdagen.**

SpareMester hjelper deg med å ta bedre kjøpsbeslutninger ved å gi deg tid til å tenke deg om før du kjøper noe. Legg til produkter du ønsker, og appen setter en automatisk tenketid basert på prisen.

## ✨ Funksjoner

- ⏳ **Automatiske ventetider** - Jo dyrere produkt, jo lengre tenketid
- 🔔 **Varsler** - Få beskjed når tenketiden er over
- 📊 **Statistikk** - Se hvor mye du har spart
- 🏆 **Prestasjoner** - Lås opp over 30 achievements
- 📱 **100% Offline** - All data lagres lokalt på telefonen
- 🚫 **Ingen datainnsamling** - Din informasjon forblir privat
- 🎨 **Norsk & Engelsk** - Velg ditt foretrukne språk

## 🔒 Personvern

SpareMester samler INGEN data. Alt lagres lokalt på din telefon:
- Ingen brukerprofil
- Ingen servere
- Ingen analysedata
- Ingen annonsering

## 📥 Installasjon

### Metode 1: Last ned ferdig APK (Anbefalt)

1. **Last ned APK:**
   - Gå til [Releases-siden](https://github.com/thohov/SpareMester/releases)
   - Last ned `app-release.apk` fra den nyeste versjonen

2. **Aktiver ukjente apper:**
   - Åpne **Innstillinger** på Android-telefonen
   - Gå til **Apper** eller **Sikkerhet**
   - Finn **Installer ukjente apper**
   - Velg nettleseren du lastet ned APK med (f.eks. Chrome)
   - Aktiver **Tillat fra denne kilden**

3. **Installer APK:**
   - Åpne nedlastingsmappen på telefonen
   - Trykk på `app-release.apk`
   - Følg installasjonsinstruksjonene
   - Trykk **Installer**

4. **Kjør appen:**
   - Åpne SpareMester fra app-listen
   - Gjennomfør onboarding (10 kort introduksjon)
   - Begynn å spare penger! 💰

### Metode 2: Bygg selv fra kildekode

```bash
# Klon repository
git clone https://github.com/thohov/SpareMester.git
cd SpareMester

# Installer dependencies
flutter pub get

# Bygg release APK
flutter build apk --release
```
APK-filen ligger i: `build/app/outputs/flutter-apk/app-release.apk`

## 🛠️ Bygget med

- Flutter & Dart
- Hive (lokal database)
- Flutter Local Notifications

## 📄 Lisens

Se [LICENSE](LICENSE) filen for detaljer. Koden er tilgjengelig for inspeksjon, men ikke for kommersiell bruk.

## 👨‍💻 Utvikler

Laget med ❤️ av Thomas Øie-Hovland

---

*Laget for å ikke bruke penger på unødvendig dritt <3*
