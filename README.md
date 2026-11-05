# 🩺 wsl-doctor

**Diagnostic, Benchmark & Auto-Tuning CLI for WSL2, Windows Host Networking & AI Coding Agents (Claude Code, Antigravity, Cursor)**

[![CI](https://github.com/omatheusgit/wsl-doctor/actions/workflows/ci.yml/badge.svg)](https://github.com/omatheusgit/wsl-doctor/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-22C55E.svg)](LICENSE)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-3776AB.svg)](https://www.python.org/)

---

## Why `wsl-doctor`?

Developers running **WSL2**, **Docker/K3d**, and **AI Agents** (Claude Code, Google Antigravity, MCP servers) on 8 GB – 32 GB Windows laptops frequently hit silent performance bottlenecks:

1. **ISP Router DNS Stalls (1,000+ ms per lookup)**: Default NAT DNS proxying to home routers often adds 1+ second latency to every `git`, `pip`, `npm`, or LLM API call.
2. **Aggressive Kernel Swapping (`vm.swappiness=60`) & VFS Cache Eviction (`vm.vfs_cache_pressure=100`)**: Causes premature disk thrashing and slow `git status` on large repositories.
3. **Suboptimal TCP Congestion Control (`cubic` over Wi-Fi)**: Switching to **Google TCP BBR (`bbr` + `fq`)** drastically improves throughput and tail latency on wireless links.
4. **Unbounded `vmmemWSL` Memory Usage**: Missing `.wslconfig` rules (`autoMemoryReclaim=gradual`, `sparseVhd=true`, `dnsTunneling=true`) starve the Windows host.

`wsl-doctor` diagnoses these bottlenecks in **< 50ms**, scores your environment (`0–100`), generates a mathematically calibrated `.wslconfig`, and provides automated kernel + Windows PowerShell remediation scripts.

---

## Quick Start

```bash
# 1. Run full health & AI-agent readiness audit
python3 wsl_doctor.py check

# 2. Emit JSON output (ideal for AI agents and statuslines)
python3 wsl_doctor.py check --json

# 3. Generate an optimal .wslconfig for an 8 GB RAM / 4 vCPU laptop
python3 wsl_doctor.py generate-wslconfig --ram-gb 8 --cpus 4 --out /mnt/c/Users/$USER/.wslconfig
```

### Example Output

```text
🩺 wsl-doctor — System Health & AI Agent Readiness Report
Host: edge-wsl | Kernel: 6.18.54.1-microsoft-standard-WSL2 | Score: 100/100
----------------------------------------------------------------------------
✅ [PASS] Kernel VM Swappiness (Memory)
    Current: 15 | Target: 10-20
✅ [PASS] VFS Inode/Dentry Cache Retention (Filesystem)
    Current: 50 | Target: 50
✅ [PASS] TCP Congestion Control & Queue Discipline (Network)
    Current: bbr (qdisc=fq) | Target: bbr (qdisc=fq)
✅ [PASS] WSL2 Memory & Swap Allocation (Memory)
    Current: 3.70 GiB RAM / 1.00 GiB Swap | Target: >= 4.0 GiB RAM / 2.0 GiB Swap
✅ [PASS] DNS Resolution Latency (github.com) (Network)
    Current: 8.12 ms | Target: < 50 ms (Cloudflare 1.1.1.1 / Google 8.8.8.8)
✅ [PASS] Windows Host .wslconfig Profile (Configuration)
    Current: /mnt/c/Users/cabelim/.wslconfig | Target: Present with pageReporting, autoMemoryReclaim=gradual
----------------------------------------------------------------------------
```

---

## Windows Wi-Fi & DNS Optimizer (`scripts/Optimize-WindowsWifiAndDns.ps1`)

Included PowerShell script tunes your Windows wireless adapter (5 GHz preference, MIMO SMPS disabled, Throughput Booster enabled) and switches DNS from slow ISP gateways to Cloudflare (`1.1.1.1`) + Google (`8.8.8.8`).

## License

MIT © [Matheus Santana](https://github.com/omatheusgit)
