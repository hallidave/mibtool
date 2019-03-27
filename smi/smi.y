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
%token DOT_DOT
%token COLON_COLON_EQUAL

%token <id>UPPERCASE_IDENTIFIER
%token <id>LOWERCASE_IDENTIFIER
%token <unsigned32>NUMBER
%token <integer32>NEGATIVENUMBER
%token <unsigned64>NUMBER64
%token <integer64>NEGATIVENUMBER64
%token <text>BIN_STRING
%token <text>HEX_STRING
%token <text>QUOTED_STRING

%token <id>ACCESS
%token <id>AGENT_CAPABILITIES
%token <id>APPLICATION
%token <id>AUGMENTS
%token <id>BEGIN_
%token <id>BITS
%token <id>CHOICE
%token <id>CONTACT_INFO
%token <id>CREATION_REQUIRES
%token <id>COUNTER32
%token <id>COUNTER64
%token <id>DEFINITIONS
%token <id>DEFVAL
%token <id>DESCRIPTION
%token <id>DISPLAY_HINT
%token <id>END
%token <id>ENTERPRISE
%token <id>EXPORTS
%token <id>EXTENDS
%token <id>FROM
%token <id>GROUP
%token <id>GAUGE32
%token <id>IDENTIFIER
%token <id>IMPLICIT
%token <id>IMPLIED
%token <id>IMPORTS
%token <id>INCLUDES
%token <id>INDEX
%token <id>INSTALL_ERRORS
%token <id>INTEGER
%token <id>INTEGER32
%token <id>INTEGER64
%token <id>IPADDRESS
%token <id>LAST_UPDATED
%token <id>MACRO
%token <id>MANDATORY_GROUPS
%token <id>MAX_ACCESS
%token <id>MIN_ACCESS
%token <id>MODULE
%token <id>MODULE_COMPLIANCE
%token <id>MODULE_IDENTITY
%token <id>NOT_ACCESSIBLE
%token <id>NOTIFICATIONS
%token <id>NOTIFICATION_GROUP
%token <id>NOTIFICATION_TYPE
%token <id>OBJECT
%token <id>OBJECT_GROUP
%token <id>OBJECT_IDENTITY
%token <id>OBJECT_TYPE
%token <id>OBJECTS
%token <id>OCTET
%token <id>OF
%token <id>ORGANIZATION
%token <id>OPAQUE
%token <id>PIB_ACCESS
%token <id>PIB_DEFINITIONS
%token <id>PIB_INDEX
%token <id>PIB_MIN_ACCESS
%token <id>PIB_REFERENCES
%token <id>PIB_TAG
%token <id>POLICY_ACCESS
%token <id>PRODUCT_RELEASE
%token <id>REFERENCE
%token <id>REVISION
%token <id>SEQUENCE
%token <id>SIZE
%token <id>STATUS
%token <id>STRING
%token <id>SUBJECT_CATEGORIES
%token <id>SUPPORTS
%token <id>SYNTAX
%token <id>TEXTUAL_CONVENTION
%token <id>TIMETICKS
%token <id>TRAP_TYPE
%token <id>UNIQUENESS
%token <id>UNITS
%token <id>UNIVERSAL
%token <id>UNSIGNED32
%token <id>UNSIGNED64
%token <id>VALUE
%token <id>VARIABLES
%token <id>VARIATION
%token <id>WRITE_SYNTAX



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
			COLON_COLON_EQUAL BEGIN_
			exportsClause
			linkagePart
			declarationPart
			END
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

definitions:            DEFINITIONS
                        {}
        |               PIB_DEFINITIONS
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

linkageClause:		IMPORTS importPart ';'
			{
				$$ = $2
			}
        ;

exportsClause:		/* empty */
			{}
	|		EXPORTS
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
                        FROM
                        moduleName
			{
				$$ = Import{From: $3, Symbols: $1}
			}
	;

importIdentifiers:	importIdentifier
			{
				$$ = []string{$1}
			}
	|		importIdentifiers ',' importIdentifier
			{
				$$ = append($1, $3)
			}
	;

/*
 * Note that some named types must not be imported, REF:RFC1902,590 .
 */
importIdentifier:	LOWERCASE_IDENTIFIER
	|		UPPERCASE_IDENTIFIER
	|		importedKeyword
	;

/*
 * These keywords are no real keywords. They have to be imported
 * from the SMI, TC, CONF MIBs.
 */
importedKeyword:	importedSMIKeyword
                        {}
        |               importedSPPIKeyword
                        {}
        |               BITS
	|		INTEGER32
	|		IPADDRESS
	|		MANDATORY_GROUPS
	|		MODULE_COMPLIANCE
	|		MODULE_IDENTITY
	|		OBJECT_GROUP
	|		OBJECT_IDENTITY
	|		OBJECT_TYPE
	|		OPAQUE
	|		TEXTUAL_CONVENTION
	|		TIMETICKS
	|		UNSIGNED32
        ;

importedSMIKeyword:     AGENT_CAPABILITIES
	|		COUNTER32
	|		COUNTER64
	|		GAUGE32
	|		NOTIFICATION_GROUP
	|		NOTIFICATION_TYPE
	|		TRAP_TYPE
	;

importedSPPIKeyword:	INTEGER64
	|		UNSIGNED64
	;

moduleName:		UPPERCASE_IDENTIFIER
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
 * the scanner until 'END' is read. This is just to make the SMI
 * documents readable.
 */
macroClause:		macroName
			{
			}
			MACRO
			{
			}
			/* the scanner skips until... */
			END
			{
                        }
	;

macroName:		MODULE_IDENTITY     { $$ = $1; }
	|		OBJECT_TYPE	    { $$ = $1; }
	|		TRAP_TYPE	    { $$ = $1; }
	|		NOTIFICATION_TYPE   { $$ = $1; }
	|		OBJECT_IDENTITY	    { $$ = $1; }
	|		TEXTUAL_CONVENTION  { $$ = $1; }
	|		OBJECT_GROUP	    { $$ = $1; }
	|		NOTIFICATION_GROUP  { $$ = $1; }
	|		MODULE_COMPLIANCE   { $$ = $1; }
	|		AGENT_CAPABILITIES  { $$ = $1; }
	;

choiceClause:		CHOICE
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
fuzzy_lowercase_identifier:	LOWERCASE_IDENTIFIER
			{
			}
	|
			UPPERCASE_IDENTIFIER
			{
			}
	;

/* valueDeclaration:	LOWERCASE_IDENTIFIER */
valueDeclaration:	fuzzy_lowercase_identifier
			OBJECT IDENTIFIER
			COLON_COLON_EQUAL '{' objectIdentifier '}'
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
			COLON_COLON_EQUAL typeDeclarationRHS
			{
			}
	;

typeName:		UPPERCASE_IDENTIFIER
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

typeSMIandSPPI:		IPADDRESS
	|		TIMETICKS
	|		OPAQUE
	|		INTEGER32
	|		UNSIGNED32
        ;

typeSMIonly:		COUNTER32
	|		GAUGE32
	|		COUNTER64
	;

typeSPPIonly:           INTEGER64
        |               UNSIGNED64
        ;

typeDeclarationRHS:	Syntax
			{
			}
	|		TEXTUAL_CONVENTION
			{
			}
			DisplayPart
			STATUS Status
			DESCRIPTION Text
			{
			}
			ReferPart
			SYNTAX Syntax
			{
			}
	|		choiceClause
			{
			}
	;

/* REF:RFC1902,7.1.12. */
conceptualTable:	SEQUENCE OF row
			{
			}
	;

row:			UPPERCASE_IDENTIFIER
			/*
			 * In this case, we do NOT allow `Module.Type'.
			 * The identifier must be defined in the local
			 * module.
			 */
			{
			}
	;

/* REF:RFC1902,7.1.12. */
entryType:		SEQUENCE '{' sequenceItems '}'
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
sequenceItem:		LOWERCASE_IDENTIFIER sequenceSyntax
			{
			}
	;

Syntax:			ObjectSyntax
			{
			}
	|		BITS '{' NamedBits '}'
			{
			}
	;

sequenceSyntax:		/* ObjectSyntax */
			sequenceObjectSyntax
			{
			}
	|		BITS
			{
			}
	|		UPPERCASE_IDENTIFIER anySubType
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

NamedBit:		LOWERCASE_IDENTIFIER
			{
			}
			'(' NUMBER ')'
			{
			}
	;

objectIdentityClause:	LOWERCASE_IDENTIFIER
			OBJECT_IDENTITY
			STATUS Status
			DESCRIPTION Text
			ReferPart
			COLON_COLON_EQUAL
			'{' objectIdentifier '}'
			{
				$$ = Node{Label: $1, Type: NodeObjectID, IDs: $10}
			}
	;

objectTypeClause:	LOWERCASE_IDENTIFIER
			OBJECT_TYPE
			SYNTAX Syntax                /* old $6, new $6 */
		        UnitsPart                    /* old $7, new $7 */
                        MaxOrPIBAccessPart           /* old $8, new $8 */
                        SPPIPibReferencesPart        /* SPPI only, $9 */
                        SPPIPibTagPart               /* SPPI only, $10 */
			STATUS Status                /* old $9 $10, new $11 $12 */
			descriptionClause            /* old $11, new $13 */
                        SPPIErrorsPart               /* SPPI only, $14 */
			ReferPart                    /* old $12, new $15 */
			IndexPart                    /* modified, old $13, new $16 */
                        MibIndex                     /* new, $17 */
                        SPPIUniquePart               /* SPPI only, $18 */
			DefValPart                   /* old $14, new $19 */
			COLON_COLON_EQUAL '{' ObjectName '}' /* old $17, new $22 */
			{
				$$ = Node{Label: $1, Type: NodeObjectType, IDs: $20}
			}
	;

descriptionClause:	/* empty */
			{
			}
	|		DESCRIPTION Text
			{
			}
	;

trapTypeClause:		fuzzy_lowercase_identifier
			{
			}
			TRAP_TYPE
			{
			}
			ENTERPRISE objectIdentifier
			VarPart
			DescrPart
			ReferPart
			COLON_COLON_EQUAL NUMBER
			{
			}
	;

VarPart:		VARIABLES '{' VarTypes '}'
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

DescrPart:		DESCRIPTION Text
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

PibAccess:              POLICY_ACCESS
                        {
                        }
        |               PIB_ACCESS
                        { }
        ;

SPPIPibReferencesPart:  PIB_REFERENCES
                        {
                        }
                        '{' Entry '}'
                        {}
        |               /* empty */
                        {}
        ;

SPPIPibTagPart:         PIB_TAG
                        {
                        }
                        '{' ObjectName '}'
                        {}
        |               /* empty */
                        {}
        ;


SPPIUniquePart:         UNIQUENESS
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

SPPIErrorsPart:         INSTALL_ERRORS
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

Error:                  LOWERCASE_IDENTIFIER '(' NUMBER ')'
			{
			}
        ;


MaxAccessPart:		MAX_ACCESS
			{
			}
			Access
			{ }
	|		ACCESS
			{
			}
			Access
			{ }
	;

notificationTypeClause:	LOWERCASE_IDENTIFIER
			NOTIFICATION_TYPE
			NotificationObjectsPart
			STATUS Status
			DESCRIPTION Text
			ReferPart
			COLON_COLON_EQUAL
			'{' NotificationName '}'
			{
				$$ = Node{Label: $1, Type: NodeNotification, IDs: $11}
			}
	;

moduleIdentityClause:	LOWERCASE_IDENTIFIER
			MODULE_IDENTITY
                        SubjectCategoriesPart        /* SPPI only */
			LAST_UPDATED ExtUTCTime
			ORGANIZATION Text
			CONTACT_INFO Text
			DESCRIPTION Text
			RevisionPart
			COLON_COLON_EQUAL
			'{' objectIdentifier '}'
			{
				$$ = Node{Label: $1, Type: NodeModuleID, IDs: $15}
			}
        ;

SubjectCategoriesPart:  SUBJECT_CATEGORIES '{' SubjectCategories '}'
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

CategoryID:		LOWERCASE_IDENTIFIER
                        {
                        }
        |               LOWERCASE_IDENTIFIER '(' NUMBER ')'
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
	|		entryType	     /* SEQUENCE { ... } phrase */
			{
			}
	|		ApplicationSyntax
			{
			}
        ;

typeTag:		'[' APPLICATION NUMBER ']' IMPLICIT
			{}
	|		'[' UNIVERSAL NUMBER ']' IMPLICIT
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

SimpleSyntax:		INTEGER			/* (-2147483648..2147483647) */
			{
			}
	|		INTEGER
			{
			}
			integerSubType
			{
			}
	|		INTEGER
			{
			}
			enumSpec
			{
			}
	|		INTEGER32		/* (-2147483648..2147483647) */
			{
			}
        |		INTEGER32
			{
			}
			integerSubType
			{
			}
	|		UPPERCASE_IDENTIFIER
			{
			}
			enumSpec
			{
			}
	|		moduleName '.' UPPERCASE_IDENTIFIER enumSpec
			{
			}
	|		UPPERCASE_IDENTIFIER integerSubType
			{
			}
	|		moduleName '.' UPPERCASE_IDENTIFIER integerSubType
			{
			}
	|		OCTET STRING		/* (SIZE (0..65535))	     */
			{
			}
	|		OCTET STRING
			{
			}
			octetStringSubType
			{
			}
	|		UPPERCASE_IDENTIFIER octetStringSubType
			{
			}
	|		moduleName '.' UPPERCASE_IDENTIFIER octetStringSubType
			{
			}
	|		OBJECT IDENTIFIER anySubType
			{
			}
        ;

valueofSimpleSyntax:	NUMBER			/* 0..2147483647 */
			/* NOTE: Counter64 must not have a DEFVAL */
			{
			}
	|		NEGATIVENUMBER		/* -2147483648..0 */
			{
			}
        |               NUMBER64		/* 0..18446744073709551615 */
			{
			}
	|		NEGATIVENUMBER64	/* -9223372036854775807..0 */
			{
			}
	|		BIN_STRING		/* number or OCTET STRING */
			{
			}
	|		HEX_STRING		/* number or OCTET STRING */
			{
			}
	|		LOWERCASE_IDENTIFIER	/* enumeration or named oid */
			{
			}
	|		QUOTED_STRING		/* an OCTET STRING */
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
sequenceSimpleSyntax:	INTEGER	anySubType
			{
			}
        |		INTEGER32 anySubType
			{
			}
	|		OCTET STRING anySubType
			{
			}
	|		OBJECT IDENTIFIER anySubType
			{
			}
	;

ApplicationSyntax:	IPADDRESS anySubType
			{
			}
	|		COUNTER32  /* (0..4294967295)	     */
			{
			}
	|		COUNTER32 integerSubType
			{
			}
	|		GAUGE32			/* (0..4294967295)	     */
			{
			}
	|		GAUGE32 integerSubType
			{
			}
	|		UNSIGNED32		/* (0..4294967295)	     */
			{
			}
	|		UNSIGNED32
			{
			}
			integerSubType
			{
			}
	|		TIMETICKS anySubType
			{
			}
	|		OPAQUE			/* IMPLICIT OCTET STRING     */
			{
			}
	|		OPAQUE octetStringSubType
			{
			}
	|		COUNTER64
			{
			}
	|		COUNTER64 integerSubType
			{
			}
	|		INTEGER64               /* (-9223372036854775807..9223372036854775807) */
			{
			}
	|		INTEGER64 integerSubType
			{
			}
	|		UNSIGNED64	        /* (0..18446744073709551615) */
			{
			}
	|		UNSIGNED64 integerSubType
			{
			}
	;

/*
 * In a SEQUENCE { ... } there are no sub-types, enumerations or
 * named bits. REF: draft, p.29
 */
sequenceApplicationSyntax: IPADDRESS anySubType
			{
			}
	|		COUNTER32 anySubType
			{
			}
	|		GAUGE32	anySubType	/* (0..4294967295)	     */
			{
			}
	|		UNSIGNED32 anySubType /* (0..4294967295)	     */
			{
			}
	|		TIMETICKS anySubType	/* (0..4294967295)	     */
			{
			}
	|		OPAQUE			/* IMPLICIT OCTET STRING     */
			{
			}
	|		COUNTER64 anySubType    /* (0..18446744073709551615) */
			{
			}
	|		INTEGER64	        /* (-9223372036854775807..9223372036854775807) */
			{
			}
	|		UNSIGNED64	        /* (0..18446744073709551615) */
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

octetStringSubType:	'(' SIZE '(' ranges ')' ')'
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
	|		value DOT_DOT value
			{
			}
	;

value:			NEGATIVENUMBER
			{
			}
	|		NUMBER
			{
			}
	|		NEGATIVENUMBER64
			{
			}
	|		NUMBER64
			{
			}
	|		HEX_STRING
			{
			}
	|		BIN_STRING
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

enumItem:		LOWERCASE_IDENTIFIER
			{
			}
			'(' enumNumber ')'
			{
			}
	;

enumNumber:		NUMBER
			{
			}
	|		NEGATIVENUMBER
			{
			}
	;

Status:			LOWERCASE_IDENTIFIER
			{
			}
        ;

Status_Capabilities:	LOWERCASE_IDENTIFIER
			{
			}
        ;

DisplayPart:		DISPLAY_HINT Text
			{
			}
        |		/* empty */
			{
			}
        ;

UnitsPart:		UNITS Text
			{
			}
        |		/* empty */
			{
			}
        ;

Access:			LOWERCASE_IDENTIFIER
			{
			}
        ;

IndexPart:              PIB_INDEX
                        {
                        }
                        '{' Entry '}'
                        {
			}
        |		AUGMENTS '{' Entry '}'
			{
			}
        |		EXTENDS
                        {
                        }
                        '{' Entry '}'
			{
			}
        |		/* empty */
			{
			}
	;

MibIndex:		INDEX
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

IndexType:		IMPLIED Index
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

DefValPart:		DEFVAL '{' Value '}'
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

BitNames:		LOWERCASE_IDENTIFIER
			{
			}
	|		BitNames ',' LOWERCASE_IDENTIFIER
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

ReferPart:		REFERENCE Text
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

Revision:		REVISION ExtUTCTime
			{
			}
			DESCRIPTION Text
			{
			}
	;

NotificationObjectsPart: OBJECTS '{' Objects '}'
			{
			}
	|		/* empty */
			{
			}
	;

ObjectGroupObjectsPart:	OBJECTS '{' Objects '}'
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

NotificationsPart:	NOTIFICATIONS '{' Notifications '}'
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

Text:			QUOTED_STRING
			{
			}
	;

ExtUTCTime:		QUOTED_STRING
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
	|		NUMBER
			{
				$$ = SubID{ID: int($1)}
			}
	|		LOWERCASE_IDENTIFIER '(' NUMBER ')'
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

subidentifier_defval:	LOWERCASE_IDENTIFIER '(' NUMBER ')'
			{}
	|		NUMBER
			{}
	;

objectGroupClause:	LOWERCASE_IDENTIFIER
			{
			}
			OBJECT_GROUP
			{
			}
			ObjectGroupObjectsPart
			STATUS Status
			DESCRIPTION Text
			{
			}
			ReferPart
			COLON_COLON_EQUAL '{' objectIdentifier '}'
			{
			}
	;

notificationGroupClause: LOWERCASE_IDENTIFIER
			{
			}
			NOTIFICATION_GROUP
			{
			}
			NotificationsPart
			STATUS Status
			DESCRIPTION Text
			{
			}
			ReferPart
			COLON_COLON_EQUAL '{' objectIdentifier '}'
			{
			}
	;

moduleComplianceClause:	LOWERCASE_IDENTIFIER
			{
			}
			MODULE_COMPLIANCE
			{
			}
			STATUS Status
			DESCRIPTION Text
			{
			}
			ReferPart
			ComplianceModulePart
			COLON_COLON_EQUAL '{' objectIdentifier '}'
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

ComplianceModule:	MODULE ComplianceModuleName
			{
			}
			MandatoryPart
			CompliancePart
			{
			}
	;

ComplianceModuleName:	UPPERCASE_IDENTIFIER objectIdentifier
			{
			}
	|		UPPERCASE_IDENTIFIER
			{
			}
	|		/* empty, only if contained in MIB module */
			{
			}
	;

MandatoryPart:		MANDATORY_GROUPS '{' MandatoryGroups '}'
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

ComplianceGroup:	GROUP
			{
			}
			objectIdentifier
			DESCRIPTION Text
			{
			}
	;

ComplianceObject:	OBJECT
			{
			}
			ObjectName
			SyntaxPart
			WriteSyntaxPart                 /* modified for SPPI */
			AccessPart                      /* modified for SPPI */
			DESCRIPTION Text
			{
			}
	;

SyntaxPart:		SYNTAX Syntax
			{
			}
	|		/* empty */
			{
			}
	;

WriteSyntaxPart:	WRITE_SYNTAX WriteSyntax
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

AccessPart:		MIN_ACCESS Access
			{
			}
        |               PIB_MIN_ACCESS Access
                        {
                        }
	|		/* empty */
			{
			}
	;

agentCapabilitiesClause: LOWERCASE_IDENTIFIER
			{
			}
			AGENT_CAPABILITIES
			{
			}
			PRODUCT_RELEASE Text
			STATUS Status_Capabilities
			DESCRIPTION Text
			{
			}
			ReferPart
			ModulePart_Capabilities
			COLON_COLON_EQUAL '{' objectIdentifier '}'
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

Module_Capabilities:	SUPPORTS ModuleName_Capabilities
			{
			}
			INCLUDES '{' CapabilitiesGroups '}'
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

ModuleName_Capabilities: UPPERCASE_IDENTIFIER objectIdentifier
			{
			}
	|		UPPERCASE_IDENTIFIER
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

Variation:		VARIATION ObjectName
			{
			}
			SyntaxPart
			WriteSyntaxPart
			VariationAccessPart
			CreationPart
			DefValPart
			{
			}
			DESCRIPTION Text
			{
			}
	;

VariationAccessPart:	ACCESS VariationAccess
			{}
	|		/* empty */
			{}
	;

VariationAccess:	LOWERCASE_IDENTIFIER
			{
			}
        ;

CreationPart:		CREATION_REQUIRES '{' Cells '}'
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
