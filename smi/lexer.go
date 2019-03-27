// Copyright (c) 2019 David R. Halliday. All rights reserved.
//
// Use of this source code is governed by an MIT-style license
// that can be found in the LICENSE file.

package smi

import (
	"bufio"
	"fmt"
	"io"
	"math"
	"strconv"
	"strings"
	"unicode"
)

const (
	lexEOF = 0
	lexUnk = 2
	lexEOL = '\n'
)

const (
	skipNone skipState = iota
	skipExports
	skipMacro
	skipChoice
)

type skipState int

var keywords = map[string]int{
	"ACCESS":             ACCESS,
	"AGENT-CAPABILITIES": AGENT_CAPABILITIES,
	"APPLICATION":        APPLICATION,
	"AUGMENTS":           AUGMENTS,
	"BEGIN":              BEGIN_,
	"BITS":               BITS,
	"CHOICE":             CHOICE,
	"CONTACT-INFO":       CONTACT_INFO,
	"CREATION-REQUIRES":  CREATION_REQUIRES,
	"Counter32":          COUNTER32,
	"Counter64":          COUNTER64,
	"DEFINITIONS":        DEFINITIONS,
	"DEFVAL":             DEFVAL,
	"DESCRIPTION":        DESCRIPTION,
	"DISPLAY-HINT":       DISPLAY_HINT,
	"END":                END,
	"ENTERPRISE":         ENTERPRISE,
	"EXPORTS":            EXPORTS,
	"EXTENDS":            EXTENDS,
	"FROM":               FROM,
	"GROUP":              GROUP,
	"Gauge32":            GAUGE32,
	"IDENTIFIER":         IDENTIFIER,
	"IMPLICIT":           IMPLICIT,
	"IMPLIED":            IMPLIED,
	"IMPORTS":            IMPORTS,
	"INCLUDES":           INCLUDES,
	"INDEX":              INDEX,
	"INSTALL-ERRORS":     INSTALL_ERRORS,
	"INTEGER":            INTEGER,
	"Integer32":          INTEGER32,
	"Integer64":          INTEGER64,
	"IpAddress":          IPADDRESS,
	"LAST-UPDATED":       LAST_UPDATED,
	"MACRO":              MACRO,
	"MANDATORY-GROUPS":   MANDATORY_GROUPS,
	"MAX-ACCESS":         MAX_ACCESS,
	"MIN-ACCESS":         MIN_ACCESS,
	"MODULE":             MODULE,
	"MODULE-COMPLIANCE":  MODULE_COMPLIANCE,
	"MODULE-IDENTITY":    MODULE_IDENTITY,
	"NOTIFICATION-GROUP": NOTIFICATION_GROUP,
	"NOTIFICATION-TYPE":  NOTIFICATION_TYPE,
	"NOTIFICATIONS":      NOTIFICATIONS,
	"OBJECT":             OBJECT,
	"OBJECT-GROUP":       OBJECT_GROUP,
	"OBJECT-IDENTITY":    OBJECT_IDENTITY,
	"OBJECT-TYPE":        OBJECT_TYPE,
	"OBJECTS":            OBJECTS,
	"OCTET":              OCTET,
	"OF":                 OF,
	"ORGANIZATION":       ORGANIZATION,
	"Opaque":             OPAQUE,
	"PIB-ACCESS":         PIB_ACCESS,
	"PIB-DEFINITIONS":    PIB_DEFINITIONS,
	"PIB-INDEX":          PIB_INDEX,
	"PIB-MIN-ACCESS":     PIB_MIN_ACCESS,
	"PIB-REFERENCES":     PIB_REFERENCES,
	"PIB-TAG":            PIB_TAG,
	"POLICY-ACCESS":      POLICY_ACCESS,
	"PRODUCT-RELEASE":    PRODUCT_RELEASE,
	"REFERENCE":          REFERENCE,
	"REVISION":           REVISION,
	"SEQUENCE":           SEQUENCE,
	"SIZE":               SIZE,
	"STATUS":             STATUS,
	"STRING":             STRING,
	"SUBJECT-CATEGORIES": SUBJECT_CATEGORIES,
	"SUPPORTS":           SUPPORTS,
	"SYNTAX":             SYNTAX,
	"TEXTUAL-CONVENTION": TEXTUAL_CONVENTION,
	"TimeTicks":          TIMETICKS,
	"TRAP-TYPE":          TRAP_TYPE,
	"UNIQUENESS":         UNIQUENESS,
	"UNITS":              UNITS,
	"UNIVERSAL":          UNIVERSAL,
	"Unsigned32":         UNSIGNED32,
	"Unsigned64":         UNSIGNED64,
	"VALUE":              VALUE,
	"VARIABLES":          VARIABLES,
	"VARIATION":          VARIATION,
	"WRITE-SYNTAX":       WRITE_SYNTAX,
}

type Lexer struct {
	s           *bufio.Scanner
	line        []byte
	lineno      int
	scanOffset  int
	tokenOffset int
	state       skipState
	savedToken  *string
	err         error
	module      *Module
}

func init() {
	smiDebug = 0           // debug output level for generated lexer
	smiErrorVerbose = true // return useful error messages
	fixToknames()
}

func fixToknames() {
	smiToknames[lexEOF] = "end of file"
	smiToknames[lexUnk] = "character"
	smiToknames[3] = "'..'"
	smiToknames[4] = "'::='"
	smiToknames[5] = "upper case identifier"
	smiToknames[6] = "identifier"
	smiToknames[7] = "number"
	smiToknames[8] = "number"
	smiToknames[9] = "64-bit number"
	smiToknames[10] = "64-bit number"
	smiToknames[11] = "binary string"
	smiToknames[12] = "hexadecimal string"
	smiToknames[13] = "string"
	for keyword, token := range keywords {
		smiToknames[token-57343] = keyword
	}
}

func (lex *Lexer) readLine() bool {
	if lex.err != nil {
		return false
	}
	if !lex.s.Scan() {
		lex.err = lex.s.Err()
		return false
	}
	lex.line = lex.s.Bytes()
	lex.tokenOffset = 0
	lex.scanOffset = 0
	lex.lineno++
	return true
}

func (lex *Lexer) peek() byte {
	if lex.line == nil {
		if !lex.readLine() {
			return lexEOF
		}
	}
	if lex.line != nil && lex.scanOffset == len(lex.line) {
		s := lex.consumeToken()
		lex.savedToken = &s
		lex.line = nil
		return lexEOL
	}
	if lex.savedToken != nil {
		return lexEOL
	}
	return lex.line[lex.scanOffset]
}

func (lex *Lexer) peek2() []byte {
	b2 := make([]byte, 2)
	b2[0] = lex.peek()
	if lex.scanOffset < len(lex.line)-1 {
		b := lex.line[lex.scanOffset+1]
		b2[1] = b
	}
	return b2
}

func (lex *Lexer) next() byte {
	b := lex.peek()
	if b != lexEOL && b != lexEOF {
		lex.scanOffset++
	}
	return b
}

func (lex *Lexer) skip(n int) {
	lex.scanOffset += n
	lex.tokenOffset = lex.scanOffset
	lex.savedToken = nil
}

func (lex *Lexer) skipWhitespace() {
	for b := lex.peek(); isSpaceByte(b); b = lex.peek() {
		lex.skip(1)
	}
}

func (lex *Lexer) consumeToken() string {
	if lex.savedToken != nil {
		ret := lex.savedToken
		lex.savedToken = nil
		return *ret
	}
	tokStr := string(lex.line[lex.tokenOffset:lex.scanOffset])
	lex.tokenOffset = lex.scanOffset

	return tokStr
}

func isLetterByte(b byte) bool {
	return (b >= 'a' && b <= 'z') || (b >= 'A' && b <= 'Z')
}

func isDigitByte(b byte) bool {
	return b >= '0' && b <= '9'
}

func isHexDigitByte(b byte) bool {
	return (b >= '0' && b <= '9') || (b >= 'a' && b <= 'f') || (b >= 'A' && b <= 'F')
}

func isBinaryDigitByte(b byte) bool {
	return b == '0' || b == '1'
}

func isLowerByte(b byte) bool {
	return b <= unicode.MaxASCII && unicode.IsLower(rune(b))
}

func isIdentByte(b2 []byte) bool {
	return isLetterByte(b2[0]) || isDigitByte(b2[0]) ||
		(b2[0] == '-' && (isLetterByte(b2[1]) || isDigitByte(b2[1])))
}

func isSpaceByte(b byte) bool {
	return b == ' ' || b == '\t' || b == lexEOL
}

func (lex *Lexer) consumeIdent(lval *smiSymType) int {
	for b2 := lex.peek2(); isIdentByte(b2); b2 = lex.peek2() {
		lex.next()
	}
	lval.id = lex.consumeToken()

	if tok, ok := keywords[lval.id]; ok {
		return tok
	}

	tok := UPPERCASE_IDENTIFIER
	if isLowerByte(lval.id[0]) {
		tok = LOWERCASE_IDENTIFIER
	}
	return tok
}

func (lex *Lexer) consumeDash(lval *smiSymType) int {
	b2 := lex.peek2()
	if b2[0] == '-' && b2[1] == '-' {
		return lex.consumeComment(lval)
	}
	if b2[0] == '-' && isDigitByte(b2[1]) {
		return lex.consumeSigned(lval)
	}
	tok := int(lex.next())
	lex.consumeToken()
	return tok
}

func (lex *Lexer) consumeComment(lval *smiSymType) int {
	lex.skip(2)
	for {
		b2 := lex.peek2()
		if b2[0] == lexEOL || b2[0] == lexEOF {
			lex.skip(1)
			break
		}
		if b2[0] == '-' && b2[1] == '-' {
			lex.skip(2)
			break
		}
		lex.skip(1)
	}
	return lex.Lex(lval)
}

func (lex *Lexer) consumeSingleQuote(lval *smiSymType) int {
	binOnly := true

	lex.skip(1)
	for b := lex.peek(); b != '\''; b = lex.peek() {
		d := lex.next()
		if d == lexEOF {
			lex.err = fmt.Errorf("file ends with unterminated numeric string")
			return lexEOF
		}
		if !isHexDigitByte(d) {
			lex.err = fmt.Errorf("expected a digit")
			return lexEOF
		}
		if binOnly && !isBinaryDigitByte(d) {
			binOnly = false
		}
	}
	lval.text = lex.consumeToken()
	lex.skip(1)

	t := lex.peek()
	lex.skip(1)
	if t == 'h' || t == 'H' {
		return HEX_STRING
	}
	if t == 'b' || t == 'B' {
		if binOnly {
			return BIN_STRING
		}
		lex.err = fmt.Errorf("expected H character")
		return lexEOF
	}

	lex.err = fmt.Errorf("expected H or B character")
	return lexEOF
}

func (lex *Lexer) consumeDoubleQuote(lval *smiSymType) int {
	buf := strings.Builder{}
	lex.skip(1)
	for {
		b := lex.peek()
		if b == lexEOF {
			lex.err = fmt.Errorf("file ends with unterminated string")
			return lexEOF
		}
		if b == '"' {
			buf.WriteString(lex.consumeToken())
			lval.text = buf.String()
			lex.skip(1)
			break
		}
		if b == lexEOL {
			buf.WriteString(lex.consumeToken())
			buf.WriteByte('\n')
			continue
		}
		lex.next()
	}
	return QUOTED_STRING
}

func (lex *Lexer) consumeUnsigned(lval *smiSymType) int {
	for b := lex.peek(); isDigitByte(b); b = lex.peek() {
		lex.next()
	}
	text := lex.consumeToken()
	i, err := strconv.ParseUint(text, 10, 64)
	if err != nil {
		lex.err = err
		return lexEOF
	}
	if i < 0 {
		panic("expected positive number")
	}
	if i <= uint64(math.MaxUint32) {
		lval.unsigned32 = uint32(i)
		return NUMBER
	}
	lval.unsigned64 = i
	return NUMBER64
}

func (lex *Lexer) consumeSigned(lval *smiSymType) int {
	lex.next()
	for b := lex.peek(); isDigitByte(b); b = lex.peek() {
		lex.next()
	}
	text := lex.consumeToken()
	i, err := strconv.ParseInt(text, 10, 64)
	if err != nil {
		lex.err = err
		return lexEOF
	}
	if i > 0 {
		panic("expected negative number")
	}
	if i <= int64(math.MaxInt32) {
		lval.integer32 = int32(i)
		return NEGATIVENUMBER
	}
	lval.integer64 = i
	return NEGATIVENUMBER64
}

func (lex *Lexer) consumeColon(lval *smiSymType) int {
	b := lex.next()
	if b2 := lex.peek2(); b2[0] == ':' && b2[1] == '=' {
		lex.skip(2)
		return COLON_COLON_EQUAL
	}
	return int(b)
}

func (lex *Lexer) consumeDot(lval *smiSymType) int {
	b := lex.next()
	if bb := lex.peek(); bb == '.' {
		lex.skip(1)
		return DOT_DOT
	}
	return int(b)
}

func (lex *Lexer) getToken(lval *smiSymType) int {
	lex.skipWhitespace()

	b := lex.peek()
	switch {
	case isLetterByte(b):
		return lex.consumeIdent(lval)
	case isDigitByte(b):
		return lex.consumeUnsigned(lval)
	case b == '-':
		return lex.consumeDash(lval)
	case b == '\'':
		return lex.consumeSingleQuote(lval)
	case b == '"':
		return lex.consumeDoubleQuote(lval)
	case b == ':':
		return lex.consumeColon(lval)
	case b == '.':
		return lex.consumeDot(lval)
	case b != lexEOF:
		tok := int(lex.next())
		lex.consumeToken()
		return tok
	}

	return lexEOF
}

func (lex *Lexer) nextState(tok int) {
	switch lex.state {
	case skipNone:
		if tok == CHOICE {
			lex.state = skipChoice
		} else if tok == EXPORTS {
			lex.state = skipExports
		} else if tok == MACRO {
			lex.state = skipMacro
		}
	case skipChoice:
		if tok == '}' || tok == lexEOF {
			lex.state = skipNone
		}
	case skipExports:
		if tok == ';' || tok == lexEOF {
			lex.state = skipNone
		}
	case skipMacro:
		if tok == END || tok == lexEOF {
			lex.state = skipNone
		}
	default:
		panic(fmt.Sprint("invalid state:", lex.state))
	}
}

func (lex *Lexer) Lex(lval *smiSymType) int {
	switch lex.state {
	case skipNone:
		tok := lex.getToken(lval)
		lex.nextState(tok)
		return tok
	case skipChoice, skipExports, skipMacro:
		var tok int
		for lex.state != skipNone {
			tok = lex.getToken(lval)
			lex.nextState(tok)
		}
		return tok
	default:
		panic(fmt.Sprint("invalid state: ", lex.state))
	}
}

func (lex *Lexer) Error(e string) {
	lex.err = fmt.Errorf("%s: %s\n", lex.pos(), e)
}

func NewLexer(r io.Reader) *Lexer {
	return &Lexer{s: bufio.NewScanner(r)}
}

func (lex *Lexer) pos() string {
	return fmt.Sprintf("%d:%d", lex.lineno, lex.tokenOffset)
}

func setModule(smiLexer *smiLexer, m *Module) {
	lex := (*smiLexer).(*Lexer)
	lex.module = m
}
