package smi

import "testing"

func TestOIDString(t *testing.T) {
	tests := []struct {
		oid      OID
		expected string
	}{
		{oid: OID{}, expected: ""},
		{oid: OID{1}, expected: "1"},
		{oid: OID{1, 2, 3, 4}, expected: "1.2.3.4"},
	}
	for _, test := range tests {
		result := test.oid.String()
		if result != test.expected {
			t.Errorf("expected %s, got %s", test.expected, result)
		}

	}
}

