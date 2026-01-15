# CLEAN CORE TRACE
time: 2026-01-15 12:53:38 EET

core:
- heartbeat: /home/arc/GENESIS/bin/genesis_poe_heartbeat.sh
- weekly proof: /home/arc/GENESIS/bin/genesis_poe_proof_week.sh
- status: /home/arc/GENESIS/bin/genesis_poe_status.sh
- metrics: /home/arc/GENESIS/VAULT/_METRICS/poe_metrics.csv

systemd:
- /home/arc/.config/systemd/user/genesis-poe-heartbeat.service
- /home/arc/.config/systemd/user/genesis-poe-heartbeat.timer
- /home/arc/.config/systemd/user/genesis-poe-proof-week.service
- /home/arc/.config/systemd/user/genesis-poe-proof-week.timer
