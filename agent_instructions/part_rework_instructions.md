# Deine Aufgabe

Deine Aufgabe ist es, alle Kapitel im Teil "Datentransformation" zu überarbeiten. Das betrifft alle Dateien im Ordner [03-data-transformation](/03-data-transformation). Folgende Dinge sollst du bitte tun:

- Für den gesamten Teil des Buches soll der Datensatz der Tweets verwendet werden: [tweets_ampel.rds](/data/tweets_ampel.rds). Er enthält Tweets von Politikern aus der Ampelregierung aus dem Zeitraum 2020-2024. Führe eine umfassende Analyse durch, damit du die Daten besser verstehst und passende Beispiele für die jeweilgen Kapitel identifizieren kannst.

- Sollte es besser sein, einen fiktiven Datensatz zu verwenden, weil es dann besser verständlich wird, dann erstelle dafür eine kleine CSV-Datei im /data Ordner und lese sie mit `read_csv()` ein. Erstelle keine tibbles manuell, das sollen die Studierenden nicht zwangsweise können. Versuche aber auch bei fiktiven Datensätzen am Beispiel der Tweets zu bleiben (z. B. für Joins die Parteizugehörigkeit eines Users als Mappingtabelle etc.).

- Vergib für jedes Kapitel (#) und seinen Unterabschnitten auf erster Ebene (##) eine ID nach dem Format `#sec-<chapter_file_without-file-ending>-<id>`. Stelle Verbindungen zwischen den Kapitel und Abschnitten her, wenn das sinnvoll erscheint. Es soll auf jeden Fall ein roter Faden im gesamten Teil erkennbar sein, der wird durch Querverweise verstärkt.

- Analysiere alle Kapitel und prüfe, ob ein roter Faden existiert. Mache entsprechende Änderungen, falls das der Fall ist.

- Inhatliche Dopplungen sind OK, stelle aber sicher, dass du in einem Kapitel die Details aufzeigst (wo das Thema am ehesten hingehört) und an anderer Stelle dann darauf referenziert wird.

- Stelle eine kurze Zusammenfassung an den Anfang jedes Kapitels. Füge dort auch eine Tabelle mit den wichtigsten neuen Funktionen ein. Stelle sicher, dass der grundlegende Aufbau in jedem Kapitel gleich ist.

- Stelle am Ende jedes Kapitels eine Zusammenfassung in 1-2 Sätzen und leite zum nächsten Kapitel über. Verzichte hier auf eine lange Zusammefassung oder Bullet-Point-Listen.

- Überprüfe im Gesamtblick alle Kapitel auf inhaltliche Vollständigkeit und Korrektheit. Kapitel die noch nicht fertig sind verfasst du bitte komplett neu.

- Beachte immer die Hinweise zum Schreibstil unten. Meine Vorbilder sind die Bücher R 4 Data Science von Hadley Wickham und das Buch "The Effect" von Nick Huntington-Klein, was den Schreibstil angeht.

# Schreibstil

Beachte die Hinweise zum Schreibstil:

- Das Kapitel soll so geschrieben sein, dass es die Studierenden anspricht und mitnimmt
- Ich spreche die Studierenden im Buch mit "ihr" an; zuweilen schreibe ich auch "Lasst uns sehen..." oder "Prüfen wir, ob...".
- Ich stelle gerne Fragen zu Beginn eines Abschnitts, die dann im Laufe der nächsten Absätze beantwortet wird. Damit versuche ich, die Studierenden neugierig zu machen und die Fragen auch in ihren Kopf zu projizieren.
- Ich nutze gerne Analogien und Bilder, wo sinnvoll. Knüpfe an das Allgemeinwissen junger Menschen an.
- Vermeide Bindestriche, um **Sätze** zu verbinden. Wörter darftst du natürlich mit Bindestrichen verbinden, wenn nötig.
- Verwende möglichst keine Abkürzungen wie "z. B." oder "inkl.", sondern schreibe sie aus.
- Verwende in Code-Beispielen ausschließlich **englische Variablennamen** (zum Beispiel `age` statt `alter`, `grades` statt `noten`, `passed` statt `bestanden`). Das gilt auch für Spaltennamen in Data Frames und Tibbles sowie für die Werte von Faktoren.
- Verwende kurze Abschnittsnamen und Überschriften und verwende keine Doppelpunkte in Abschnittsnamen.