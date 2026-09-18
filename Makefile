DRAFT   := draft-herdes-idr-otc-rs-verification-01
VENV    := .venv
XML2RFC := $(VENV)/bin/xml2rfc
PYTHON  ?= python3

# BibXML snapshots are vendored under refs/ and refreshed with `make refs`.
# Used references are embedded in the draft so local and IETF builds need no
# local-file or network access.
REFS := 2119 4271 4272 5398 6793 7606 7705 7908 7947 8174 9234
BIBXML := https://bib.ietf.org/public/rfc/bibxml

.PHONY: all txt html clean distclean refs idnits check setup

all: txt html

setup: $(XML2RFC)

$(XML2RFC):
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --quiet --upgrade pip xml2rfc

txt: $(DRAFT).txt
html: $(DRAFT).html

$(DRAFT).txt: $(DRAFT).xml $(XML2RFC)
	$(XML2RFC) --text $<

$(DRAFT).html: $(DRAFT).xml $(XML2RFC)
	$(XML2RFC) --html $<

# Re-fetch the vendored bibxml references.
refs:
	mkdir -p refs
	@for n in $(REFS); do \
		echo "fetching RFC $$n"; \
		curl -sSf -o refs/reference.RFC.$$n.xml $(BIBXML)/reference.RFC.$$n.xml || exit 1; \
	done

# Submit the built text to the IETF author-tools idnits service.
idnits: $(DRAFT).txt
	@curl -sS -m 180 -X POST -F "file=@$(DRAFT).txt" \
		https://author-tools.ietf.org/api/idnits | sed -n '1,45p'

# Local sanity checks that do not need the network.
check: $(DRAFT).txt
	@echo "== lines longer than 72 columns =="
	@awk 'length>72 {c++; print NR": "length} END{printf "  count: %d\n", c+0}' $(DRAFT).txt
	@echo "== non-ASCII bytes (form feed \\f is expected) =="
	@LC_ALL=C tr -d '\11\12\40-\176' < $(DRAFT).txt | od -c \
		| awk '{for(i=2;i<=NF;i++) if($$i!="") print $$i}' | sort -u | sed 's/^/  /'

clean:
	rm -f $(DRAFT).txt $(DRAFT).html

distclean: clean
	rm -rf $(VENV)
