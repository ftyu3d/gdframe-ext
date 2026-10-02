#!/usr/bin/env bash
# Pack dist/<id>.zip. Zip entries are addons/gdframe_<id>/...
# Usage:
#   ./tools/pack_release.sh
#   ./tools/pack_release.sh stream_bus
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
MODULES=(stream_bus rumble input_remap)

if [[ "${1:-}" != "" ]]; then
	id="$1"
	found=0
	for m in "${MODULES[@]}"; do
		if [[ "$m" == "$id" ]]; then
			found=1
			break
		fi
	done
	if [[ "$found" -ne 1 ]]; then
		echo "Unknown ext id: $id (allowed: ${MODULES[*]})" >&2
		exit 1
	fi
	MODULES=("$id")
fi

mkdir -p "$DIST"

for id in "${MODULES[@]}"; do
	rel="addons/gdframe_$id"
	if [[ ! -f "$ROOT/$rel/plugin.cfg" ]]; then
		echo "Missing ext dir: $rel" >&2
		exit 1
	fi
	zip_path="$DIST/$id.zip"
	rm -f "$zip_path"
	(
		cd "$ROOT"
		zip -r -q "$zip_path" "$rel"
	)
	echo "Created: $zip_path"
done
