# Skill "sismos" para Claude Code 🌎

Una [skill](https://docs.claude.com/en/docs/claude-code/skills) que hace que **Claude te avise de los
sismos y temblores cerca de ti**, en la conversación y con notificación push.

- Fuentes: **USGS** y **EMSC** (catálogos públicos) y, opcionalmente, **GlobalQuake Server** (detección
  propia en segundos) o el backend en tiempo real `sismo-rt`.
- Calcula para tu ubicación la distancia, la dirección y la **intensidad estimada (Mercalli)**.
- Dos niveles: **ALERTA** (M ≥ 4.0 y se sentiría en tu ubicación: intensidad ≥ III) e **INFO**.
- No repite avisos, aunque el vigilante se reinicie, y te avisa si una fuente deja de responder.
- Solo Python estándar (3.9+). No necesita instalar nada.

> ⚠️ **Nadie puede predecir terremotos.** La skill avisa cuando un sismo ya fue *detectado*. Con
> USGS/EMSC el aviso llega entre 1 y 20 minutos después. Para emergencias en Chile, la fuente oficial es
> el **SAE de SENAPRED** y el **CSN** ([sismologia.cl](https://www.sismologia.cl)).

## Instalación

```bash
git clone https://github.com/<tu-usuario>/claude-skill-sismos.git
cd claude-skill-sismos
./install.sh            # Windows: powershell -ExecutionPolicy Bypass -File install.ps1
```

Queda en `~/.claude/skills/sismos` y Claude Code la carga en cualquier proyecto. Para usarla solo en
un proyecto, copia la carpeta `sismos/` a `<proyecto>/.claude/skills/sismos`.

## Uso

Dile a Claude, en lenguaje normal:

| Le dices | Qué hace |
|---|---|
| "¿Hubo temblores cerca?" | Revisa las últimas 24 h y te resume los sismos relevantes |
| "Avísame si tiembla" | Deja un vigilante en segundo plano y te avisa apenas aparezca un sismo |
| "Vigila los sismos en Santiago" | Lo mismo, para otra ciudad |
| "Para de vigilar" | Detiene el vigilante |

Ejemplo de aviso:

```text
SISMO nivel=ALERTA | M5.4 a 44 km al O de Copiapó | intensidad estimada V (Moderado) | prof 35 km |
2026-10-19 18:03:12 (hace 3 min) | 40 km W of Copiapó, Chile | fuentes=emsc,usgs | https://...
```

El vigilante corre mientras la sesión de Claude Code esté abierta. Claude lo rearma cada 30 minutos.

### Usar el script directamente

```bash
python3 sismos/scripts/sismos.py ahora --horas 24          # sismos recientes
python3 sismos/scripts/sismos.py ahora --json              # en JSON
python3 sismos/scripts/sismos.py vigilar                   # vigilancia continua (Ctrl+C para salir)
python3 sismos/scripts/sismos.py prueba                    # aviso ficticio para probar
```

## Configuración

Por defecto vigila **Copiapó**: sismos a ≤ 500 km, M ≥ 6.0 en todo el mundo, ignora M < 3.0.
Se cambia con argumentos o variables de entorno:

| Variable | Argumento | Por defecto |
|---|---|---|
| `SISMOS_LAT`, `SISMOS_LON`, `SISMOS_LUGAR` | `--lat --lon --lugar` | Copiapó |
| `SISMOS_RADIO_KM` | `--radio-km` | 500 |
| `SISMOS_MAG_GLOBAL` | `--mag-global` | 6.0 |
| `SISMOS_MAG_MIN` | `--mag-min` | 3.0 |
| `SISMOS_INTERVALO_S` | `--intervalo` | 30 (USGS/EMSC) |
| `SISMOS_GQ_URL` | `--gq-url` | — (GlobalQuake Server) |
| `SISMOS_RT_URL` | `--rt-url` | — (backend sismo-rt) |

## GlobalQuake

El repositorio público de [GlobalQuake](https://github.com/xspanger3770/GlobalQuake) está descontinuado
desde la 1.0.0 (sigue como proyecto propietario en globalquake.net). La versión abierta **0.11**
(licencia MIT) incluye en **GlobalQuake Server** una API FDSNWS-event, apagada por defecto:

1. En los settings de GlobalQuake Server: `autoStartFDSNWSEventServer=true` (puerto `FDSNWSEventPort`,
   por defecto 8080).
2. `export SISMOS_GQ_URL=http://localhost:8080`

La skill lo consulta cada 5 s y marca sus sismos como `SIN_CONFIRMAR` hasta que USGS o EMSC los
confirman. GlobalQuake es experimental: sus autores advierten que puede dar datos erróneos.

## Cómo se calcula

- **Distancia:** fórmula de Haversine. Se usa la distancia hipocentral (incluye la profundidad).
- **Intensidad:** Allen, Wald & Worden (2012), *Intensity attenuation for active crustal regions*,
  J. Seismol. 16:409–433, versión con distancia hipocentral (coeficientes verificados contra
  `AllenEtAl2012Rhypo` de OpenQuake). Está calibrada para corteza activa: en la subducción chilena es
  una aproximación.
- **Mismo sismo en varias fuentes:** se une si ocurre a ≤ 90 s y ≤ 150 km de otro.

## Red

Necesita salida HTTPS a `earthquake.usgs.gov` y `www.seismicportal.eu`. Si se usa en una sesión de
Claude Code en la nube, esos dominios deben estar permitidos en la red del entorno.

## Pruebas

```bash
python3 -m unittest discover -s sismos/tests -v
```

No usan internet: simulan USGS, EMSC, GlobalQuake Server y sismo-rt con servidores locales.

## Licencia

MIT.
