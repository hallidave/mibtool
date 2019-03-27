// Copyright (c) 2019 David R. Halliday. All rights reserved.
//
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

//go:generate goyacc -o yysmi.go -p "smi" smi.y

package smi

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func mustClose(closer io.Closer) {
	err := closer.Close()
	if err != nil {
		panic(err)
	}
}

func ParseModule(filename string) (*Module, error) {
	file, err := os.Open(filename)
	if err != nil {
		panic(err)
	}
	defer mustClose(file)
	reader := bufio.NewReader(file)
	lex := NewLexer(reader)
	ret := smiParse(lex)
	if lex.err != nil {
		return nil, fmt.Errorf("%s:%v", filename, lex.err)
	}
	if ret != 0 {
		return nil, fmt.Errorf("parse failed: %d", ret)
	}

	lex.module.File = filename
	return lex.module, nil
}

type NotAModuleError string

func (f NotAModuleError) Error() string {
	return fmt.Sprintf("not a module file: %s", f)
}

func (f NotAModuleError) Filename() string {
	return string(f)
}

func ModuleName(filename string) (string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return "", err
	}
	defer mustClose(file)
	r := bufio.NewReader(file)
	lex := NewLexer(r)
	lval := smiSymType{}
	tok := lex.Lex(&lval)
	if tok == UPPERCASE_IDENTIFIER {
		moduleName := lval.id
		tok = lex.Lex(&lval)
		if tok == DEFINITIONS {
			return moduleName, nil
		}
	}
	return "", NotAModuleError(filename)
}
