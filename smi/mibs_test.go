// Copyright (c) 2019 David R. Halliday. All rights reserved.
//
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

package smi_test

import (
	"fmt"
	"log"
	"testing"

	"github.com/hallidave/mibtool/smi"
)

func TestLoadModules(t *testing.T) {
	mib := smi.NewMIB("testdata")
	err := mib.LoadModules()
	if err != nil {
		t.Error(err)
	}

	expectedNum := 14
	num := len(mib.Modules)
	if num != expectedNum {
		t.Error("expected", expectedNum, ", got", num)
	}
}

func TestLoadTwice(t *testing.T) {
	mib := smi.NewMIB("testdata")
	err := mib.LoadModules("HOST-RESOURCES-MIB")
	if err != nil {
		t.Error(err)
	}
	err = mib.LoadModules("BGP4-MIB")
	if err != nil {
		t.Error(err)
	}
	oid, err := mib.OID("bgpPeerIdentifier.1")
	if err != nil {
		t.Fatal(err)
	}
	if !oid.Equal(smi.OID{1, 3, 6, 1, 2, 1, 15, 3, 1, 1, 1}) {
		t.Error("not equal:" + oid.String())
	}

	oid, err = mib.OID("hrSystemProcesses")
	if err != nil {
		t.Fatal(err)
	}
	if !oid.Equal(smi.OID{1, 3, 6, 1, 2, 1, 25, 1, 6}) {
		t.Error("not equal:" + oid.String())
	}

}

func TestSymbolLookup(t *testing.T) {
	mib := smi.NewMIB("testdata")
	err := mib.LoadModules("SNMPv2-MIB")
	if err != nil {
		t.Error(err)
	}
	sysDescrOID := smi.OID{1, 3, 6, 1, 2, 1, 1, 1, 0}
	s, i := mib.Symbol(sysDescrOID)
	if s == nil {
		t.FailNow()
	}
	if s.Module.Name != "SNMPv2-MIB" {
		t.Fail()
	}
	if s.Name != "sysDescr" {
		t.Error(s)
	}
	if len(i) != 1 || i[0] != 0 {
		t.Error(s)
	}
}

func TestSymbolString(t *testing.T) {
	tests := []struct {
		oid      smi.OID
		expected string
	}{
		{smi.OID{}, ""},
		{smi.OID{1}, "iso"},
		{smi.OID{1, 1}, "iso.1"},
		{smi.OID{1, 3}, "SNMPv2-SMI::org"},
		{smi.OID{1, 3, 6, 1, 2, 1, 1, 1, 0}, "SNMPv2-MIB::sysDescr.0"},
		{smi.OID{1, 3, 6, 1, 2, 1, 15, 1}, "BGP4-MIB::bgpVersion"},
		{smi.OID{1, 3, 6, 1, 2, 1, 15, 3, 1, 1, 1}, "BGP4-MIB::bgpPeerIdentifier.1"},
	}

	mib := smi.NewMIB("testdata")
	err := mib.LoadModules("SNMPv2-MIB", "BGP4-MIB")
	if err != nil {
		t.Error(err)
	}

	for _, test := range tests {
		result := mib.SymbolString(test.oid)
		if result != test.expected {
			t.Errorf("got %s, expected %s", result, test.expected)
		}
	}
}

func TestOID(t *testing.T) {
	tests := []struct {
		in       string
		expected smi.OID
	}{
		{"1.3.6.1.2.1.2", smi.OID{1, 3, 6, 1, 2, 1, 2}},
		{"IF-MIB::ifTable.1.2.3", smi.OID{1, 3, 6, 1, 2, 1, 2, 2, 1, 2, 3}},
		{"IF-MIB::ifTable", smi.OID{1, 3, 6, 1, 2, 1, 2, 2}},
		{"ifTable", smi.OID{1, 3, 6, 1, 2, 1, 2, 2}},
		{"sysDescr.0", smi.OID{1, 3, 6, 1, 2, 1, 1, 1, 0}},
		{"IF-MIB::1.3.6.1.2.1.2", nil},
		{"IF-MIB::sysDescr.0", nil},
		{"foo", nil},
		{"foo.1", nil},
		{"FOO::", nil},
		{"IF-MIB::foo", nil},
	}

	mib := smi.NewMIB("testdata")
	err := mib.LoadModules("IF-MIB")
	if err != nil {
		t.Error(err)
	}

	for _, test := range tests {
		result, err := mib.OID(test.in)
		if err != nil {
			if test.expected != nil {
				t.Error(err)
			}
		}
		if !result.Equal(test.expected) {
			t.Errorf("got %s, expected %s", result, test.expected)
		}
	}
}

func TestLoadAll(t *testing.T) {
	mib := smi.NewMIB("testdata")
	mib.Debug = false
	err := mib.LoadModules()
	if err != nil {
		t.Error(err)
		t.FailNow()
	}
}

func BenchmarkLoadIFMIB(b *testing.B) {
	for i := 0; i < b.N; i++ {
		mib := smi.NewMIB("testdata")
		err := mib.LoadModules("IF-MIB")
		if err != nil {
			b.Error(err)
		}
	}
}

func BenchmarkResolveOID(b *testing.B) {
	mib := smi.NewMIB("testdata")
	err := mib.LoadModules("IF-MIB")
	if err != nil {
		b.Error(err)
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		oid, err := mib.OID("IF-MIB::ifTable.1.1")
		if err != nil {
			b.Error(err)
		}
		if len(oid) != 10 {
			b.Error("not 10")
		}
	}
}

func ExampleMIB_VisitSymbols() {
	mib := smi.NewMIB("testdata")
	mib.Debug = true
	err := mib.LoadModules("SNMPv2-SMI")
	if err != nil {
		log.Fatal(err)
	}
	mib.VisitSymbols(func(sym *smi.Symbol, oid smi.OID) {
		fmt.Printf("%-40s %s\n", sym, oid)
	})
	//Output:
	//SNMPv2-SMI::org                          1.3
	//SNMPv2-SMI::dod                          1.3.6
	//SNMPv2-SMI::internet                     1.3.6.1
	//SNMPv2-SMI::directory                    1.3.6.1.1
	//SNMPv2-SMI::mgmt                         1.3.6.1.2
	//SNMPv2-SMI::mib-2                        1.3.6.1.2.1
	//SNMPv2-SMI::transmission                 1.3.6.1.2.1.10
	//SNMPv2-SMI::experimental                 1.3.6.1.3
	//SNMPv2-SMI::private                      1.3.6.1.4
	//SNMPv2-SMI::enterprises                  1.3.6.1.4.1
	//SNMPv2-SMI::security                     1.3.6.1.5
	//SNMPv2-SMI::snmpV2                       1.3.6.1.6
	//SNMPv2-SMI::snmpDomains                  1.3.6.1.6.1
	//SNMPv2-SMI::snmpProxys                   1.3.6.1.6.2
	//SNMPv2-SMI::snmpModules                  1.3.6.1.6.3
}

func ExampleMIB_OID() {
	mib := smi.NewMIB("testdata")
	err := mib.LoadModules("IF-MIB")
	if err != nil {
		log.Fatal(err)
	}

	examples := []string{
		"ifTable", "IF-MIB::ifIndex",
		"ifType.3", "IF-MIB::ifOperStatus.4",
	}
	for _, example := range examples {
		oid, err := mib.OID(example)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(oid.String())
	}
	//Output:
	//1.3.6.1.2.1.2.2
	//1.3.6.1.2.1.2.2.1.1
	//1.3.6.1.2.1.2.2.1.3.3
	//1.3.6.1.2.1.2.2.1.8.4
}
