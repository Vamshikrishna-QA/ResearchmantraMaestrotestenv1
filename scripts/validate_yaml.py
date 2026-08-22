#!/usr/bin/env python3
"""
Validate all .yaml files under maestro-e2e-automation by attempting to parse them with PyYAML.
Exits with code 0 on success, 1 on parse errors.
"""
import sys
from pathlib import Path

try:
    import yaml
except Exception as e:
    print("Missing dependency: PyYAML is required. Install with: pip install pyyaml")
    sys.exit(2)

base = Path.cwd() / "maestro-e2e-automation"
if not base.exists():
    print(f"Directory not found: {base}")
    sys.exit(1)

errors = []
files = sorted(base.rglob("*.yaml"))
if not files:
    print(f"No YAML files found under {base}")
    sys.exit(0)

for f in files:
    try:
        data = f.read_text(encoding="utf-8")
        list(yaml.safe_load_all(data))
        print(f"OK: {f}")
    except Exception as ex:
        errors.append((f, str(ex)))
        print(f"ERROR: {f} -> {ex}")

if errors:
    print(f"\nValidation failed: {len(errors)} file(s) have YAML errors.")
    sys.exit(1)

print("\nAll YAML files parsed successfully.")
sys.exit(0)
