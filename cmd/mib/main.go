package main

import (
	"fmt"
	"github.com/hallidave/mibtool/smi"
	"os"
	"os/user"
	"path/filepath"
)

func userMibDir() string {
	usr, err := user.Current()
	if err != nil {
		panic(err)
	}
	defaultDir, err := filepath.Abs(filepath.Join(usr.HomeDir, ".snmp", "mibs"))
	if err != nil {
		panic(err)
	}
	return defaultDir
}

func dumpModule(mib *smi.MIB, modName string) {
	mib.VisitSymbols(func(sym *smi.Symbol, oid smi.OID) {
		if sym.Module.Name == modName {
//			fmt.Printf("%-40s %s\n", sym, oid)
			fmt.Printf("%-40s %-30s %-16s %s\n", sym, oid, sym.Node.Syntax, sym.Node.Description)
		}
	})
}

func dumpModules(mib *smi.MIB, modNames []string) {
	mib.VisitSymbols(func(sym *smi.Symbol, oid smi.OID) {
		for _, str := range modNames {
			if sym.Module.Name == str {
				fmt.Printf("%-40s %-30s %-16s %s\n", sym, oid, sym.Node.Syntax, sym.Node.Description)
				break
			}
		}
	})
}

func main() {
	if len(os.Args) < 3 || os.Args[1] != "dump" {
		fmt.Printf("Usage: %v dump [module]\n", os.Args[0])
		os.Exit(1)
	}

	modulenames := []string{}
	for i := 2; i < len(os.Args); i++ {
		modulenames = append(modulenames, os.Args[i])
	}

	mib := smi.NewMIB(userMibDir())
//	err := mib.LoadModules(os.Args[2])
	err := mib.LoadModules(modulenames...)
	if err != nil {
		fmt.Println(err)
	}
//	dumpModule(mib, os.Args[2])
	dumpModules(mib, modulenames)
}
