PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

DIT_PT = dit-pt
DIT_PT_REPORT = dit-pt-report

.PHONY: help install uninstall deps nuclei check

help:
	@echo ""
	@echo "dit-pt Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make install        Install dit-pt and dit-pt-report"
	@echo "  make deps           Install OS dependencies"
	@echo "  make nuclei         Install nuclei (optional)"
	@echo "  make uninstall      Remove installed files"
	@echo "  make check          Check required tools"
	@echo ""

install:
	@echo "[*] Installing dit-pt..."
	install -m 0755 $(DIT_PT) $(BINDIR)/dit-pt
	install -m 0755 $(DIT_PT_REPORT) $(BINDIR)/dit-pt-report
	@echo "[+] Installed to $(BINDIR)"

deps:
	@echo "[*] Installing dependencies..."
	@if command -v apt >/dev/null 2>&1; then \
		sudo apt update && sudo apt install -y \
			bash \
			jq \
			nmap \
			tcpdump \
			ca-certificates \
			curl; \
	elif command -v dnf >/dev/null 2>&1; then \
		sudo dnf install -y \
			bash \
			jq \
			nmap \
			tcpdump \
			ca-certificates \
			curl; \
	else \
		echo "[-] Unsupported package manager. Install deps manually."; \
	fi

nuclei:
	@echo "[*] Installing nuclei..."
	@if command -v nuclei >/dev/null 2>&1; then \
		echo "[+] nuclei already installed"; \
	else \
		echo "[*] Downloading nuclei..."; \
		curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
		| jq -r '.assets[] | select(.name | test("linux_amd64.zip")) | .browser_download_url' \
		| xargs -n1 curl -L -o /tmp/nuclei.zip; \
		unzip -o /tmp/nuclei.zip -d /tmp; \
		sudo install -m 0755 /tmp/nuclei $(BINDIR)/nuclei; \
		rm -f /tmp/nuclei /tmp/nuclei.zip; \
	fi
	@echo "[*] Installing nuclei templates..."
	nuclei -update-templates

check:
	@echo "[*] Checking environment..."
	@command -v bash >/dev/null || echo "Missing: bash"
	@command -v jq >/dev/null || echo "Missing: jq"
	@command -v nmap >/dev/null || echo "Missing: nmap"
	@command -v tcpdump >/dev/null || echo "Missing: tcpdump"
	@command -v nuclei >/dev/null || echo "Missing: nuclei (optional)"
	@echo "[+] Check complete"

uninstall:
	@echo "[*] Removing dit-pt..."
	rm -f $(BINDIR)/dit-pt
	rm -f $(BINDIR)/dit-pt-report
	@echo "[+] Removed"

