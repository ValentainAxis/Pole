# QUALITY_DAY (POROG v3) — with Temperature
Paths:
- Logs:   /home/arc/GENESIS/VAULT/_POROG_V3/QUALITY_DAY/logs/YYYY-MM-DD.md
- State:  /home/arc/GENESIS/VAULT/_POROG_V3/QUALITY_DAY/state/last_state.env
- Temp:   /home/arc/GENESIS/VAULT/_POROG_V3/QUALITY_DAY/temperature_calc.sh
- Binary: /home/arc/GENESIS/bin/porog-quality-day

Manual (interactive):
  /home/arc/GENESIS/bin/porog-quality-day

Silent (auto):
  /home/arc/GENESIS/bin/porog-quality-day --auto

Timer:
  systemctl --user status porog-quality-day.timer
  systemctl --user list-timers --all | grep porog-quality-day || true

View today's log:
  less -R "/home/arc/GENESIS/VAULT/_POROG_V3/QUALITY_DAY/logs/$(date +%F).md"
