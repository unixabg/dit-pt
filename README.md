# dit-pt

**Defensive Infrastructure Testing — Passive-first Testing & Network Assessment**

`dit-pt` is a lightweight Bash-based tool for safely inspecting network segments,
discovering active hosts, and identifying exposed services using a non-intrusive workflow.

It is designed for:
- K–12 environments
- IT administrators
- Blue teams
- Network hygiene audits

---

## ✨ Features

- Passive VLAN discovery
- Safe DHCP-based network enumeration
- Host discovery (ARP / Nmap)
- Scoped port scanning
- Nuclei-based exposure checks
- Markdown + CSV reporting
- No exploitation or brute forcing
- Designed for unattended operation

---

## 🧠 Philosophy

`dit-pt` is **not** a penetration testing framework.

It is intended to answer:

> “What is visible and potentially misconfigured on this network?”

It does **not**:
- exploit vulnerabilities
- brute-force services
- perform denial-of-service tests
- attempt privilege escalation

---

## 📦 Requirements

- bash
- jq
- nmap
- tcpdump
- arp-scan
- netdiscover
- nuclei (optional, recommended)

---

## 🚀 Usage

### Discover VLANs
```bash
sudo ./dit-pt.sh vlans --iface eth0
