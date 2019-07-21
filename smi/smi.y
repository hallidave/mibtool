/*
 * Original parsing rules from the libsmi library:
 *
 * Copyright (c) 1999 Frank Strauss, Technical University of Braunschweig.
 *
 * This software is copyrighted by Frank Strauss, the Technical University
 * of Braunschweig, and other parties.  The following terms apply to all
 * files associated with the software unless explicitly disclaimed in
 * individual files.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 *
 * IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
 * DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
 * IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
 * NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS.
 *
 * Portions of this file specific to the Go programming language:
 *
 * Copyright (c) 2019 David R. Halliday. All rights reserved.
 *
 * Use of this source code is governed by an MIT-style license
 * that can be found in the LICENSE file.
 */

%{

package smi

%}

/*
 * The grammars start symbol.
 */
%start mibFile


/*
 * The attributes.
 */
%union {
    text string
    id   string
    err   int
    date string
    objectPtr string
    SmiStatus int
    SmiAccess int
    typePtr string
    listPtr string
    namedNumberPtr string
    rangePtr string
    valuePtr string
    unsigned32 uint32
    integer32 int32
    unsigned64 uint64
    integer64 int64
    compl string
    index string
    modulePtr string
    subjectCategoriesPtr string
    subid SubID
    subidList []SubID
    node Node
    nodeList []Node
    idList []string
    imp Import
    impList []Import
}



/*
 * Tokens and their attributes.
 */
%token tDOT_DOT
%token tCOLON_COLON_EQUAL

%token <id>tUPPERCASE_IDENTIFIER
%token <id>tLOWERCASE_IDENTIFIER
%token <unsigned32>tNUMBER
%token <integer32>tNEGATIVENUMBER
%token <unsigned64>tNUMBER64
%token <integer64>tNEGATIVENUMBER64
%token <text>tBIN_STRING
%token <text>tHEX_STRING
%token <text>tQUOTED_STRING

%token <id>tACCESS
%token <id>tAGENT_CAPABILITIES
%token <id>tAPPLICATION
%token <id>tAUGMENTS
%token <id>tBEGIN_
%token <id>tBITS
%token <id>tCHOICE
%token <id>tCONTACT_INFO
%token <id>tCREATION_REQUIRES
%token <id>tCOUNTER32
%token <id>tCOUNTER64
%token <id>tDEFINITIONS
%token <id>tDEFVAL
%token <id>tDESCRIPTION
%token <id>tDISPLAY_HINT
%token <id>tEND
%token <id>tENTERPRISE
%token <id>tEXPORTS
%token <id>tEXTENDS
%token <id>tFROM
%token <id>tGROUP
%token <id>tGAUGE32
%token <id>tIDENTIFIER
%token <id>tIMPLICIT
%token <id>tIMPLIED
%token <id>tIMPORTS
%token <id>tINCLUDES
%token <id>tINDEX
%token <id>tINSTALL_ERRORS
%token <id>tINTEGER
%token <id>tINTEGER32
%token <id>tINTEGER64
%token <id>tIPADDRESS
%token <id>tLAST_UPDATED
%token <id>tMACRO
%token <id>tMANDATORY_GROUPS
%token <id>tMAX_ACCESS
%token <id>tMIN_ACCESS
%token <id>tMODULE
%token <id>tMODULE_COMPLIANCE
%token <id>tMODULE_IDENTITY
%token <id>tNOT_ACCESSIBLE
%token <id>tNOTIFICATIONS
%token <id>tNOTIFICATION_GROUP
%token <id>tNOTIFICATION_TYPE
%token <id>tOBJECT
%token <id>tOBJECT_GROUP
%token <id>tOBJECT_IDENTITY
%token <id>tOBJECT_TYPE
%token <id>tOBJECTS
%token <id>tOCTET
%token <id>tOF
%token <id>tORGANIZATION
%token <id>tOPAQUE
%token <id>tPIB_ACCESS
%token <id>tPIB_DEFINITIONS
%token <id>tPIB_INDEX
%token <id>tPIB_MIN_ACCESS
%token <id>tPIB_REFERENCES
%token <id>tPIB_TAG
%token <id>tPOLICY_ACCESS
%token <id>tPRODUCT_RELEASE
%token <id>tREFERENCE
%token <id>tREVISION
%token <id>tSEQUENCE
%token <id>tSIZE
%token <id>tSTATUS
%token <id>tSTRING
%token <id>tSUBJECT_CATEGORIES
%token <id>tSUPPORTS
%token <id>tSYNTAX
%token <id>tTEXTUAL_CONVENTION
%token <id>tTIMETICKS
%token <id>tTRAP_TYPE
%token <id>tUNIQUENESS
%token <id>tUNITS
%token <id>tUNIVERSAL
%token <id>tUNSIGNED32
%token <id>tUNSIGNED64
%token <id>tVALUE
%token <id>tVARIABLES
%token <id>tVARIATION
%token <id>tWRITE_SYNTAX



/*
 * Types of non-terminal symbols.
 */
%type  <err>mibFile
%type  <err>modules
%type  <err>module
%type  <err>moduleOid
%type  <id>moduleName
%type  <id>importIdentifier
%type  <idList>importIdentifiers
%type  <id>importedKeyword
%type  <id>importedSMIKeyword
%type  <id>importedSPPIKeyword
%type  <impList>linkagePart
%type  <impList>linkageClause
%type  <impList>importPart
%type  <impList>imports
%type  <imp> import
%type  <nodeList>declarationPart
%type  <nodeList>declarations
%type  <node>declaration
%type  <err>exportsClause
%type  <err>macroClause
%type  <id>macroName
%type  <typePtr>choiceClause
%type  <id>typeName
%type  <id>typeSMI
%type  <id>typeSMIonly
%type  <id>typeSMIandSPPI
%type  <id>typeSPPIonly
%type  <err>typeTag
%type  <id>fuzzy_lowercase_identifier
%type  <node>valueDeclaration
%type  <typePtr>conceptualTable
%type  <typePtr>row
%type  <typePtr>entryType
%type  <listPtr>sequenceItems
%type  <objectPtr>sequenceItem
%type  <typePtr>Syntax
%type  <typePtr>sequenceSyntax
%type  <listPtr>NamedBits
%type  <namedNumberPtr>NamedBit
%type  <node>objectIdentityClause
%type  <node>objectTypeClause
%type  <err>trapTypeClause
%type  <text>descriptionClause
%type  <listPtr>VarPart
%type  <listPtr>VarTypes
%type  <objectPtr>VarType
%type  <text>DescrPart
%type  <access>MaxAccessPart
%type  <access>MaxOrPIBAccessPart
%type  <access>PibAccessPart
%type  <node>notificationTypeClause
%type  <node>moduleIdentityClause
%type  <err>typeDeclaration
%type  <typePtr>typeDeclarationRHS
%type  <typePtr>ObjectSyntax
%type  <typePtr>sequenceObjectSyntax
%type  <valuePtr>valueofObjectSyntax
%type  <typePtr>SimpleSyntax
%type  <valuePtr>valueofSimpleSyntax
%type  <typePtr>sequenceSimpleSyntax
%type  <typePtr>ApplicationSyntax
%type  <typePtr>sequenceApplicationSyntax
%type  <listPtr>anySubType
%type  <listPtr>integerSubType
%type  <listPtr>octetStringSubType
%type  <listPtr>ranges
%type  <rangePtr>range
%type  <valuePtr>value
%type  <listPtr>enumSpec
%type  <listPtr>enumItems
%type  <namedNumberPtr>enumItem
%type  <valuePtr>enumNumber
%type  <status>Status
%type  <status>Status_Capabilities
%type  <text>DisplayPart
%type  <text>UnitsPart
%type  <access>Access
%type  <index>IndexPart
%type  <index>MibIndex
%type  <listPtr>IndexTypes
%type  <objectPtr>IndexType
%type  <objectPtr>Index
%type  <objectPtr>Entry
%type  <valuePtr>DefValPart
%type  <valuePtr>Value
%type  <listPtr>BitsValue
%type  <listPtr>BitNames
%type  <subidList>ObjectName
%type  <subidList>NotificationName
%type  <text>ReferPart
%type  <err>RevisionPart
%type  <err>Revisions
%type  <err>Revision
%type  <listPtr>NotificationObjectsPart
%type  <listPtr>ObjectGroupObjectsPart
%type  <listPtr>Objects
%type  <objectPtr>Object
%type  <listPtr>NotificationsPart
%type  <listPtr>Notifications
%type  <objectPtr>Notification
%type  <text>Text
%type  <date>ExtUTCTime
%type  <subidList>objectIdentifier
%type  <subidList>subidentifiers
%type  <subid>subidentifier
%type  <text>objectIdentifier_defval
%type  <err>subidentifiers_defval
%type  <err>subidentifier_defval
%type  <err>objectGroupClause
%type  <err>notificationGroupClause
%type  <err>moduleComplianceClause
%type  <compl>ComplianceModulePart
%type  <compl>ComplianceModules
%type  <compl>ComplianceModule
%type  <modulePtr>ComplianceModuleName
%type  <listPtr>MandatoryPart
%type  <listPtr>MandatoryGroups
%type  <objectPtr>MandatoryGroup
%type  <compl>CompliancePart
%type  <compl>Compliances
%type  <compl>Compliance
%type  <listPtr>ComplianceGroup
%type  <listPtr>ComplianceObject
%type  <typePtr>SyntaxPart
%type  <typePtr>WriteSyntaxPart
%type  <typePtr>WriteSyntax
%type  <access>AccessPart
%type  <err>agentCapabilitiesClause
%type  <err>ModulePart_Capabilities
%type  <err>Modules_Capabilities
%type  <err>Module_Capabilities
%type  <modulePtr>ModuleName_Capabilities
%type  <listPtr>CapabilitiesGroups
%type  <listPtr>CapabilitiesGroup
%type  <err>VariationPart
%type  <err>Variations
%type  <err>Variation
%type  <access>VariationAccessPart
%type  <access>VariationAccess
%type  <err>CreationPart
%type  <err>Cells
%type  <err>Cell
%type  <objectPtr>SPPIPibReferencesPart
%type  <objectPtr>SPPIPibTagPart
%type  <subjectCategoriesPtr>SubjectCategoriesPart
%type  <subjectCategoriesPtr>SubjectCategories
%type  <listPtr>CategoryIDs
%type  <objectPtr>CategoryID
%type  <objectPtr>UniqueType
%type  <listPtr>UniqueTypes
%type  <listPtr>UniqueTypesPart
%type  <listPtr>SPPIUniquePart
%type  <objectPtr>Error
%type  <listPtr>Errors
%type  <listPtr>SPPIErrorsPart

%%

/*
 * One mibFile may contain multiple MIB modules.
 * It's also possible that there's no module in a file.
 */
mibFile:
                        modules
        |               /* empty */
                        {}
        ;

modules:		module
	|		modules module
                        {}
	;

/*
 * The general structure of a module is described at REF:RFC1902,3. .
 * An example is given at REF:RFC1902,5.7. .
 */
module:			moduleName
			moduleOid
			definitions
			tCOLON_COLON_EQUAL tBEGIN_
			exportsClause
			linkagePart
			declarationPart
			tEND
			{
				m := Module{Name: $1, Imports: $7, Nodes: $8}
				setModule(&smilex, &m)
			}
	;

moduleOid:		'{' objectIdentifier '}'
			{}
	|		/* empty */
                        {}
	;

definitions:            tDEFINITIONS
                        {}
        |               tPIB_DEFINITIONS
                        {}
        ;

/*
 * REF:RFC1902,3.2.
 */
linkagePart:		linkageClause
	|		/* empty */
			{
				$$ = []Import{}
			}
	;

linkageClause:		tIMPORTS importPart ';'
			{
				$$ = $2
			}
        ;

exportsClause:		/* empty */
			{}
	|		tEXPORTS
			{}
			/* the scanner skips until... */
			';'
			{}
	;

importPart:		imports
	|		/* empty */
			{
				$$ = []Import{}
			}
	;

imports:		import
			{
				$$ = []Import{$1}
			}
	|		imports import
			{
				$$ = append($1, $2)
			}
	;

import:			importIdentifiers
                        tFROM
                        moduleName
			{
				$$ = Import{From: $3, Symbols: $1}
			}
	;

importIdentifiers:	importIdentifier
			{
				if $1 == "" {
					$$ = []string{}
				} else {
					$$ = []string{$1}
				}
			}
	|		importIdentifiers ',' importIdentifier
			{
				if $3 == "" {
					$$ = $1
				} else {
					$$ = append($1, $3)
				}
			}
	;

/*
 * Note that some named types must not be imported, REF:RFC1902,590 .
 */
importIdentifier:	tLOWERCASE_IDENTIFIER
	|		tUPPERCASE_IDENTIFIER
	|		importedKeyword
			{
				$$ = ""
			}
	;

/*
 * These keywords are no real keywords. They have to be imported
 * from the SMI, TC, CONF MIBs.
 */
importedKeyword:	importedSMIKeyword
                        {}
        |               importedSPPIKeyword
                        {}
        |               tBITS
	|		tINTEGER32
	|		tIPADDRESS
	|		tMANDATORY_GROUPS
	|		tMODULE_COMPLIANCE
	|		tMODULE_IDENTITY
	|		tOBJECT_GROUP
	|		tOBJECT_IDENTITY
	|		tOBJECT_TYPE
	|		tOPAQUE
	|		tTEXTUAL_CONVENTION
	|		tTIMETICKS
	|		tUNSIGNED32
        ;

importedSMIKeyword:     tAGENT_CAPABILITIES
	|		tCOUNTER32
	|		tCOUNTER64
	|		tGAUGE32
	|		tNOTIFICATION_GROUP
	|		tNOTIFICATION_TYPE
	|		tTRAP_TYPE
	;

importedSPPIKeyword:	tINTEGER64
	|		tUNSIGNED64
	;

moduleName:		tUPPERCASE_IDENTIFIER
	;

/*
 * The paragraph at REF:RFC1902,490 lists roughly what is allowed
 * in the body of an information module.
 */
declarationPart:	declarations
			{}
	|		/* empty */
			{}
	;

declarations:		declaration
			{
				if $1.Type != NodeNotSupported {
					$$ = []Node{$1}
				} else {
					$$ = []Node{}
				}
			}
	|		declarations declaration
			{
				if $2.Type != NodeNotSupported {
					$$ = append($1, $2)
				}
			}
	;

declaration:		typeDeclaration
			{
			}
	|		valueDeclaration
			{
			}
	|		objectIdentityClause
			{
			}
	|		objectTypeClause
			{
			}
	|		trapTypeClause
			{
			}
	|		notificationTypeClause
			{
			}
	|		moduleIdentityClause
			{
			}
	|		moduleComplianceClause
			{
			}
	|		objectGroupClause
			{
			}
	|		notificationGroupClause
			{
			}
	|		agentCapabilitiesClause
			{
			}
	|		macroClause
			{
			}
	|		error '}'
			{
			}
	;

/*
 * Macro clauses. Its contents are not really parsed, but skipped by
 * the scanner until 'tEND' is read. This is just to make the SMI
 * documents readable.
 */
macroClause:		macroName
			{
			}
			tMACRO
			{
			}
			/* the scanner skips until... */
			tEND
			{
                        }
	;

macroName:		tMODULE_IDENTITY     { $$ = $1; }
	|		tOBJECT_TYPE	    { $$ = $1; }
	|		tTRAP_TYPE	    { $$ = $1; }
	|		tNOTIFICATION_TYPE   { $$ = $1; }
	|		tOBJECT_IDENTITY	    { $$ = $1; }
	|		tTEXTUAL_CONVENTION  { $$ = $1; }
	|		tOBJECT_GROUP	    { $$ = $1; }
	|		tNOTIFICATION_GROUP  { $$ = $1; }
	|		tMODULE_COMPLIANCE   { $$ = $1; }
	|		tAGENT_CAPABILITIES  { $$ = $1; }
	;

choiceClause:		tCHOICE
			{
			}
			/* the scanner skips until... */
			'}'
			{
			}
	;

/*
 * The only ASN.1 value declarations are for OIDs, REF:RFC1902,491 .
 */
fuzzy_lowercase_identifier:	tLOWERCASE_IDENTIFIER
			{
			}
	|
			tUPPERCASE_IDENTIFIER
			{
			}
	;

valueDeclaration:	fuzzy_lowercase_identifier
			tOBJECT tIDENTIFIER
			tCOLON_COLON_EQUAL '{' objectIdentifier '}'
			{
				$$ = Node{Label: $1, Type: NodeObjectID, IDs: $6}
			}
	;

/*
 * This is for simple ASN.1 style type assignments and textual conventions.
 */
typeDeclaration:	typeName
			{
			}
			tCOLON_COLON_EQUAL typeDeclarationRHS
			{
			}
	;

typeName:		tUPPERCASE_IDENTIFIER
			{
			}
	|		typeSMI
			{
			}
        |               typeSPPIonly
                        {
                        }
	;

typeSMI:                typeSMIandSPPI
        |               typeSMIonly
                        {
                        }
        ;

typeSMIandSPPI:		tIPADDRESS
	|		tTIMETICKS
	|		tOPAQUE
	|		tINTEGER32
	|		tUNSIGNED32
        ;

typeSMIonly:		tCOUNTER32
	|		tGAUGE32
	|		tCOUNTER64
	;

typeSPPIonly:           tINTEGER64
        |               tUNSIGNED64
        ;

typeDeclarationRHS:	Syntax
			{
			}
	|		tTEXTUAL_CONVENTION
			{
			}
			DisplayPart
			tSTATUS Status
			tDESCRIPTION Text
			{
			}
			ReferPart
			tSYNTAX Syntax
			{
			}
	|		choiceClause
			{
			}
	;

/* REF:RFC1902,7.1.12. */
conceptualTable:	tSEQUENCE tOF row
			{
			}
	;

row:			tUPPERCASE_IDENTIFIER
			/*
			 * In this case, we do NOT allow `Module.Type'.
			 * The identifier must be defined in the local
			 * module.
			 */
			{
			}
	;

/* REF:RFC1902,7.1.12. */
entryType:		tSEQUENCE '{' sequenceItems '}'
			{
			}
;

sequenceItems:		sequenceItem
			{
			}
	|		sequenceItems ',' sequenceItem
			{
			}
	;

/*
 * In a SEQUENCE { ... } there are no sub-types, enumerations or
 * named bits. REF: draft, p.29
 * NOTE: REF:RFC1902,7.1.12. was less clear, it said:
 * `normally omitting the sub-typing information'
 */
sequenceItem:		tLOWERCASE_IDENTIFIER sequenceSyntax
			{
			}
	;

Syntax:			ObjectSyntax
			{
			}
	|		tBITS '{' NamedBits '}'
			{
			}
	;

sequenceSyntax:		/* ObjectSyntax */
			sequenceObjectSyntax
			{
			}
	|		tBITS
			{
			}
	|		tUPPERCASE_IDENTIFIER anySubType
			{
			}
	;

NamedBits:		NamedBit
			{
			}
	|		NamedBits ',' NamedBit
			{
			}
	;

NamedBit:		tLOWERCASE_IDENTIFIER
			{
			}
			'(' tNUMBER ')'
			{
			}
	;

objectIdentityClause:	tLOWERCASE_IDENTIFIER
			tOBJECT_IDENTITY
			tSTATUS Status
			tDESCRIPTION Text
			ReferPart
			tCOLON_COLON_EQUAL
			'{' objectIdentifier '}'
			{
				$$ = Node{Label: $1, Type: NodeObjectID, IDs: $10}
			}
	;

objectTypeClause:	tLOWERCASE_IDENTIFIER
			tOBJECT_TYPE
			tSYNTAX Syntax                /* old $6, new $6 */
		        UnitsPart                    /* old $7, new $7 */
                        MaxOrPIBAccessPart           /* old $8, new $8 */
                        SPPIPibReferencesPart        /* SPPI only, $9 */
                        SPPIPibTagPart               /* SPPI only, $10 */
			tSTATUS Status                /* old $9 $10, new $11 $12 */
			descriptionClause            /* old $11, new $13 */
                        SPPIErrorsPart               /* SPPI only, $14 */
			ReferPart                    /* old $12, new $15 */
			IndexPart                    /* modified, old $13, new $16 */
                        MibIndex                     /* new, $17 */
                        SPPIUniquePart               /* SPPI only, $18 */
			DefValPart                   /* old $14, new $19 */
			tCOLON_COLON_EQUAL '{' ObjectName '}' /* old $17, new $22 */
			{
				$$ = Node{Label: $1, Type: NodeObjectType, IDs: $20}
			}
	;

descriptionClause:	/* empty */
			{
			}
	|		tDESCRIPTION Text
			{
			}
	;

trapTypeClause:		fuzzy_lowercase_identifier
			{
			}
			tTRAP_TYPE
			{
			}
			tENTERPRISE objectIdentifier
			VarPart
			DescrPart
			ReferPart
			tCOLON_COLON_EQUAL tNUMBER
			{
			}
	;

VarPart:		tVARIABLES '{' VarTypes '}'
			{
			}
	|		/* empty */
			{
			}
	;

VarTypes:		VarType
			{
			}
	|		VarTypes ',' VarType
			{
			}
	;

VarType:		ObjectName
			{
			}
	;

DescrPart:		tDESCRIPTION Text
			{
			}
	|		/* empty */
			{}
	;

MaxOrPIBAccessPart:     MaxAccessPart
                        {
                        }
        |               PibAccessPart
                        {
                        }
        |               /* empty */
                        { }
        ;

PibAccessPart:          PibAccess Access
                        { }
        ;

PibAccess:              tPOLICY_ACCESS
                        {
                        }
        |               tPIB_ACCESS
                        { }
        ;

SPPIPibReferencesPart:  tPIB_REFERENCES
                        {
                        }
                        '{' Entry '}'
                        {}
        |               /* empty */
                        {}
        ;

SPPIPibTagPart:         tPIB_TAG
                        {
                        }
                        '{' ObjectName '}'
                        {}
        |               /* empty */
                        {}
        ;


SPPIUniquePart:         tUNIQUENESS
                        {
                        }
                        '{' UniqueTypesPart '}'
                        {}
        |               /* empty */
                        {}
        ;

UniqueTypesPart:        UniqueTypes
                        {}
        |               /* empty */
                        {}
        ;

UniqueTypes:            UniqueType
                        {
			}
        |               UniqueTypes ',' UniqueType
			{
                        }
        ;

UniqueType:             ObjectName
                        {}
        ;

SPPIErrorsPart:         tINSTALL_ERRORS
                        {
                        }
                        '{' Errors '}'
                        {}
        |               /* empty */
                        {}
        ;

Errors:                 Error
                        {
			}
        |               Errors ',' Error
			{
                        }
        ;

Error:                  tLOWERCASE_IDENTIFIER '(' tNUMBER ')'
			{
			}
        ;


MaxAccessPart:		tMAX_ACCESS
			{
			}
			Access
			{ }
	|		tACCESS
			{
			}
			Access
			{ }
	;

notificationTypeClause:	tLOWERCASE_IDENTIFIER
			tNOTIFICATION_TYPE
			NotificationObjectsPart
			tSTATUS Status
			tDESCRIPTION Text
			ReferPart
			tCOLON_COLON_EQUAL
			'{' NotificationName '}'
			{
				$$ = Node{Label: $1, Type: NodeNotification, IDs: $11}
			}
	;

moduleIdentityClause:	tLOWERCASE_IDENTIFIER
			tMODULE_IDENTITY
                        SubjectCategoriesPart        /* SPPI only */
			tLAST_UPDATED ExtUTCTime
			tORGANIZATION Text
			tCONTACT_INFO Text
			tDESCRIPTION Text
			RevisionPart
			tCOLON_COLON_EQUAL
			'{' objectIdentifier '}'
			{
				$$ = Node{Label: $1, Type: NodeModuleID, IDs: $15}
			}
        ;

SubjectCategoriesPart:  tSUBJECT_CATEGORIES '{' SubjectCategories '}'
                        {
                        }
        |               /* empty */
                        {
                        }
        ;

SubjectCategories:      CategoryIDs
                        {
                        }
        ;

CategoryIDs:            CategoryID
			{
			}
        |               CategoryIDs ',' CategoryID
			{
			}
        ;

CategoryID:		tLOWERCASE_IDENTIFIER
                        {
                        }
        |               tLOWERCASE_IDENTIFIER '(' tNUMBER ')'
			{
			}
        ;

ObjectSyntax:		SimpleSyntax
			{
			}
	|		typeTag SimpleSyntax
			{
			}
	|		conceptualTable
			{
			}
	|		row		     /* the uppercase name of a row  */
			{
			}
	|		entryType	     /* tSEQUENCE { ... } phrase */
			{
			}
	|		ApplicationSyntax
			{
			}
        ;

typeTag:		'[' tAPPLICATION tNUMBER ']' tIMPLICIT
			{}
	|		'[' tUNIVERSAL tNUMBER ']' tIMPLICIT
			{}
	;

/*
 * In a SEQUENCE { ... } there are no sub-types, enumerations or
 * named bits. REF: draft, p.29
 */
sequenceObjectSyntax:	sequenceSimpleSyntax
			{}
	|		sequenceApplicationSyntax
			{
			}
        ;

valueofObjectSyntax:	valueofSimpleSyntax
			{}
			/* conceptualTables and rows do not have DEFVALs
			 */
			/* valueofApplicationSyntax would not introduce any
			 * further syntax of ObjectSyntax values.
			 */
	;

SimpleSyntax:		tINTEGER			/* (-2147483648..2147483647) */
			{
			}
	|		tINTEGER
			{
			}
			integerSubType
			{
			}
	|		tINTEGER
			{
			}
			enumSpec
			{
			}
	|		tINTEGER32		/* (-2147483648..2147483647) */
			{
			}
        |		tINTEGER32
			{
			}
			integerSubType
			{
			}
	|		tUPPERCASE_IDENTIFIER
			{
			}
			enumSpec
			{
			}
	|		moduleName '.' tUPPERCASE_IDENTIFIER enumSpec
			{
			}
	|		tUPPERCASE_IDENTIFIER integerSubType
			{
			}
	|		moduleName '.' tUPPERCASE_IDENTIFIER integerSubType
			{
			}
	|		tOCTET tSTRING		/* (tSIZE (0..65535))	     */
			{
			}
	|		tOCTET tSTRING
			{
			}
			octetStringSubType
			{
			}
	|		tUPPERCASE_IDENTIFIER octetStringSubType
			{
			}
	|		moduleName '.' tUPPERCASE_IDENTIFIER octetStringSubType
			{
			}
	|		tOBJECT tIDENTIFIER anySubType
			{
			}
        ;

valueofSimpleSyntax:	tNUMBER			/* 0..2147483647 */
			/* NOTE: Counter64 must not have a DEFVAL */
			{
			}
	|		tNEGATIVENUMBER		/* -2147483648..0 */
			{
			}
        |               tNUMBER64		/* 0..18446744073709551615 */
			{
			}
	|		tNEGATIVENUMBER64	/* -9223372036854775807..0 */
			{
			}
	|		tBIN_STRING		/* number or OCTET STRING */
			{
			}
	|		tHEX_STRING		/* number or OCTET STRING */
			{
			}
	|		tLOWERCASE_IDENTIFIER	/* enumeration or named oid */
			{
			}
	|		tQUOTED_STRING		/* an OCTET STRING */
			{
			}
			/* NOTE: If the value is an OBJECT IDENTIFIER, then
			 *       it must be expressed as a single ASN.1
			 *	 identifier, and not as a collection of
			 *	 of sub-identifiers.
			 *	 REF: draft,p.34
			 *	 Anyway, we try to accept it. But it's only
			 *	 possible for numbered sub-identifiers, since
			 *	 other identifiers would make something like
			 *	 { gaga } indistiguishable from a BitsValue.
			 */
	|		'{' objectIdentifier_defval '}'
			/*
			 * This is only for some MIBs with invalid numerical
			 * OID notation for DEFVALs. We DO NOT parse them
			 * correctly. We just don't want to produce a
			 * parser error.
			 */
			{
			}
	;

/*
 * In a SEQUENCE { ... } there are no sub-types, enumerations or
 * named bits. REF: draft, p.29
 */
sequenceSimpleSyntax:	tINTEGER	anySubType
			{
			}
        |		tINTEGER32 anySubType
			{
			}
	|		tOCTET tSTRING anySubType
			{
			}
	|		tOBJECT tIDENTIFIER anySubType
			{
			}
	;

ApplicationSyntax:	tIPADDRESS anySubType
			{
			}
	|		tCOUNTER32  /* (0..4294967295)	     */
			{
			}
	|		tCOUNTER32 integerSubType
			{
			}
	|		tGAUGE32			/* (0..4294967295)	     */
			{
			}
	|		tGAUGE32 integerSubType
			{
			}
	|		tUNSIGNED32		/* (0..4294967295)	     */
			{
			}
	|		tUNSIGNED32
			{
			}
			integerSubType
			{
			}
	|		tTIMETICKS anySubType
			{
			}
	|		tOPAQUE			/* IMPLICIT OCTET STRING     */
			{
			}
	|		tOPAQUE octetStringSubType
			{
			}
	|		tCOUNTER64
			{
			}
	|		tCOUNTER64 integerSubType
			{
			}
	|		tINTEGER64               /* (-9223372036854775807..9223372036854775807) */
			{
			}
	|		tINTEGER64 integerSubType
			{
			}
	|		tUNSIGNED64	        /* (0..18446744073709551615) */
			{
			}
	|		tUNSIGNED64 integerSubType
			{
			}
	;

/*
 * In a SEQUENCE { ... } there are no sub-types, enumerations or
 * named bits. REF: draft, p.29
 */
sequenceApplicationSyntax: tIPADDRESS anySubType
			{
			}
	|		tCOUNTER32 anySubType
			{
			}
	|		tGAUGE32	anySubType	/* (0..4294967295)	     */
			{
			}
	|		tUNSIGNED32 anySubType /* (0..4294967295)	     */
			{
			}
	|		tTIMETICKS anySubType	/* (0..4294967295)	     */
			{
			}
	|		tOPAQUE			/* IMPLICIT OCTET STRING     */
			{
			}
	|		tCOUNTER64 anySubType    /* (0..18446744073709551615) */
			{
			}
	|		tINTEGER64	        /* (-9223372036854775807..9223372036854775807) */
			{
			}
	|		tUNSIGNED64	        /* (0..18446744073709551615) */
			{
			}
	;

anySubType:		integerSubType
			{
			}
	|	        octetStringSubType
			{
			}
	|		enumSpec
			{
			}
	|		/* empty */
			{
			}
        ;


/* REF: draft,p.46 */
integerSubType:		'(' ranges ')'		/* at least one range        */
			/*
			 * the specification mentions an alternative of an
			 * empty RHS here. this would lead to reduce/reduce
			 * conflicts. instead, we differentiate the parent
			 * rule(s) (SimpleSyntax).
			 */
			{}
	;

octetStringSubType:	'(' tSIZE '(' ranges ')' ')'
			/*
			 * the specification mentions an alternative of an
			 * empty RHS here. this would lead to reduce/reduce
			 * conflicts. instead, we differentiate the parent
			 * rule(s) (SimpleSyntax).
			 */
			{
			}
	;

ranges:			range
			{
			}
	|		ranges '|' range
			{
			}
	;

range:			value
			{
			}
	|		value tDOT_DOT value
			{
			}
	;

value:			tNEGATIVENUMBER
			{
			}
	|		tNUMBER
			{
			}
	|		tNEGATIVENUMBER64
			{
			}
	|		tNUMBER64
			{
			}
	|		tHEX_STRING
			{
			}
	|		tBIN_STRING
			{
			}
	;

enumSpec:		'{' enumItems '}'
			{
			}
	;

enumItems:		enumItem
			{
			}
	|		enumItems ',' enumItem
			{
			}
	;

enumItem:		tLOWERCASE_IDENTIFIER
			{
			}
			'(' enumNumber ')'
			{
			}
	;

enumNumber:		tNUMBER
			{
			}
	|		tNEGATIVENUMBER
			{
			}
	;

Status:			tLOWERCASE_IDENTIFIER
			{
			}
        ;

Status_Capabilities:	tLOWERCASE_IDENTIFIER
			{
			}
        ;

DisplayPart:		tDISPLAY_HINT Text
			{
			}
        |		/* empty */
			{
			}
        ;

UnitsPart:		tUNITS Text
			{
			}
        |		/* empty */
			{
			}
        ;

Access:			tLOWERCASE_IDENTIFIER
			{
			}
        ;

IndexPart:              tPIB_INDEX
                        {
                        }
                        '{' Entry '}'
                        {
			}
        |		tAUGMENTS '{' Entry '}'
			{
			}
        |		tEXTENDS
                        {
                        }
                        '{' Entry '}'
			{
			}
        |		/* empty */
			{
			}
	;

MibIndex:		tINDEX
                        {
			}
			'{' IndexTypes '}'
			{
                        }
        |               /* empty */
			{
			}
        ;

IndexTypes:		IndexType
			{
			}
        |		IndexTypes ',' IndexType
			{
			}
	;

IndexType:		tIMPLIED Index
			{
			}
	|		Index
			{
			}
	;

Index:			ObjectName
			{
			}
        ;

Entry:			ObjectName
			{
			}
        ;

DefValPart:		tDEFVAL '{' Value '}'
			{
			}
	|		/* empty */
			{}
	;

Value:			valueofObjectSyntax
			{}
	|		'{' BitsValue '}'
			{
			}
	;

BitsValue:		BitNames
			{}
	|		/* empty */
			{}
	;

BitNames:		tLOWERCASE_IDENTIFIER
			{
			}
	|		BitNames ',' tLOWERCASE_IDENTIFIER
			{
			}
	;

ObjectName:		objectIdentifier
			{
			}
	;

NotificationName:	objectIdentifier
			{
			}
	;

ReferPart:		tREFERENCE Text
			{
			}
	|		/* empty */
			{}
	;

RevisionPart:		Revisions
			{}
	|		/* empty */
			{}
	;

Revisions:		Revision
			{}
	|		Revisions Revision
			{}
	;

Revision:		tREVISION ExtUTCTime
			{
			}
			tDESCRIPTION Text
			{
			}
	;

NotificationObjectsPart: tOBJECTS '{' Objects '}'
			{
			}
	|		/* empty */
			{
			}
	;

ObjectGroupObjectsPart:	tOBJECTS '{' Objects '}'
			{
			}
	;

Objects:		Object
			{
			}
	|		Objects ',' Object
			{
			}
	;

Object:			ObjectName
			{
			}
	;

NotificationsPart:	tNOTIFICATIONS '{' Notifications '}'
			{
			}
	;

Notifications:		Notification
			{
			}
	|		Notifications ',' Notification
			{
			}
	;

Notification:		NotificationName
			{
			}
	;

Text:			tQUOTED_STRING
			{
			}
	;

ExtUTCTime:		tQUOTED_STRING
			{
			}
	;

objectIdentifier:	subidentifiers
			{
			}
	;

subidentifiers:
			subidentifier
			{
				$$ = []SubID{$1}
			}
	|		subidentifiers
			subidentifier
			{
				$$ = append($1, $2)
			}
        ;

subidentifier:
			/* LOWERCASE_IDENTIFIER */
			fuzzy_lowercase_identifier
			{
				$$ = SubID{ID: -1, Label: $1}
			}
	|		tNUMBER
			{
				$$ = SubID{ID: int($1)}
			}
	|		tLOWERCASE_IDENTIFIER '(' tNUMBER ')'
			{
				$$ = SubID{int($3), $1}
			}
	;

objectIdentifier_defval: subidentifiers_defval
			{}
        ;

subidentifiers_defval:	subidentifier_defval
			{}
	|		subidentifiers_defval subidentifier_defval
			{}
        ;

subidentifier_defval:	tLOWERCASE_IDENTIFIER '(' tNUMBER ')'
			{}
	|		tNUMBER
			{}
	;

objectGroupClause:	tLOWERCASE_IDENTIFIER
			{
			}
			tOBJECT_GROUP
			{
			}
			ObjectGroupObjectsPart
			tSTATUS Status
			tDESCRIPTION Text
			{
			}
			ReferPart
			tCOLON_COLON_EQUAL '{' objectIdentifier '}'
			{
			}
	;

notificationGroupClause: tLOWERCASE_IDENTIFIER
			{
			}
			tNOTIFICATION_GROUP
			{
			}
			NotificationsPart
			tSTATUS Status
			tDESCRIPTION Text
			{
			}
			ReferPart
			tCOLON_COLON_EQUAL '{' objectIdentifier '}'
			{
			}
	;

moduleComplianceClause:	tLOWERCASE_IDENTIFIER
			{
			}
			tMODULE_COMPLIANCE
			{
			}
			tSTATUS Status
			tDESCRIPTION Text
			{
			}
			ReferPart
			ComplianceModulePart
			tCOLON_COLON_EQUAL '{' objectIdentifier '}'
			{
			}
	;

ComplianceModulePart:	ComplianceModules
			{
			}
	;

ComplianceModules:	ComplianceModule
			{
			}
	|		ComplianceModules ComplianceModule
			{
			}
	;

ComplianceModule:	tMODULE ComplianceModuleName
			{
			}
			MandatoryPart
			CompliancePart
			{
			}
	;

ComplianceModuleName:	tUPPERCASE_IDENTIFIER objectIdentifier
			{
			}
	|		tUPPERCASE_IDENTIFIER
			{
			}
	|		/* empty, only if contained in MIB module */
			{
			}
	;

MandatoryPart:		tMANDATORY_GROUPS '{' MandatoryGroups '}'
			{
			}
	|		/* empty */
			{
			}
	;

MandatoryGroups:	MandatoryGroup
			{
			}
	|		MandatoryGroups ',' MandatoryGroup
			{
			}
	;

MandatoryGroup:		objectIdentifier
			{
			}
	;

CompliancePart:		Compliances
			{
			}
	|		/* empty */
			{
			}
	;

Compliances:		Compliance
			{
			}
	|		Compliances Compliance
			{
			}
	;

Compliance:		ComplianceGroup
			{
			}
	|		ComplianceObject
			{
			}
	;

ComplianceGroup:	tGROUP
			{
			}
			objectIdentifier
			tDESCRIPTION Text
			{
			}
	;

ComplianceObject:	tOBJECT
			{
			}
			ObjectName
			SyntaxPart
			WriteSyntaxPart                 /* modified for SPPI */
			AccessPart                      /* modified for SPPI */
			tDESCRIPTION Text
			{
			}
	;

SyntaxPart:		tSYNTAX Syntax
			{
			}
	|		/* empty */
			{
			}
	;

WriteSyntaxPart:	tWRITE_SYNTAX WriteSyntax
			{
			}
	|		/* empty */
			{
			}
	;

WriteSyntax:		Syntax
			{
			}
	;

AccessPart:		tMIN_ACCESS Access
			{
			}
        |               tPIB_MIN_ACCESS Access
                        {
                        }
	|		/* empty */
			{
			}
	;

agentCapabilitiesClause: tLOWERCASE_IDENTIFIER
			{
			}
			tAGENT_CAPABILITIES
			{
			}
			tPRODUCT_RELEASE Text
			tSTATUS Status_Capabilities
			tDESCRIPTION Text
			{
			}
			ReferPart
			ModulePart_Capabilities
			tCOLON_COLON_EQUAL '{' objectIdentifier '}'
			{
			}
	;

ModulePart_Capabilities: Modules_Capabilities
			{}
	|		/* empty */
			{}
	;

Modules_Capabilities:	Module_Capabilities
			{}
	|		Modules_Capabilities Module_Capabilities
			{}
	;

Module_Capabilities:	tSUPPORTS ModuleName_Capabilities
			{
			}
			tINCLUDES '{' CapabilitiesGroups '}'
			VariationPart
			{
			}
	;

CapabilitiesGroups:	CapabilitiesGroup
			{
			}
	|		CapabilitiesGroups ',' CapabilitiesGroup
			{
			}
	;

CapabilitiesGroup:	objectIdentifier
			{
			}
	;

ModuleName_Capabilities: tUPPERCASE_IDENTIFIER objectIdentifier
			{
			}
	|		tUPPERCASE_IDENTIFIER
			{
			}
	;

VariationPart:		Variations
			{}
	|		/* empty */
			{}
	;

Variations:		Variation
			{}
	|		Variations Variation
			{}
	;

Variation:		tVARIATION ObjectName
			{
			}
			SyntaxPart
			WriteSyntaxPart
			VariationAccessPart
			CreationPart
			DefValPart
			{
			}
			tDESCRIPTION Text
			{
			}
	;

VariationAccessPart:	tACCESS VariationAccess
			{}
	|		/* empty */
			{}
	;

VariationAccess:	tLOWERCASE_IDENTIFIER
			{
			}
        ;

CreationPart:		tCREATION_REQUIRES '{' Cells '}'
			{
			}
	|		/* empty */
			{}
	;

Cells:			Cell
			{}
	|		Cells ',' Cell
			{}
	;

Cell:			ObjectName
			{}
	;

%%
