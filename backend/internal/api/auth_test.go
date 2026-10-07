package api

import "testing"

func TestNormalizePhone(t *testing.T) {
	cases := []struct {
		in   string
		want string
		ok   bool
	}{
		{"+993 61 188798", "+99361188798", true},
		{" +993 (61) 18-87-98 ", "+99361188798", true},
		{"+99361188798", "+99361188798", true},
		{"61188798", "61188798", false},
		{"", "", false},
		{"+99", "+99", false},
		{"abc", "", false},
	}
	for _, c := range cases {
		got, ok := normalizePhone(c.in)
		if got != c.want || ok != c.ok {
			t.Errorf("normalizePhone(%q) = %q, %v; want %q, %v", c.in, got, ok, c.want, c.ok)
		}
	}
}
