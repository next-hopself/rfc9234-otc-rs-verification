# Strict Only to Customer (OTC) Verification on Route Server Sessions

`draft-ietf-idr-otc-rs-verification`

## Abstract

RFC 9234 requires an AS receiving a route from a lateral Peer to verify that the
Only to Customer (OTC) Attribute equals that Peer's AS number, but imposes no
equivalent requirement on a Route Server Client (RS-Client) receiving a route
from a Route Server (RS). Because an RS is always the apex of any path that
traverses it, a route leak that has transited an RS can be accepted without
detection.

This document updates RFC 9234 by adding one ingress rule: an RS-Client MUST
treat a route received from an RS as a route leak if its OTC value is not the
RS's AS number. The check is performed by the RS-Client alone and is therefore
effective even when the RS does not implement RFC 9234.

## The check

[RFC 9234][rfc9234] checks the OTC value on a route received from a lateral
Peer: the value must equal the Peer's AS number, or the route is a leak. It
makes no equivalent check on a route received from an RS.

A route server exists to redistribute routes between clients that peer laterally
through it, so a route reaching an RS-Client from an RS has just crossed that
lateral exchange and the RS is the apex of its path. Such a route must therefore
carry either no OTC Attribute or one equal to the RS's AS number. Any other
value names a different AS as the apex, which means a leak occurred earlier on
the path and the RS forwarded it on.

The draft adds this as ingress rule 3:

> If a route with the OTC Attribute is received from an RS (i.e., remote AS with
> an RS Role) and the Attribute has a value that is not equal to the remote
> (i.e., RS's) AS number, then it is a route leak and MUST be considered
> ineligible.

Rules 1 and 2 are unchanged, rule 3 of RFC 9234 becomes rule 4, and the egress
procedure is unchanged.

## Building

```sh
make setup    # one-time: creates .venv with xml2rfc
make          # builds .txt and .html
make check    # offline checks (line length, non-ASCII)
make idnits   # submits the .txt to IETF author-tools
```

Reference metadata is embedded in the draft so its XML can be submitted
directly to the IETF Datatracker and built offline. BibXML snapshots are
vendored under `refs/`; refresh them with `make refs`.

## Scope

The document is scoped `Updates: 9234`, not `Obsoletes: 9234`. It specifies a
single delta to the ingress procedure rather than replacing RFC 9234. If it is
later respun as a full replacement, the header and the Section 5 framing need to
change.

[rfc9234]: https://www.rfc-editor.org/rfc/rfc9234.html
