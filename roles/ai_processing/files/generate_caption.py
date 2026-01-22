#!/usr/bin/env python3
import sys
import subprocess
import base64
import requests
import tempfile
import os
from pathlib import Path

MODEL = "qwen2.5vl:7b"
OLLAMA_URL = "http://127.0.0.1:11434/api/chat"

DEFAULT_TEXT = "편집된 영상"

PROMPT = (
    "이 이미지를 보고 "
    "영상 썸네일에 쓸 짧은 한국어 제목을 만들어라. "
    "최대 15자. 설명 금지. 문장부호 금지."
)

def ollama_chat(image_b64: str, timeout=120) -> str:
    payload = {
        "model": MODEL,
        "messages": [
            {
                "role": "user",
                "content": PROMPT,
                "images": [image_b64]
            }
        ],
        "stream": False,
        "options": {
            "temperature": 0.6,
            "num_predict": 20
        }
    }

    r = requests.post(OLLAMA_URL, json=payload, timeout=timeout)
    r.raise_for_status()

    data = r.json()
    # 👇 여기 중요
    return (data.get("message", {}).get("content") or "").strip()


def sanitize(text: str) -> str:
    for c in ["\n", "\r", "'", '"', "(", ")", "[", "]", "#", "*", ":", "."]:
        text = text.replace(c, "")
    return text.strip()


def main():
    if len(sys.argv) != 2:
        print(DEFAULT_TEXT)
        return

    video = Path(sys.argv[1])
    if not video.exists():
        print(DEFAULT_TEXT)
        return

    fd, frame_path = tempfile.mkstemp(suffix=".jpg")
    os.close(fd)
    frame = Path(frame_path)

    try:
        # 1️⃣ 프레임 추출 (저해상도)
        subprocess.run(
            [
                "ffmpeg", "-y",
                "-ss", "00:00:01",
                "-i", str(video),
                "-vf", "scale=320:-1",
                "-frames:v", "1",
                "-q:v", "10",
                str(frame)
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        if not frame.exists() or frame.stat().st_size == 0:
            print(DEFAULT_TEXT)
            return

        img_b64 = base64.b64encode(frame.read_bytes()).decode()

        # 2️⃣ qwen2.5vl 호출
        caption = ollama_chat(img_b64)
        caption = sanitize(caption)

        print(caption if caption else DEFAULT_TEXT)

    except Exception as e:
        print(DEFAULT_TEXT)

    finally:
        try:
            frame.unlink()
        except Exception:
            pass


if __name__ == "__main__":
    main()
