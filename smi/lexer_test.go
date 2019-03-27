// Copyright (c) 2019 David R. Halliday. All rights reserved.
//
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

package smi

import (
	"strings"
	"testing"
)

func TestLexer_Init(t *testing.T) {
	r := strings.NewReader("IF-MIB DEFINITIONS\nfoo")
	NewLexer(r)

	if smiToknames[tACCESS-57343] != "ACCESS" || smiToknames[tWRITE_SYNTAX-57343] != "WRITE-SYNTAX" {
		t.Fatal("token indexes changed - smi.y updated?")
	}
}

func TestLexer_Ident(t *testing.T) {
	r := strings.NewReader("IF-MIB DEFINITIONS\nfoo")
	lex := NewLexer(r)

	lval := &smiSymType{}
	tok := lex.Lex(lval)

	if tok != tUPPERCASE_IDENTIFIER {
		t.Errorf("error")
	}

	if lval.id != "IF-MIB" {
		t.Errorf("expected IF-MIB, not '%s'", lval.id)
	}

	lval = &smiSymType{}
	tok = lex.Lex(lval)

	if tok != tDEFINITIONS {
		t.Errorf("error")
	}

	if lval.id != "DEFINITIONS" {
		t.Errorf("expected DEFINITIONS, not '%s'", lval.id)
	}

}

func TestLexer_QuotedString(t *testing.T) {
	r := strings.NewReader("\"hello\n   test\n\"")
	lex := NewLexer(r)

	lval := &smiSymType{}
	tok := lex.Lex(lval)

	if tok != tQUOTED_STRING {
		t.Errorf("expected %d, got %d", tQUOTED_STRING, tok)
	}

	if lval.text != "hello\n   test\n" {
		t.Errorf("expected text, not '%s'", lval.text)
	}
}

func TestLexer_Example(t *testing.T) {
	expected := []struct {
		tok        int
		text       string
		id         string
		integer32  int32
		unsigned32 uint32
	}{
		{tok: tLOWERCASE_IDENTIFIER, id: "a"},
		{tok: tLOWERCASE_IDENTIFIER, id: "foo"},
		{tok: tNEGATIVENUMBER, integer32: -42},
		{tok: tLOWERCASE_IDENTIFIER, id: "as-df"},
		{tok: tLOWERCASE_IDENTIFIER, id: "boo"},
		{tok: '-'},
		{tok: '-'},
		{tok: tUPPERCASE_IDENTIFIER, id: "MOO"},
		{tok: tUPPERCASE_IDENTIFIER, id: "FASDFASD"},
		{tok: tQUOTED_STRING, text: "is quoted!"},
		{tok: tNUMBER, unsigned32: 42},
		{tok: tLOWERCASE_IDENTIFIER, id: "bar"},
	}
	r := strings.NewReader("a \nfoo--bar\n-42\n as-df boo- -MOO	 \t   \nFASDFASD \"is quoted!\"\n--blah\n--foo--42bar\n\n\r\n\r\n")
	lex := NewLexer(r)

	lval := &smiSymType{}
	for tok, i := lex.Lex(lval), 0; tok != lexEOF; tok, i = lex.Lex(lval), i+1 {
		if tok != expected[i].tok {
			t.Errorf("%d: token: got %d, expected %d", i, tok, expected[i].tok)
		}
		if lval.id != expected[i].id {
			t.Errorf("%d: id: got %s, expected %s", i, lval.id, expected[i].id)
		}
		if lval.text != expected[i].text {
			t.Errorf("%d: text: got %s, expected %s", i, lval.text, expected[i].text)
		}
		if lval.unsigned32 != expected[i].unsigned32 {
			t.Errorf("%d: id: got %d, expected %d", i, lval.unsigned32, expected[i].unsigned32)
		}
		if lval.integer32 != expected[i].integer32 {
			t.Errorf("%d: id: got %d, expected %d", i, lval.integer32, expected[i].integer32)
		}
		lval = &smiSymType{}
	}
	if lex.err != nil {
		t.Fatal(lex.err)
	}
}

func TestLexer_ident(t *testing.T) {
	r := strings.NewReader("foo")
	lex := NewLexer(r)
	value := &smiSymType{}
	token := lex.Lex(value)
	if token != tLOWERCASE_IDENTIFIER {
		t.Errorf("expected %d, got %d", tLOWERCASE_IDENTIFIER, token)
	}
	if value.id != "foo" {
		t.Errorf("expected '%s', got %v", "foo", value)
	}
}

func TestLexer_string(t *testing.T) {
	r := strings.NewReader("\"one\ntwo\"")
	lex := NewLexer(r)
	value := &smiSymType{}
	token := lex.Lex(value)
	if token != tQUOTED_STRING {
		t.Errorf("expected %d, got %d", tQUOTED_STRING, token)
	}
	if value.text != "one\ntwo" {
		t.Errorf("expected '%s', got %v", "one\ntwo", value)
	}
}

func TestLexer_first_line_blank(t *testing.T) {
	r := strings.NewReader("\"\none\ntwo\"")
	lex := NewLexer(r)
	value := &smiSymType{}
	token := lex.Lex(value)
	if token != tQUOTED_STRING {
		t.Errorf("expected %d, got %d", tQUOTED_STRING, token)
	}
	if value.text != "\none\ntwo" {
		t.Errorf("expected '%s', got '%v'", "\none\ntwo", value.text)
	}
}

type commentTC struct {
	inText   string
	outToken int
	outID    string
}

func TestLexer_comment(t *testing.T) {
	testCases := []commentTC{
		{"--", lexEOF, ""},
		{"--\n", lexEOF, ""},
		{"-- test", lexEOF, ""},
		{"-- test\n", lexEOF, ""},
		{"-- one\n-- two", lexEOF, ""},
		{"one -- test\n", tLOWERCASE_IDENTIFIER, "one"},
		{"two --test--\n", tLOWERCASE_IDENTIFIER, "two"},
		{"three--test", tLOWERCASE_IDENTIFIER, "three"},
		{"--test--four", tLOWERCASE_IDENTIFIER, "four"},
	}

	for _, tc := range testCases {
		r := strings.NewReader(tc.inText)
		lex := NewLexer(r)
		value := &smiSymType{}
		tokens := make([]int, 0)
		for tok := lex.Lex(value); tok != lexEOF; tok = lex.Lex(value) {
			tokens = append(tokens, tok)
		}

		if tc.outToken == lexEOF && len(tokens) > 0 {
			t.Errorf("expected no tokens, got %v", tokens)
		}

		if tc.outToken != lexEOF && (tc.outToken != tokens[0] || len(tokens) != 1) {
			t.Errorf("expected %d, got %v", tc.outToken, tokens)
		}

		if tc.outID != "" && value.id != tc.outID {
			t.Errorf("expected %s, got %s", tc.outID, value.id)
		}
	}
}

func TestLexer_HexBin(t *testing.T) {
	testCases := []struct {
		inText   string
		outToken int
		outText  string
		outErr   string
	}{
		{inText: "''H", outToken: tHEX_STRING, outText: ""},
		{inText: "'0101'h", outToken: tHEX_STRING, outText: "0101"},
		{inText: "'0101'B", outToken: tBIN_STRING, outText: "0101"},
		{inText: "'abcdef'H", outToken: tHEX_STRING, outText: "abcdef"},
		{inText: "'0'b", outToken: tBIN_STRING, outText: "0"},
		{inText: "'01012'B", outToken: lexEOF, outErr: "expected H character"},
		{inText: "'0101'", outToken: lexEOF, outErr: "expected H or B character"},
		{inText: "'123", outToken: lexEOF, outErr: "file ends with unterminated numeric string"},
		{inText: "'0x1234'h", outToken: lexEOF, outErr: "expected a digit"},
	}

	for i, tc := range testCases {
		r := strings.NewReader(tc.inText)
		lex := NewLexer(r)
		value := &smiSymType{}
		tokens := make([]int, 0)
		for tok := lex.Lex(value); tok != lexEOF; tok = lex.Lex(value) {
			tokens = append(tokens, tok)
		}

		if tc.outToken == lexEOF && lex.err != nil {
			if tc.outErr != lex.err.Error() {
				t.Errorf("TC %d: expected %s, got '%s'", i, tc.outErr, lex.err.Error())
			}
		}

		if tc.outToken == lexEOF && len(tokens) > 0 {
			t.Errorf("TC %d: expected no tokens, got %v", i, tokens)
		}

		if tc.outToken != lexEOF && (tc.outToken != tokens[0] || len(tokens) != 1) {
			t.Errorf("TC %d: expected %d, got %v", i, tc.outToken, tokens)
		}

		if tc.outText != "" && value.text != tc.outText {
			t.Errorf("TC %d: expected %s, got %s", i, tc.outText, value.text)
		}
	}

}
