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
- gawk
- jq
- nmap
- tcpdump
- arp-scan
- dhclient (needed for `--dhcp`; Debian package `isc-dhcp-client`)
- netdiscover (optional, recommended)
- nuclei (optional, recommended)

On Debian:

```bash
make deps        # OS packages
make nuclei      # nuclei binary (optional)
make templates   # nuclei templates into /var/lib/dit-pt/nuclei-templates
make check
sudo make install
```

---

## 🚀 Usage

### Discover VLANs
```bash
sudo ./dit-pt vlans --iface eth0 --secs 30
```

### Scan one VLAN
```bash
sudo ./dit-pt run --vlan 30 --iface eth0 --dhcp
sudo ./dit-pt run --vlan 99 --iface eth0 --static 10.99.0.250/24 --gw 10.99.0.1
```

### Scan the VLANs you are authorized to test
```bash
sudo ./dit-pt run --auto --iface eth0 --secs 30 --allow-vlans 20,30,52
```

Every run ends with `COVERAGE` lines naming anything that was **not** scanned:
allow-listed VLANs that were quiet during the sniff (add `--scan-unseen`),
VLANs cut by `--max-vlans`, VLANs with no DHCP lease, and nuclei failures.

### Re-run nuclei on saved targets
```bash
sudo ./dit-pt run --replay 20260129-161131
```

### Report
```bash
./dit-pt-report --in /var/lib/dit-pt/reports/nuclei-30-20260129-161131.jsonl --out-dir ./reports
```

See `dit-pt --help` for all options and `dit-pt-cheatsheet.txt` for examples
by risk profile.

---

## ⚠️ Authorization

VLAN discovery is passive. Joining a VLAN and scanning it is active.
Only run `dit-pt` on networks you are authorized to test.
