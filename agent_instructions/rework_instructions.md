Du hilfst mir bei der Überarbeitung meines vorliegenden Buches "Hands-On Exploratory Data Analysis". Ich schreibe das Buch in Quarto, jedes Kapitel ist eine Markdown-Datei (`.qmd`). Bitte stelle bei deiner Bearbeitung sicher, dass alle Quarto- und Markdown-Elemente richtig erhalten bleiben (Bilder, Links etc.).

# Abruf der Bilder

Ich erwarte, dass du bei deiner Arbeit die Bilder aus dem Quarto-Dokument mit einbeziehst. Die Bilder kannst du aufrufen, indem du folgende URL vor den Pfad setzt: https://winf-hsos.github.io/hands-on-exploratory-data-analysis-book

Also wenn etwa im Marddown steht:

```md
![Arten von Variablen und typische verwendete Datentypen in R.](/images/types-of-variables.png){#fig-surveys-types-of-variables}
```

Dann ist der Link zum Bild:

https://winf-hsos.github.io/hands-on-exploratory-data-analysis-book/images/types-of-variables.png

# Hinweise zu deiner Aufgabe

Ich bin unzufrieden mit der Struktur des Kapitels. Die Inhalte sind zwar gut und richtig, aber ich habe das Gefühl, dass die Struktur besser sein könnte. Deine Aufgabe ist es daher, das Kapitel *komplett* zu überarbeiten und in eine bessere Struktur zu bringen. Dabei darfst und sollst du:

- Inhalte aus Absätzen in andere Absätze verschieben, wenn es dem Verständnis dient.
- Absätze umschreiben, damit sie besser verstanden werden.
- Absätze löschen, wenn sie redundant sind oder nicht zum Verständnis beitragen.
- Neue Absätze verfassen, wenn es dem Verständnis dient.
- Übergänge zwischen Absätzen herstellen, wenn es dem Verständnis dient.
- Alle Überschriften neu schreiben, wenn es dem Verständnis dient. 
- Bevorzuge kurze und prägnante Überschriften für Abschnitte und formuliere sie nicht als Fragen.

Im Prinzip hast du alle Freiheiten, das Kapitel so zu gestalten, dass es für die Studierenden am besten verständlich ist. Du sollst dabei aber den ursprünglichen Sinn und die ursprünglichen Inhalte des Kapitels beibehalten. 

# Schreibstil

Beachte folgende Hinweise zu meinem Schreibstil:

- Das Buch soll so geschrieben sein, dass es die Studierenden anspricht und mitnimmt
- Ich spreche die Studierenden im Buch mit "ihr" an; zuweilen schreibe ich auch "Lasst uns sehen..." oder "Prüfen wir, ob...".
- Ich stelle gerne Fragen zu Beginn eines Abschnitts, die dann im Laufe der nächsten Absätze beantwortet wird. Damit versuche ich, die Studierenden neugierig zu machen und die Fragen auch in ihren Kopf zu projizieren.
- Ich nutze gerne Analogien und Bilder, wo sinnvoll. Knüpfe an das Allgemeinwissen junger Menschen an.
- Vermeide Bindestriche, um Sätze zu verbinden.
- Verwende möglichst keine Abkürzungen wie "z. B." oder "inkl.", schreibe sie aus.
- Verwende in Code-Beispielen ausschließlich **englische Variablennamen** (zum Beispiel `age` statt `alter`, `grades` statt `noten`, `passed` statt `bestanden`). Das gilt auch für Spaltennamen in Data Frames und Tibbles sowie für die Werte von Faktoren.

# Ergebnis

Lege vor deiner Überarbeitung immer eine Kopie an, der du den Präfix "OLD_" gibst. Also wenn du den Auftrag hast, das Kapitel:

`project-1-survey/types-of-variables.qmd` 

zu überarbeiten, dann legst du eine Datei mit dem Namen

`project-1-survey/OLD_types-of-variables.qmd`

an. Nutze dazu die Kopierbefehle im Terminal. 

Du änderst dann direkt in der Originaldatei. Zudem legst du eine weitere Datei an, in der du detailliert auflistest, welche Änderungen du gemacht hast und den Grund dafür.

`project-1-survey/CHANGES_types-of-variables.qmd`