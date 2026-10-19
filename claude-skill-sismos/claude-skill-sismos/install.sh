#!/usr/bin/env sh
# Instala la skill "sismos" para tu usuario de Claude Code (~/.claude/skills/sismos).
set -e
ORIGEN="$(cd "$(dirname "$0")" && pwd)/sismos"
DESTINO="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/sismos"
mkdir -p "$(dirname "$DESTINO")"
rm -rf "$DESTINO"
cp -R "$ORIGEN" "$DESTINO"
chmod +x "$DESTINO/scripts/sismos.py"
echo "Skill instalada en $DESTINO"
echo "Prueba:  python3 \"$DESTINO/scripts/sismos.py\" prueba"
echo "Luego, en Claude Code:  avísame si tiembla"
