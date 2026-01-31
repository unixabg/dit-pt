# Use bash for consistent behavior (but avoid bash-only features anyway)
SHELL := /usr/bin/env bash

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
DESTDIR ?=

DIT_PT        ?= dit-pt
DIT_PT_REPORT ?= dit-pt-report

WORKDIR ?= /var/lib/dit-pt
SUDO    ?= sudo

NUCLEI_TEMPLATE_DIR := $(WORKDIR)/nuclei-templates

.DEFAULT_GOAL := help

.PHONY: help install uninstall deps nuclei templates check

help:
	@echo ""
	@echo "dit-pt Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make install        Install dit-pt and dit-pt-report"
	@echo "  make deps           Install OS dependencies"
	@echo "  make nuclei         Install nuclei binary (optional)"
	@echo "  make templates      Update nuclei templates (optional)"
	@echo "  make uninstall      Remove installed files"
	@echo "  make check          Check required tools"
	@echo ""
	@echo "Vars:"
	@echo "  PREFIX=/usr/local   Install prefix"
	@echo "  BINDIR=\$$PREFIX/bin"
	@echo "  DESTDIR=            Staging root (packaging)"
	@echo "  WORKDIR=/var/lib/dit-pt"
	@echo "  SUDO=sudo|''        Set to empty if already root"
	@echo ""

install:
	@echo "[*] Installing dit-pt..."
	$(SUDO) install -d -m 0755 "$(DESTDIR)$(BINDIR)"
	$(SUDO) install -m 0755 "$(DIT_PT)"        "$(DESTDIR)$(BINDIR)/dit-pt"
	$(SUDO) install -m 0755 "$(DIT_PT_REPORT)" "$(DESTDIR)$(BINDIR)/dit-pt-report"

	@echo "[*] Creating work directories..."
	$(SUDO) install -d -m 0755 "$(WORKDIR)"
	$(SUDO) install -d -m 0755 "$(WORKDIR)/logs" "$(WORKDIR)/reports" "$(WORKDIR)/targets" "$(WORKDIR)/nmap"

	@echo "[+] Installed successfully"

deps:
	@echo "[*] Installing dependencies..."
	@if command -v apt >/dev/null 2>&1; then \
		$(SUDO) apt update && $(SUDO) apt install -y \
			bash jq nmap tcpdump arp-scan \
			ca-certificates curl unzip gawk; \
	elif command -v dnf >/dev/null 2>&1; then \
		$(SUDO) dnf install -y \
			bash jq nmap tcpdump arp-scan \
			ca-certificates curl unzip gawk; \
	elif command -v pacman >/dev/null 2>&1; then \
		$(SUDO) pacman -Sy --noconfirm \
			bash jq nmap tcpdump arp-scan \
			ca-certificates curl unzip gawk; \
	else \
		echo "[-] Unsupported package manager. Install deps manually."; \
		exit 1; \
	fi
	@echo "[+] Dependencies installed"

# Optional: install nuclei binary
nuclei:
	@echo "[*] Installing nuclei..."
	@if command -v nuclei >/dev/null 2>&1; then \
		echo "[+] nuclei already installed"; \
	else \
		set -euo pipefail; \
		ARCH="$$(uname -m)"; \
		case "$$ARCH" in \
			x86_64|amd64)  PKG="linux_amd64.zip" ;; \
			aarch64|arm64) PKG="linux_arm64.zip" ;; \
			*) echo "[-] Unsupported arch: $$ARCH"; exit 1 ;; \
		esac; \
		TMP="$$(mktemp -d)"; \
		echo "[*] Downloading latest nuclei ($$PKG)..."; \
		URL="$$(curl -fsSL https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
			| jq -r '.assets[] | select(.name == "'$$PKG'") | .browser_download_url' \
			| head -n1)"; \
		test -n "$$URL"; \
		curl -fsSL "$$URL" -o "$$TMP/nuclei.zip"; \
		unzip -o "$$TMP/nuclei.zip" -d "$$TMP" >/dev/null; \
		$(SUDO) install -m 0755 "$$TMP/nuclei" "$(DESTDIR)$(BINDIR)/nuclei"; \
		rm -rf "$$TMP"; \
		echo "[+] nuclei installed"; \
	fi

# Optional: update nuclei templates
templates:
	@echo "[*] Installing nuclei templates..."
	@command -v nuclei >/dev/null || { echo "[-] nuclei not installed"; exit 1; }

	$(SUDO) mkdir -p $(NUCLEI_TEMPLATE_DIR)
	$(SUDO) nuclei -update-templates -templates $(NUCLEI_TEMPLATE_DIR)

	@echo "[+] Templates installed to $(NUCLEI_TEMPLATE_DIR)"


check:
	@echo "[*] Checking environment..."
	@command -v bash >/dev/null || { echo "Missing: bash"; exit 1; }
	@command -v jq >/dev/null || { echo "Missing: jq"; exit 1; }
	@command -v nmap >/dev/null || { echo "Missing: nmap"; exit 1; }
	@command -v tcpdump >/dev/null || { echo "Missing: tcpdump"; exit 1; }
	@command -v arp-scan >/dev/null || { echo "Missing: arp-scan (required)"; exit 1; }
	@command -v gawk >/dev/null || { echo "Missing: gawk (required)"; exit 1; }
	@command -v netdiscover >/dev/null || echo "Missing: netdiscover (optional)"
	@command -v nuclei >/dev/null || echo "Missing: nuclei (optional)"
	@echo "[+] Check complete"

uninstall:
	@echo "[*] Removing dit-pt..."
	$(SUDO) rm -f "$(DESTDIR)$(BINDIR)/dit-pt" "$(DESTDIR)$(BINDIR)/dit-pt-report"
	@echo "[+] Removed"

