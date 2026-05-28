#!/usr/bin/env python3
"""Import Resora docx content into Firestore content_items.

Usage:
  python3 scripts/import_resora_docx_to_firestore.py --apply
  python3 scripts/import_resora_docx_to_firestore.py --verify-only
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
import zipfile
from dataclasses import dataclass
from pathlib import Path

PROJECT_ID = "calmacare-b6d6c"
DATABASE = "(default)"
COLLECTION = "content_items"
API_BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/{DATABASE}/documents"

JOURNAL_DOC = Path("/Users/mkay/Downloads/Resora Journal Prompts.docx")
NORMAL_DOC = Path("/Users/mkay/Downloads/Resora — Is This Normal, Topics 11 to 20.docx")


def _now_iso() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z")


def _today_str() -> str:
    return dt.datetime.now(dt.timezone.utc).date().isoformat()


def _slug(text: str) -> str:
    out = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return out or "item"


def _clean_line(line: str) -> str:
    line = line.replace("\u2019", "'").replace("\u201c", '"').replace("\u201d", '"')
    line = re.sub(r"\s+", " ", line).strip()
    line = re.sub(r'^"|"$', "", line).strip()
    return line


def _read_docx_lines(path: Path) -> list[str]:
    ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
    with zipfile.ZipFile(path, "r") as zf:
        xml_bytes = zf.read("word/document.xml")

    root = ET.fromstring(xml_bytes)
    lines: list[str] = []
    for p in root.findall(".//w:p", ns):
        texts = [t.text or "" for t in p.findall(".//w:t", ns)]
        if not texts:
            continue
        line = _clean_line("".join(texts))
        if line:
            lines.append(line)
    return lines


@dataclass
class JournalEntry:
    category: str
    prompt: str
    order: int


@dataclass
class NormalEntry:
    heading: str
    question: str
    answer: str
    voices: list[str]


def parse_journal_doc(path: Path) -> list[JournalEntry]:
    lines = _read_docx_lines(path)
    entries: list[JournalEntry] = []
    current_category = ""
    order = 1

    theme_re = re.compile(r"^THEME\s+\d+\s+[—-]\s+(.+)$", re.IGNORECASE)
    prompt_re = re.compile(r"^\d+\.\s+(.+)$")

    for line in lines:
        m_theme = theme_re.match(line)
        if m_theme:
            current_category = _clean_line(m_theme.group(1)).lower()
            continue

        m_prompt = prompt_re.match(line)
        if not m_prompt or not current_category:
            continue

        prompt = _clean_line(m_prompt.group(1))
        if not prompt:
            continue

        entries.append(JournalEntry(category=current_category, prompt=prompt, order=order))
        order += 1

    return entries


def parse_normal_doc(path: Path) -> list[NormalEntry]:
    lines = _read_docx_lines(path)

    blocks: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    mode = ""

    heading_re = re.compile(r"^(TOPIC\s*\d+|Post\s*\d+)\s*$", re.IGNORECASE)

    def flush_current() -> None:
        nonlocal current
        if not current:
            return
        question = _clean_line(str(current.get("question", "")))
        answer = _clean_line(str(current.get("answer", "")))
        voices = [
            _clean_line(v)
            for v in current.get("voices", [])  # type: ignore[arg-type]
            if _clean_line(v)
        ]
        heading = _clean_line(str(current.get("heading", "")))
        if question:
            blocks.append({
                "heading": heading,
                "question": question,
                "answer": answer,
                "voices": voices,
            })
        current = None

    i = 0
    while i < len(lines):
        line = lines[i]

        if heading_re.match(line):
            flush_current()
            current = {"heading": line, "question": "", "answer": "", "voices": []}
            mode = ""
            i += 1
            continue

        if current is None:
            i += 1
            continue

        low = line.lower()
        if low.startswith("question"):
            mode = "question"
            i += 1
            continue
        if low.startswith("expert answer"):
            mode = "answer"
            i += 1
            continue
        if low.startswith("community voices"):
            mode = "voices"
            i += 1
            continue

        if line.startswith("━━━━━━━━"):
            i += 1
            continue

        if mode == "question":
            if not current["question"]:
                current["question"] = line
        elif mode == "answer":
            prior = str(current["answer"])
            current["answer"] = (prior + " " + line).strip() if prior else line
        elif mode == "voices":
            voices = current["voices"]
            assert isinstance(voices, list)
            voices.append(line)

        i += 1

    flush_current()

    entries: list[NormalEntry] = []
    for b in blocks:
        question = str(b["question"]).strip()
        answer = str(b["answer"]).strip()
        voices = [v for v in b["voices"] if isinstance(v, str)]

        if not answer:
            answer = (
                "Yes, this can be more common than it feels in the moment. "
                "You are not alone in this experience, and this is a place to pause, "
                "name what is happening, and choose one gentle next step."
            )

        entries.append(
            NormalEntry(
                heading=str(b["heading"]),
                question=question,
                answer=answer,
                voices=voices,
            )
        )

    return entries


def fs_string(value: str) -> dict:
    return {"stringValue": value}


def fs_int(value: int) -> dict:
    return {"integerValue": str(value)}


def fs_bool(value: bool) -> dict:
    return {"booleanValue": value}


def fs_timestamp(value: str) -> dict:
    return {"timestampValue": value}


def fs_array_str(values: list[str]) -> dict:
    return {
        "arrayValue": {
            "values": [{"stringValue": v} for v in values]
        }
    }


def firestore_patch(token: str, doc_id: str, fields: dict) -> dict:
    url = f"{API_BASE}/{COLLECTION}/{urllib.parse.quote(doc_id, safe='')}"
    body = json.dumps({"fields": fields}).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="PATCH",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=45) as resp:
        return json.loads(resp.read().decode("utf-8"))


def get_access_token() -> str:
    result = subprocess.run(
        ["gcloud", "auth", "print-access-token"],
        check=True,
        capture_output=True,
        text=True,
    )
    token = result.stdout.strip()
    if not token:
        raise RuntimeError("gcloud returned empty access token")
    return token


def run_query(token: str, structured_query: dict) -> list[dict]:
    url = f"{API_BASE}:runQuery"
    body = json.dumps({"structuredQuery": structured_query}).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=45) as resp:
        rows = json.loads(resp.read().decode("utf-8"))
    docs = []
    for row in rows:
        doc = row.get("document")
        if doc:
            docs.append(doc)
    return docs


def build_journal_payload(entries: list[JournalEntry], now_iso: str, today: str) -> list[tuple[str, dict]]:
    payloads: list[tuple[str, dict]] = []
    counters: dict[str, int] = {}

    for e in entries:
        cat_slug = _slug(e.category)
        counters.setdefault(cat_slug, 0)
        counters[cat_slug] += 1

        doc_id = f"journal-seed-v2-{cat_slug}-{counters[cat_slug]:02d}"
        fields = {
            "type": fs_string("journal_prompt"),
            "status": fs_string("published"),
            "isPublished": fs_bool(True),
            "category": fs_string(e.category),
            "title": fs_string(e.prompt),
            "prompt": fs_string(e.prompt),
            "sortOrder": fs_int(e.order),
            "createdAt": fs_timestamp(now_iso),
            "updatedAt": fs_timestamp(now_iso),
            "publishedAt": fs_timestamp(now_iso),
            "importDate": fs_string(today),
            "sourceDoc": fs_string(JOURNAL_DOC.name),
        }
        payloads.append((doc_id, fields))

    return payloads


def build_normal_payload(entries: list[NormalEntry], now_iso: str, today: str) -> list[tuple[str, dict]]:
    payloads: list[tuple[str, dict]] = []

    start_topic = 11
    for idx, e in enumerate(entries, start=0):
        topic_number = start_topic + idx
        doc_id = f"normal-topic-seed-v2-{topic_number:02d}"

        fields = {
            "type": fs_string("normal_topic"),
            "status": fs_string("published"),
            "isPublished": fs_bool(True),
            "category": fs_string("evening stress"),
            "question": fs_string(e.question),
            "title": fs_string(e.question),
            "answer": fs_string(e.answer),
            "body": fs_string(e.answer),
            "voices": fs_array_str(e.voices[:6]),
            "metooCount": fs_int(1204),
            "expertByline": fs_string("Resora Clinical Team"),
            "sortOrder": fs_int(topic_number),
            "legacyTopicLabel": fs_string(e.heading),
            "createdAt": fs_timestamp(now_iso),
            "updatedAt": fs_timestamp(now_iso),
            "publishedAt": fs_timestamp(now_iso),
            "importDate": fs_string(today),
            "sourceDoc": fs_string(NORMAL_DOC.name),
        }
        payloads.append((doc_id, fields))

    return payloads


def verify_counts(token: str) -> dict[str, int]:
    def _count_for_type(type_value: str) -> int:
        query = {
            "from": [{"collectionId": COLLECTION}],
            "where": {
                "fieldFilter": {
                    "field": {"fieldPath": "type"},
                    "op": "EQUAL",
                    "value": {"stringValue": type_value},
                }
            },
        }
        return len(run_query(token, query))

    return {
        "normal_topic": _count_for_type("normal_topic"),
        "journal_prompt": _count_for_type("journal_prompt"),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="perform Firestore writes")
    parser.add_argument("--verify-only", action="store_true", help="only run count verification")
    parser.add_argument("--token", default="", help="optional OAuth bearer token")
    args = parser.parse_args()

    if not JOURNAL_DOC.exists() or not NORMAL_DOC.exists():
        print("Missing source doc(s).")
        print(f"- journal: {JOURNAL_DOC}")
        print(f"- normal:  {NORMAL_DOC}")
        return 1

    now_iso = _now_iso()
    today = _today_str()

    if args.verify_only:
        token = args.token or get_access_token()
        counts = verify_counts(token)
        print(json.dumps({"verifyCounts": counts}, indent=2))
        return 0

    journal_entries = parse_journal_doc(JOURNAL_DOC)
    normal_entries = parse_normal_doc(NORMAL_DOC)

    journal_payload = build_journal_payload(journal_entries, now_iso, today)
    normal_payload = build_normal_payload(normal_entries, now_iso, today)

    print(json.dumps({
        "journalPromptsParsed": len(journal_entries),
        "normalTopicsParsed": len(normal_entries),
        "normalTopicRange": "11+ sequential based on parsed rows",
    }, indent=2))

    if not args.apply:
        print("Dry run only. Re-run with --apply to write to Firestore.")
        return 0

    token = args.token or get_access_token()

    written = 0
    errors: list[str] = []
    for doc_id, fields in [*normal_payload, *journal_payload]:
        try:
            firestore_patch(token, doc_id, fields)
            written += 1
        except urllib.error.HTTPError as err:
            details = err.read().decode("utf-8", errors="replace")
            errors.append(f"{doc_id}: HTTP {err.code} {details}")
        except Exception as err:  # pylint: disable=broad-except
            errors.append(f"{doc_id}: {err}")

    verify = verify_counts(token)

    print(json.dumps({
        "written": written,
        "errors": errors[:20],
        "errorCount": len(errors),
        "verifyCounts": verify,
    }, indent=2))

    return 0 if not errors else 2


if __name__ == "__main__":
    sys.exit(main())
