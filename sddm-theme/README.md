# Vitreous: A Material Design-inspired theme for SDDM

![screenshot.png](repo_assets/screenshot.png)

Follow the instructions below to get started with using this theme on your system. Happy ricing!

## 1. Install fonts

Fonts required are [Google Sans Text](https://cdn.onlinewebfonts.com/Downloads/20250903/5c/OnlineWebFonts_COM_5c4fcd687637035e8854b4e9b94e727c.zip), [London Between](https://dl.dafont.com/dl/?f=london_between) and [PP Neue Machina](https://befonts.com/downfile/c0971349aa504b26b467af44daccf0a6.105233).

Use `unzip` or a file manager to extract the .zip files; you should now see .ttf and .otf files in the extracted folders.

Create two folders to store the fonts with `sudo mkdir /usr/local/share/fonts/{ttf,otf}`.

Create subfolders within `ttf` and `otf` with the corresponding font names:

```
sudo mkdir /usr/local/share/fonts/ttf/{google-sans-text,london}
sudo mkdir /usr/local/share/fonts/otf/pp-neue-machina
```

Copy the fonts to their corresponding locations with:

```
sudo cp <ttf_font_name> /usr/local/share/fonts/ttf/
sudo cp <otf_font_name> /usr/local/share/fonts/otf/pp-neue-machina # as that's the only .otf font here
```

Great! You should now have installed the required fonts correctly. Use `nwg-look` or a similar app to check if they're detected.

## 2. Configure systemd service and timer for weather

Create a file `/etc/sddm/weather.conf` that contains the following:

```
LAT="<your_latitude_coords>"
LON="<your_longitude_coords>"

# Units: C or F
UNIT="C"

```

Create a script `/usr/local/bin/update-sddm-weather` with the following:

```
#!/usr/bin/env bash
set -euo pipefail

CONF=/etc/sddm/weather.conf
[ -f "$CONF" ] && source "$CONF"

: "${LAT:?LAT missing in $CONF}"
: "${LON:?LON missing in $CONF}"
: "${UNIT:=C}"   # C or F

if [[ "$UNIT" =~ ^[Ff]$ ]]; then
  UNIT_Q="fahrenheit"
  SUFFIX="°F"
else
  UNIT_Q="celsius"
  SUFFIX="°C"
fi

URL="https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code,is_day&temperature_unit=${UNIT_Q}"

json="$(curl -fsSL "$URL")" || json=""
if [[ -z "$json" ]]; then
  echo "" > /run/sddm-weather.txt
  exit 0
fi

# Extract values
tmp="$(printf '%s' "$json" | jq -r '.current.temperature_2m // empty')"
wcode="$(printf '%s' "$json" | jq -r '.current.weather_code // empty')"
isday="$(printf '%s' "$json" | jq -r '.current.is_day // 1')"

# Round temperature
if [[ -n "${tmp:-}" ]]; then
  temp_int=$(awk -v t="$tmp" 'BEGIN{printf("%.0f", t)}')
else
  temp_int=""
fi

# Map WMO weather_code to emoji (with basic day/night variants)
emoji_for() {
  local code="$1" day="$2"
  case "$code" in
    0)   [[ "$day" = "1" ]] && echo "☀️" || echo "🌙" ;;             # Clear
    1)   [[ "$day" = "1" ]] && echo "🌤️" || echo "🌙";;              # Mainly clear
    2)   [[ "$day" = "1" ]] && echo "⛅️" || echo "☁️";;              # Partly cloudy
    3)   echo "☁️" ;;                                                # Overcast
    45|48) echo "🌫️" ;;                                             # Fog
    51|53|55) echo "🌦️" ;;                                          # Drizzle
    56|57) echo "🌧️" ;;                                             # Freezing drizzle
    61|63|65) echo "🌧️" ;;                                          # Rain
    66|67) echo "🌧️" ;;                                             # Freezing rain
    71|73|75|77) echo "🌨️" ;;                                       # Snow / grains
    80|81|82) echo "🌦️" ;;                                          # Rain showers
    85|86) echo "🌨️" ;;                                             # Snow showers
    95) echo "⛈️" ;;                                                # Thunderstorm
    96|99) echo "⛈️" ;;                                             # Thunderstorm + hail
    *) echo "🌡️" ;;                                                 # Fallback
  esac
}

emoji="$(emoji_for "${wcode:-}" "${isday:-1}")"

# Compose line
if [[ -n "$temp_int" ]]; then
  out="${emoji} ${temp_int}${SUFFIX}"
else
  out="${emoji}"
fi

# Write for greeter
outfile="/run/sddm-weather.txt"
printf '%s\n' "$out" > "$outfile"
chmod 0644 "$outfile"
chown sddm: "$outfile" 2>/dev/null || true
```

Create a systemd service `/etc/systemd/system/sddm-weather.service` with the following:

```
[Unit]
Description=Update weather string for SDDM

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-sddm-weather
```

Create a systemd timer `/etc/systemd/system/sddm-weather.timer` with the following:

```
[Unit]
Description=Refresh SDDM weather every 10 minutes

[Timer]
OnBootSec=20s
OnUnitActiveSec=10min
AccuracySec=30s
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start the timer:

```
sudo systemctl daemon-reload
sudo systemctl enable --now sddm-weather.timer
```

## 3. Add necessary env vars

Open `/etc/sddm.conf` and add the lines:

```
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1
```

## 4. Complete installation

Clone this repo with `git clone https://github.com/sane1090x/vitreous` and copy the folder to `/usr/share/sddm/themes`.

Edit `/etc/sddm.conf` and add:

```
[Theme]
Current=vitreous
```

