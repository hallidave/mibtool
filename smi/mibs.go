// Copyright (c) 2019 David R. Halliday. All rights reserved.
//
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

// Package mibs implements a parser for SNMP MIBs.
package smi

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

// A MIB is a collection of SNMP modules. The MIB provides a high-level
// API for loading and accessing the contents of parsed MIBs.
type MIB struct {
	Modules   map[string]*Module
	Root      *Symbol
	Symbols   map[string]*Symbol
	Debug     bool
	dirs      []string
	loadOrder []string
}

type parentRef struct {
	Label string
	Child *Symbol
}

var replacementModule = map[string]string{
	"RFC1155-SMI": "SNMPv2-SMI",
	"RFC-1212":    "SNMPv2-SMI",
	"RFC1212":     "SNMPv2-SMI",
	"RFC-1213":    "SNMPv2-MIB",
	"RFC1213-MIB": "SNMPv2-MIB",
	"RFC1271-MIB": "RMON-MIB",
	"RFC1316-MIB": "CHARACTER-MIB",
}

// NewMIB creates a MIB object for the modules contained in the dirs directories.
// Creating a MIB does not load any modules from the directories. You need to call
// LoadModules() on the resulting MIB object.
func NewMIB(dirs ...string) *MIB {
	mib := &MIB{
		dirs:    dirs,
		Modules: make(map[string]*Module),
		Symbols: make(map[string]*Symbol),
	}

	root := Symbol{
		Name:         "iso",
		ID:           1,
		Module:       nil,
		Parent:       nil,
		ChildByLabel: make(map[string]*Symbol),
		ChildByID:    make(map[int]*Symbol),
	}
	mib.Root = &root
	mib.Symbols[root.Name] = &root

	return mib
}

// LoadModules scans the MIB directories and loads the modules listed by modNames. The imported
// modules are also loaded. A module's name is the one specified on the first line of the MIB file.
// The file names do not have to exactly match the module names.
func (mib *MIB) LoadModules(modNames ...string) error {
	err := mib.scanDirs()
	if err != nil {
		return err
	}

	// Load all modules if no names are provided
	if len(modNames) == 0 {
		modNames = make([]string, 0, len(mib.Modules))
		for name := range mib.Modules {
			modNames = append(modNames, name)
		}
		sort.SliceStable(modNames, func(i, j int) bool {
			return modNames[i] < modNames[j]
		})
	}

	for _, modName := range modNames {
		err := mib.loadModule(modName)
		if err != nil {
			return err
		}
	}
	return mib.indexModules()
}

func (mib *MIB) addSymbol(sym *Symbol) bool {
	if oldSym, ok := mib.Symbols[sym.Name]; ok {
		if mib.Debug {
			log.Printf("imported symbol %v duplicates name of %v, ignoring", sym, oldSym)
		}
		return false
	}
	mib.Symbols[sym.Name] = sym
	return true
}

func (mib *MIB) indexModules() error {
	for _, modName := range mib.loadOrder {
		mod, ok := mib.Modules[modName]
		if !ok {
			return fmt.Errorf("indexing: module not found: %s", modName)
		}
		if !mod.IsLoaded {
			return fmt.Errorf("indexing: module not loaded: %s", modName)
		}

		var unresolved []parentRef
		for _, n := range mod.Nodes {
			if len(n.IDs) < 2 {
				return fmt.Errorf("%s: unknown IDs format: %v\n", modName, n.IDs)
			}
			parentLabel := n.IDs[0].Label
			if parentLabel == "" {
				if len(n.IDs) == 2 && n.IDs[0].ID == 0 && n.IDs[1].ID == 0 {
					// Skip NULL IDs definition
					continue
				}
				return fmt.Errorf("%s: expected parent symbol: %v", modName, n.IDs)
			}

			parent := mib.findSymbol(mod, parentLabel)
			for i := 1; i < len(n.IDs); i++ {
				id := n.IDs[i].ID
				if id == -1 {
					return fmt.Errorf("%s: expected numeric index: %v", modName, n.IDs)
				}
				var label string
				if i < len(n.IDs)-1 {
					label = ""
				} else {
					label = n.Label
				}
				sym := &Symbol{
					Name:         label,
					ID:           id,
					Module:       mod,
					Parent:       parent,
					ChildByLabel: make(map[string]*Symbol),
					ChildByID:    make(map[int]*Symbol),
				}
				if sym.Name != "" {
					mod.Symbols[sym.Name] = sym
					if !mib.addSymbol(sym) {
						continue
					}
				}
				if parent == nil {
					unresolved = append(unresolved, parentRef{Label: parentLabel, Child: sym})
				} else {
					parent.ChildByLabel[sym.Name] = sym
					parent.ChildByID[sym.ID] = sym
				}
				parent = sym
			}
		}

		for _, ref := range unresolved {
			parent := mib.findSymbol(mod, ref.Label)
			sym := ref.Child
			if parent == nil {
				return fmt.Errorf("%s: cannot resolve symbol %v, parent of %s", modName, ref.Label, sym.Name)
			}
			parent.ChildByLabel[sym.Name] = sym
			parent.ChildByID[sym.ID] = sym
		}
	}
	return nil
}

func (mib *MIB) findSymbol(mod *Module, label string) *Symbol {
	if sym, ok := mod.Symbols[label]; ok {
		return sym
	}
	for _, imp := range mod.Imports {
		for _, impLabel := range imp.Symbols {
			if label == impLabel {
				importName := imp.From
				if newName, ok := replacementModule[importName]; ok {
					importName = newName
				}

				impMod := mib.Modules[importName]
				if impMod == nil {
					if mib.Debug {
						log.Printf("imported module not found: %s", imp.From)
					}
					return nil
				}
				return mib.findSymbol(impMod, label)
			}
		}
	}
	if sym, ok := mib.Symbols[label]; ok {
		return sym
	}
	return nil
}

func (mib *MIB) loadModule(modName string) error {
	if newName, ok := replacementModule[modName]; ok {
		modName = newName
	}
	mod := mib.Modules[modName]
	if mod == nil {
		return fmt.Errorf("loading: module not found: %s", modName)
	}
	if mod.IsLoaded {
		return nil
	}
	parsedMod, err := ParseModule(mod.File)
	if err != nil {
		return err
	}
	if mod.Name != parsedMod.Name {
		return fmt.Errorf("found module %s in file %s, expected %s", parsedMod.Name, mod.File, mod.Name)
	}
	mod.Nodes = parsedMod.Nodes
	mod.Imports = parsedMod.Imports
	mod.IsLoaded = true
	mod.Symbols = make(map[string]*Symbol)
	err = mib.loadImports(mod.Imports)
	if err != nil {
		return fmt.Errorf("loading imports for %s: %v", modName, err)
	}
	mib.loadOrder = append(mib.loadOrder, modName)

	return nil
}

func (mib *MIB) loadImports(imports []Import) error {
	for _, imp := range imports {
		// We ignore keywords that are imported, so if all of the
		// symbols were keywords then the list of symbols is empty
		// and there is nothing to load.
		if len(imp.Symbols) > 0 {
			err := mib.loadModule(imp.From)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func (mib *MIB) scanDirs() error {
	scanMods := make(map[string]*Module)
	for _, dirname := range mib.dirs {
		if fi, err := os.Stat(dirname); !os.IsNotExist(err) {
			if fi.IsDir() {
				err = scanDir(dirname, &scanMods)
				if err != nil {
					return err
				}
			}
		}
	}

	// Update modules that exist in MIB
	for modName, mod := range mib.Modules {
		if newMod, ok := scanMods[modName]; ok {
			// Module already exists in MIB
			if mod.File != newMod.File {
				if mib.Debug {
					log.Printf("module %s: replacing %s with %s", modName, mod.File, newMod.File)
				}
				mib.Modules[modName] = newMod
			}
			delete(scanMods, modName)
		} else {
			// Module has been removed
			delete(mib.Modules, modName)
		}
	}

	// Add modules that are new in MIB
	for modName, mod := range scanMods {
		mib.Modules[modName] = mod
	}
	return nil
}

func scanDir(dirname string, scanMods *map[string]*Module) error {
	files, err := ioutil.ReadDir(dirname)
	if err != nil {
		return err
	}
	for _, fi := range files {
		absPath, err := filepath.Abs(filepath.Join(dirname, fi.Name()))
		if err != nil {
			return err
		}
		if fi.IsDir() {
			continue
		}
		if moduleName, err := ModuleName(absPath); err == nil {
			(*scanMods)[moduleName] = &Module{Name: moduleName, File: absPath}
		} else {
			if _, ok := err.(NotAModuleError); !ok {
				return err
			}
		}
	}
	return nil
}

// Symbol returns the Symbol and an OID index for the specified OID.
func (mib *MIB) Symbol(oid OID) (*Symbol, OID) {
	sym := mib.Root
	var prev *Symbol = nil
	for i := 0; ; {
		if sym != nil && sym.ID == oid[i] {
			i++
		} else {
			return prev, oid[i:]
		}
		if i < len(oid) {
			child := sym.ChildByID[oid[i]]
			prev = sym
			sym = child
		} else {
			return sym, OID{}
		}
	}
}

// SymbolString returns a string representation of the information
// provided by the Symbol function.
func (mib *MIB) SymbolString(oid OID) string {
	if len(oid) == 0 {
		return ""
	}
	sym, idx := mib.Symbol(oid)
	if sym == nil {
		return oid.String()
	}
	if len(idx) == 0 {
		return sym.String()
	}
	return sym.String() + "." + idx.String()
}

// OID parses the name string in the format provided by the
// SymbolString function (e.g. Module::Symbol.1.2.3) and returns
// an OID object. The module and index parts of the string are
// optional.
func (mib *MIB) OID(name string) (OID, error) {
	var modulePart string
	var namePart string
	var indexPart string

	if i := strings.Index(name, "::"); i != -1 {
		modulePart = name[:i]
		name = name[i+2:]
	}
	if i := strings.IndexByte(name, '.'); i != -1 {
		namePart = name[:i]
		indexPart = name[i+1:]
	} else {
		namePart = name
		indexPart = ""
	}
	if namePart == "" {
		return nil, fmt.Errorf("missing OID name")
	}

	var sym *Symbol
	if modulePart == "" {
		sym = mib.Symbols[namePart]
		if sym == nil {
			return nil, fmt.Errorf("name %s not in MIB", namePart)
		}
	} else {
		mod := mib.Modules[modulePart]
		if mod == nil {
			return nil, fmt.Errorf("module %s not in MIB", modulePart)
		}
		sym = mod.Symbols[namePart]
		if sym == nil {
			return nil, fmt.Errorf("name %s not in module", namePart)
		}
	}

	var idx OID
	if indexPart != "" {
		idxParts := strings.Split(indexPart, ".")
		for _, part := range idxParts {
			n, err := strconv.Atoi(part)
			if err != nil {
				return nil, fmt.Errorf("invalid index number %s: %v", part, err)
			}
			idx = append(idx, n)
		}
	}

	oid := mib.symbolOID(sym)

	return append(oid, idx...), nil
}

func (mib *MIB) symbolOID(sym *Symbol) OID {
	path := OID{sym.ID}
	for parent := sym.Parent; parent != nil; parent = parent.Parent {
		path = append(OID{parent.ID}, path...)
	}
	return path
}

// VisitSymbols walks all symbols defined in the MIB in order by OID. The action function
// is called once for each symbol.
func (mib *MIB) VisitSymbols(action func(sym *Symbol, oid OID)) {
	sym := mib.Root
	oid := OID{sym.ID}
	visitChildSymbols(sym, oid, action)
}

func visitChildSymbols(sym *Symbol, oid OID, action func(sym *Symbol, oid OID)) {
	var keys []int
	for k := range sym.ChildByID {
		keys = append(keys, k)
	}
	sort.Ints(keys)
	for _, k := range keys {
		childSym := sym.ChildByID[k]
		childOID := append(OID{}, oid...)
		childOID = append(childOID, childSym.ID)
		action(childSym, childOID)
		visitChildSymbols(childSym, childOID, action)
	}
}
