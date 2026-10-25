#!/usr/bin/env python3
"""Compile the MultiWordNet SQL dumps into one SQLite database."""
from __future__ import annotations

import sqlite3
from pathlib import Path

DATA = Path(__file__).resolve().parent
CACHE = DATA / "cache"
SOURCE = CACHE / "multiwordnet" / "multiwordnet" / "db"
TARGET = CACHE / "mwn.db"

FILES = (
    "english/english_synset.sql",
    "english/english_index.sql",
    "english/english_lemma.sql",
    "english/english_relation.sql",
    "spanish/spanish_synset.sql",
    "spanish/spanish_index.sql",
    "spanish/spanish_lemma.sql",
    "common/common_relation.sql",
    "common/common_semfield.sql",
    "common/common_semfield_hierarchy.sql",
    "common/common_sentiment.sql",
)


def main() -> None:
    if not SOURCE.is_dir():
        raise SystemExit(f"missing MultiWordNet SQL sources at {SOURCE}")
    if TARGET.exists():
        TARGET.unlink()
    connection = sqlite3.connect(TARGET)
    try:
        for relative in FILES:
            path = SOURCE / relative
            if not path.exists():
                print(f"skip missing {relative}")
                continue
            sql = path.read_text(encoding="utf-8", errors="replace")
            # The dump uses '#' comment lines and occasionally duplicates a key.
            sql = "\n".join(
                line for line in sql.splitlines() if not line.startswith("#")
            )
            sql = sql.replace("INSERT INTO", "INSERT OR IGNORE INTO")
            connection.executescript(sql)
            connection.commit()
            print(f"loaded {relative}")
    finally:
        connection.close()
    print(f"wrote {TARGET}")


if __name__ == "__main__":
    main()
