// Copyright (c) 2019 David R. Halliday. All rights reserved.
//
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

package smi

import (
	"fmt"
	"strconv"
	"strings"
)

// NodeType distinguishes the different types of objects that make
// up the Nodes in a Module.
type NodeType int

const (
	NodeNotSupported NodeType = iota
	NodeModuleID
	NodeObjectID
	NodeObjectType
	NodeNotification
)

type SubID struct {
	ID    int
	Label string
}

func (s SubID) String() string {
	if s.ID == -1 {
		return s.Label
	}
	if s.Label == "" {
		return strconv.Itoa(s.ID)
	}
	return fmt.Sprintf("%s(%d)", s.Label, s.ID)
}

// An Import represents all of the symbols imported from
// a single module.
type Import struct {
	From    string
	Symbols []string
}

// A Node represents a parse node in an SMI document
type Node struct {
	Label string
	Type  NodeType
	IDs   []SubID
}

// A Module contains all of the parse results for a single module file.
// Only the Name and File fields are valid if the IsLoaded flag is false.
type Module struct {
	Name     string
	File     string
	Imports  []Import
	Nodes    []Node
	IsLoaded bool
	Symbols  map[string]*Symbol
}

// A Symbol represents a single symbol in the tree of identifiers.
// The tree can be traversed by label or by ID. The collection of
// IDs in the path from the root of the tree to the symbol is the
// object identifier (OID) of the symbol.
type Symbol struct {
	Name         string
	ID           int
	Module       *Module
	Parent       *Symbol
	ChildByLabel map[string]*Symbol
	ChildByID    map[int]*Symbol
}

func (s *Symbol) String() string {
	if s.Module == nil {
		return s.Name
	} else {
		return s.Module.Name + "::" + s.Name
	}
}

type OID []int

func (oid OID) String() string {
	parts := make([]string, len(oid))
	for i, n := range oid {
		parts[i] = strconv.Itoa(n)
	}
	return strings.Join(parts, ".")
}

func (oid OID) Equal(other OID) bool {
	if len(oid) != len(other) {
		return false
	}
	for i, n := range oid {
		if n != other[i] {
			return false
		}
	}
	return true
}
