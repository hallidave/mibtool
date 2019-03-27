# SNMP MIB Parser for Go

The `go-smi` module contains packages for parsing SNMP MIBs and querying
the information contained in them.

The information that can currently be extracted from MIBs is limited to
symbol information and OIDs, but the intention is to extend the code
to make more information available.

## Installation

    go get github.com/hallidave/go-smi/mibs

## Examples

	mib := mibs.NewMIB("/usr/share/snmp/mibs/iana", "/usr/share/snmp/mibs/ietf")
	mib.Debug = true
	err := mib.LoadModules("IF-MIB")
	if err != nil {
		log.Fatal(err)
	}

	// Walk all symbols in MIB
	mib.VisitSymbols(func(sym *smi.Symbol, oid smi.OID) {
		fmt.Printf("%-40s %s\n", sym, oid)
	})

    // Look up OID for an OID string
    oid, err := mib.OID("IF-MIB::ifOperStatus.4")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(oid.String())
