# ncore.pro-autologin


## Hungarian / Magyar

Ez a script automatikusan bejelentkezik az ncore.pro oldalra, hogy a fiókodat ne töröljék inaktivitás miatt.
A szabályzat szerint legalább 8 hetente egyszer be kell jelentkezned, különben a fiókod letiltásra kerül. Elég hetente egyszer futtatni.
Windowson és Linuxon is működik.

Legutóbb tesztelve: 2026-11-27

### Telepítés Windowson

1. Kattints fent a zöld **Code** gombra, majd a **Download ZIP** pontra.
2. Csomagold ki egy állandó helyre, például ide: `C:\ncore-autologin`. A mappát később ne helyezd át és ne töröld, mert az ütemezett feladat innen futtatja a scriptet.
3. Kattints duplán az `install.cmd` fájlra.
4. Add meg az ncore felhasználóneved és jelszavad. A telepítő kipróbálja a belépést, és ha sikeres, létrehoz egy feladatot a Feladatütemezőben. Ez minden hétfőn 12:00-kor bejelentkezik. Ha a gép akkor ki van kapcsolva, a következő indításkor fut le.

Az eredményeket az `autologin.log` fájlban találod, a script mellett.
Ha megváltozott a jelszavad, futtasd újra az `install.cmd` fájlt.

Eltávolítás: kattints a mappa címsorába, írd be, hogy `cmd`, majd nyomj Entert. A megnyíló ablakban futtasd ezt: `install.cmd -Uninstall`. Utána a mappa törölhető.

### Telepítés Linuxon

1. Telepítsd a szükséges csomagokat (Debian és Ubuntu alatt): `sudo apt install ksh curl`
2. Töltsd le a scriptet:
   ```
   mkdir -p ~/ncore-autologin && cd ~/ncore-autologin
   curl -O https://raw.githubusercontent.com/Feriman22/ncore.pro-autologin/master/autologin.ksh
   chmod +x autologin.ksh
   ```
3. Futtasd egyszer: `./autologin.ksh`. Első futáskor létrehozza az `ncorelogininfo.txt` fájlt mintaadatokkal. Írd bele a saját felhasználóneved és jelszavad, majd futtasd: `chmod 600 ncorelogininfo.txt`
4. Futtasd újra. Ha a kimenet `Logged in successfully.`, minden rendben.
5. Állítsd be heti futásra a cronban (`crontab -e`):
   ```
   0 12 * * 1 cd $HOME/ncore-autologin && ./autologin.ksh cron
   ```
   A `cron` paraméterrel a script csak hiba esetén ír ki valamit, így a cron csak akkor küld levelet, ha baj van.

### Kilépési kódok

| Kód | Jelentés |
|-----|----------|
| 0 | Sikeres belépés |
| 2 | Hiányzik az `ncorelogininfo.txt` (a script létrehozza mintaadatokkal) |
| 3 | Nem található a belépési űrlap (az oldal nem elérhető vagy megváltozott) |
| 4 | Nem sikerült lekérni az aktuális böngészőazonosítót (user agent) |
| 5 | Sikertelen belépés (hibás felhasználónév vagy jelszó) |

### GYIK

**Biztonságos?** A felhasználónév és a jelszó sima szövegként tárolódik az `ncorelogininfo.txt` fájlban, a script mellett, és csak az ncore.pro oldalra kerül elküldésre. Csak olyan gépen használd, amelyhez más nem fér hozzá.

**Milyen gyakran fusson?** Hetente egyszer bőven elég, a szabály 8 hetet enged.

**Nem működik, mit tegyek?** Nézd meg a kilépési kódot (Windowson az `autologin.log` fájlt). Ha nem egyértelmű, nyiss egy issue-t.


## English

This script automatically logs in to ncore.pro, so that your account is not deleted due to inactivity.
The policy is that you must log in at least once every 8 weeks or your account will be banned. Running it once a week is enough.
It works on Windows and Linux.

Last tested: 27-11-2026

### Install on Windows

1. Click the green **Code** button above, then **Download ZIP**.
2. Extract it to a permanent place, for example `C:\ncore-autologin`. Do not move or delete the folder later, the scheduled task runs the script from there.
3. Double-click `install.cmd`.
4. Enter your ncore username and password. The installer tests the login, and if it works, it creates a task in Task Scheduler. It logs in every Monday at 12:00. If the computer is off at that time, it runs at the next start.

You can find the results in the `autologin.log` file next to the script.
If your password changed, run `install.cmd` again.

Uninstall: click the address bar of the folder, type `cmd` and press Enter. In the new window run `install.cmd -Uninstall`. After that you can delete the folder.

### Install on Linux

1. Install the required packages (on Debian and Ubuntu): `sudo apt install ksh curl`
2. Download the script:
   ```
   mkdir -p ~/ncore-autologin && cd ~/ncore-autologin
   curl -O https://raw.githubusercontent.com/Feriman22/ncore.pro-autologin/master/autologin.ksh
   chmod +x autologin.ksh
   ```
3. Run it once: `./autologin.ksh`. On the first run it creates `ncorelogininfo.txt` with sample data. Put your username and password in it, then run: `chmod 600 ncorelogininfo.txt`
4. Run it again. If the output is `Logged in successfully.`, everything is fine.
5. Schedule it weekly with cron (`crontab -e`):
   ```
   0 12 * * 1 cd $HOME/ncore-autologin && ./autologin.ksh cron
   ```
   With the `cron` parameter the script only prints something on errors, so cron only sends you a mail when something is wrong.

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | Logged in successfully |
| 2 | `ncorelogininfo.txt` is missing (the script creates it with sample data) |
| 3 | Login form not found (the website is offline or has changed) |
| 4 | Could not get the latest browser user agent |
| 5 | Login failed (wrong username or password) |

### FAQ

**Is it safe?** Your username and password are stored in plain text in `ncorelogininfo.txt` next to the script, and they are only sent to ncore.pro. Only use it on a computer that nobody else can access.

**How often should it run?** Once a week is more than enough, the policy allows 8 weeks.

**It does not work, what should I do?** Check the exit code (on Windows, the `autologin.log` file). If it is not clear, open an issue.

---

## Changelog

27-11-2026 - Windows version with an installer (install.cmd), install guide, MIT license.  
04-03-2025 - Improve: Get the latest user agent automatically.  
18-10-2024 - Up-to-date user agents list based on [this website](https://www.whatismybrowser.com/guides/the-latest-user-agent/)  
11-08-2024 - Up-to-date user agents list based on [this website](https://www.whatismybrowser.com/guides/the-latest-user-agent/)  
08-01-2024 - Simplify the code, up-to-date user agents list based on [this website](https://www.whatismybrowser.com/guides/the-latest-user-agent/)  
25-06-2023 - Up-to-date and extended user agents list based on [this website](https://www.whatismybrowser.com/guides/the-latest-user-agent/)  
25-06-2023 - ksh version of the script has been released.
26-01-2023 - Add argument "cron" to supress "Logged in successfully." message.   
26-01-2023 - Up-to-date and extended user agents list based on [this website](https://www.whatismybrowser.com/guides/the-latest-user-agent/)   
01-01-2023 - python3 compatibility
