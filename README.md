# Homematic 2 InfluxDB

## Beschreibung
Erzeugt eine Abfrage auf das XML-API einer Homematic (CCUx/Raspberrymatic) Zentrale und übermittelt alle verwendbaren Daten in eine InfluxDB. Die Aktualisierung erfolgt im Batchbetrieb per Zeitplan (z.B. Cron)

## Voraussetzungen

* Homematic CCUx oder [Raspberrymatic](https://raspberrymatic.de)
* Homematic XML-APi AddOn [XML-API](https://www.homematic-inside.de/software/xml-api)
* InfluxDB [InfluxDB](https://www.influxdata.com/)
* Python3

## Konfiguration

Alle benötigten Parameter können über die Datei *settings.cfg* konfiguriert werden. 

## Aufuf 

### Konsole
```console
python3 homematic2influxdb.pl 
```

### Cron
```
# m h  dom mon dow   command
* * * * * python3 /path/to/homematic2influxdb/homematic2influxdb.pl  >/dev/null 2>&1
```


## Kontakt
Michael Bieri
[E-Mail](mailto:michael@bieri.club)
[Webseite](https://michael.bieri.club)