# GENESIS — DIAG REPORT (facts-first)

time: 2026-01-15 01:23:05 EET
boot_id: dc6ef132-0b84-41d8-a977-4e8f7cef7110
uptime_s: 1324

---

## 1) System facts
- OS: Linux Mint 21.3
Linux Mint 21.3 | head -n 1
- Kernel: Linux Studio 5.15.0-164-generic #174-Ubuntu SMP Fri Nov 14 20:25:16 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
- RAM: 2.4Gi/7.7Gi
- Home disk: 113G free (75% used)
- GPU (best-effort): NVIDIA GeForce GTX 1050 Ti, 535.274.02, 4096 MiB | head -n 1
- Top RSS: chromium(659MB) telegram-deskto(383MB) chromium(301MB) chromium(268MB) chromium(263MB) chromium(249MB) chromium(210MB) 

## 2) Services facts
- ollama (system): active
- ollama endpoint (127.0.0.1:11434): ok
- docker.socket (system): active
- docker (system): inactive
- waydroid-container (system): inactive
- chronist timer (user): active
- chronist service (user): inactive

## 3) Binaries & versions (best-effort)
- godot: /usr/local/bin/godot
  - version: 4.3.stable.official.77dcf97d8
- blender: /usr/local/bin/blender
  - version: Blender 4.2.3 LTS
- ollama: /usr/local/bin/ollama
  - version: ollama version is 0.13.5
- docker: /usr/bin/docker
  - version: Docker version 28.2.2, build 28.2.2-0ubuntu1~22.04.1
- obsidian appimage (Downloads): /home/arc/Downloads/Obsidian.AppImage

## 4) GENESIS structure (exists / key files)
- GENESIS dir: /home/arc/GENESIS (exists: yes)
- VAULT dir: /home/arc/GENESIS/VAULT (exists: yes)
- TRACES dir: /home/arc/GENESIS/VAULT/_TRACES (exists: yes)
- TECH dir: /home/arc/GENESIS/VAULT/_TECH (exists: yes)
- OPEN dir: /home/arc/GENESIS/VAULT/_OPEN (exists: yes)
- BIN dir: /home/arc/GENESIS/bin (exists: yes)

### Canon/Entry files
- START.md: /home/arc/GENESIS/VAULT/START.md (exists: yes)
- MIRROR_SPEC.md: /home/arc/GENESIS/VAULT/_CORE/MIRROR_SPEC.md (exists: yes)
- MIRROR_IN.md: /home/arc/GENESIS/VAULT/_OPEN/MIRROR_IN.md (exists: yes)
- GODOT_DEFAULT_KEYS.md: /home/arc/GENESIS/VAULT/_CORE/_KEYS/GODOT_DEFAULT_KEYS.md (exists: yes)

### Runtime scripts
- mirror.sh: /home/arc/GENESIS/bin/mirror.sh (exists: yes, executable: yes)
- chronist.sh: /home/arc/GENESIS/bin/chronist.sh (exists: yes, executable: yes)
- genesis entry: /home/arc/.local/bin/genesis

## 5) Projects facts
- PROJECTS dir: /home/arc/GENESIS/PROJECTS (exists: yes)

### Latest SEED (auto)
- latest_seed_dir: /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215
- latest_seed_name: SEED_GODOT_20260114_2215
- seed_godot_dir: /home/arc/GENESIS/PROJECTS/SEED_GODOT_20260114_2215/godot
- seed_trace_main: /home/arc/GENESIS/VAULT/_TRACES/SEED_GODOT_20260114_2215.md (exists: yes)
- seed_guardrails: /home/arc/GENESIS/VAULT/_TRACES/SEED_GODOT_20260114_2215_GUARDRAILS.md (exists: yes)

### Seed file facts (if present)
- project.godot: yes
- Main.tscn: yes
- Pulse3D.tscn: yes
- Main.gd: yes
- Pulse3D.gd: yes

## 6) Desktop facts
- Desktop dir: /home/arc/Desktop (exists: yes)
- Desktop file count: 5

### Desktop listing (top 50)
```
Codec_Project
Flameshot.desktop
GRABLI-2.desktop
Launch_Forge.sh
Run_UE_Houdini.sh
Run_UE_Light.sh
```

## 7) Traces facts
- Traces file count: 14

### Traces listing (top 30 by ls -t)
```
CHRONIST_2026-01-15.md
_CHRONIST.md
SEED_GODOT_20260114_2215_2026-01-15_00-56-13.md
SEED_GODOT_20260114_2215_LAST.md
SEED_GODOT_20260114_2215_2026-01-15_00-54-33.md
SEED_GODOT_20260114_2215_GUARDRAILS.md
SEED_GODOT_20260114_2215.md
SEED_GODOT_20260114_2215_2026-01-15_00-09-24.md
SEED_GODOT_20260114_2215_2026-01-14_23-51-59.md
SEED_GODOT_20260114_2215_2026-01-14_23-47-36.md
SEED_GODOT_20260114_2215_2026-01-14_23-41-57.md
SEED_GODOT_20260114_2215_2026-01-14_23-41-24.md
ENTRY_LAST.md
ENTRY_2026-01-14_22-33-14.md
ENTRY_2026-01-14_22-30-11.md
```

## 8) Chronist output (head/tail)
- main: file:///home/arc/GENESIS/VAULT/_TRACES/_CHRONIST.md (exists: yes)
- today: file:///home/arc/GENESIS/VAULT/_TRACES/CHRONIST_2026-01-15.md (exists: yes)
- state: file:///home/arc/GENESIS/VAULT/_TECH/_chronist/state.env (exists: yes)

### _CHRONIST.md (first 80 lines)
```

# BOOT :: 2026-01-15 00:52:04 EET
- boot_id: ce21a4c8-c349-46e7-ad61-8b4f9ef7c7f8
- uptime_s: 18606
- ram: 
- home: 112G free
- services: ollama=active docker.socket=active docker=inactive
n/a waydroid=inactive
n/a
- hint: file:///home/arc/GENESIS/VAULT/START.md

## SESSION :: Godot :: 2026-01-15 00:52:04 EET
- state: started

### PULSE :: 2026-01-15 00:52:04 EET
- uptime_s: 18606
- ram: 
- home: 112G free
- apps: godot=1 blender=0 obsidian=0
- services: ollama=active docker.socket=active docker=inactive
n/a waydroid=inactive
n/a
- top_rss: godot(933MB) chromium(549MB) chromium(542MB) chromium(436MB) godot(343MB) 

### PULSE :: 2026-01-15 00:54:33 EET
- uptime_s: 18756
- ram: 4.1Gi/7.7Gi
- home: 112G free
- apps: godot=1 blender=0 obsidian=0
- services: ollama=active docker.socket=active docker=inactive waydroid=inactive
- top_rss: godot(933MB) chromium(723MB) chromium(541MB) chromium(426MB) godot(343MB) 

### PULSE :: 2026-01-15 00:57:04 EET
- uptime_s: 18906
- ram: 4.2Gi/7.7Gi
- home: 112G free
- apps: godot=1 blender=0 obsidian=0
- services: ollama=active docker.socket=active docker=inactive waydroid=inactive
- top_rss: godot(933MB) chromium(701MB) ollama(667MB) chromium(532MB) chromium(437MB) 

# BOOT :: 2026-01-15 01:01:47 EET
- boot_id: dc6ef132-0b84-41d8-a977-4e8f7cef7110
- uptime_s: 45
- ram: 1.3Gi/7.7Gi
- home: 112G free
- services: ollama=active docker.socket=active docker=inactive waydroid=inactive
- hint: file:///home/arc/GENESIS/VAULT/START.md

## SESSION :: Godot :: 2026-01-15 01:01:47 EET
- state: ended

### PULSE :: 2026-01-15 01:01:47 EET
- uptime_s: 45
- ram: 1.3Gi/7.7Gi
- home: 112G free
- apps: godot=0 blender=0 obsidian=0
- services: ollama=active docker.socket=active docker=inactive waydroid=inactive
- top_rss: telegram-deskto(383MB) chromium(137MB) Xorg(114MB) chromium(113MB) xfwm4(86MB) 

### PULSE :: 2026-01-15 01:06:48 EET
- uptime_s: 346
- ram: 2.2Gi/7.7Gi
- home: 112G free
- apps: godot=0 blender=0 obsidian=0
- services: ollama=active docker.socket=active docker=inactive waydroid=inactive
- top_rss: chromium(513MB) telegram-deskto(383MB) chromium(297MB) chromium(280MB) chromium(263MB) 

### PULSE :: 2026-01-15 01:11:50 EET
- uptime_s: 648
- ram: 2.3Gi/7.7Gi
- home: 112G free
- apps: godot=0 blender=0 obsidian=0
- services: ollama=active docker.socket=active docker=inactive waydroid=inactive
- top_rss: chromium(584MB) telegram-deskto(383MB) chromium(299MB) chromium(269MB) chromium(264MB) 

### PULSE :: 2026-01-15 01:16:51 EET
- uptime_s: 949
- ram: 2.3Gi/7.7Gi
- home: 113G free
- apps: godot=0 blender=0 obsidian=0
```

---

## 9) Cross-checks (facts-derived)
- Guardrails injection: проверяется наличием блока [GUARDRAILS_SNIP] в последнем MIRROR trace.
- F5/F6 переключатель: считается зафиксированным, если guardrails проекта содержит эту строку.
- “Истина запуска”: считается зафиксированной, если в trace проекта есть путь реального бинарника (например /usr/local/bin/godot).
- “Автопамять”: считается живой, если Chronist пишет BOOT и PULSE в CHRONIST_YYYY-MM-DD.md.

## 10) Observations (коротко)
- Этот отчёт построен только из файлов/статусов, без предположений.
- Следующий шаг диагностики обычно: открыть этот файл и глазами пройти разделы 4–8, затем решить, что считать каноном “по умолчанию”.

