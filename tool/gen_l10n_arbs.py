#!/usr/bin/env python3
"""Generate machine-translated ARB files from app_en.arb. Run from repo root."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EN_ARB = ROOT / "lib/l10n/app_en.arb"

PLACEHOLDER_RE = re.compile(r"\{([a-zA-Z][a-zA-Z0-9_]*)")


def placeholders(text: str) -> set[str]:
    return set(PLACEHOLDER_RE.findall(text))


def main() -> None:
    sys.path.insert(0, str(Path(__file__).parent))
    from l10n_catalog import CATALOG  # type: ignore

    en = json.loads(EN_ARB.read_text(encoding="utf-8"))
    keys = [k for k in en if not k.startswith("@")]
    for locale, messages in CATALOG.items():
        extra = set(messages) - set(keys)
        missing = set(keys) - set(messages)
        if extra or missing:
            raise SystemExit(
                f"{locale}: extra={sorted(extra)} missing={sorted(missing)}"
            )
        for key in keys:
            src_ph = placeholders(en[key])
            dst_ph = placeholders(messages[key])
            if src_ph != dst_ph:
                raise SystemExit(
                    f"{locale}.{key} placeholders {sorted(dst_ph)} != {sorted(src_ph)}"
                )
        out: dict = {"@@locale": locale}
        for key in keys:
            out[key] = messages[key]
            meta = en.get(f"@{key}")
            if meta is not None:
                out[f"@{key}"] = meta
        path = ROOT / f"lib/l10n/app_{locale}.arb"
        path.write_text(
            json.dumps(out, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"wrote {path.name}")
    print(f"ok {len(CATALOG)} locales")


if __name__ == "__main__":
    main()
