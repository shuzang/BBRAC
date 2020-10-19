package utils

import (
	"math"
	"testing"
)

func TestToFloat64(t *testing.T) {
	tests := []struct {
		hex  string
		want float64
	}{
		// one
		// 0x3FFF0000000000000000000000000000 = 1
		{hex: "0x3FFF0000000000000000000000000000", want: 1},
		// smallest number larger than one
		// 0x3FFF0000000000000000000000000001 = 1 + 2^{-112}
		{hex: "0x3FFF0000000000000000000000000001", want: 1 + math.Exp2(-112)},
		// -2
		// 0xC0000000000000000000000000000000 = -2
		{hex: "0xC0000000000000000000000000000000", want: -2},
		// pi
		// 0x4000921FB54442D18469898CC51701B8 = pi
		{hex: "0x4000921FB54442D18469898CC51701B8", want: 3.1415926535897932384626433832795028},
		// 1/3
		// 0x3FFD5555555555555555555555555555 = 1/3
		{hex: "0x3FFD5555555555555555555555555555", want: 0.3333333333333333},
	}

	for _, g := range tests {
		f := ToFloat64(g.hex)
		if g.want != f {
			t.Errorf("quadruple precision floating-point number: %v mismatch; expected %v, got %v", g.hex, g.want, f)
		}
	}
}

func TestFromFloat64(t *testing.T) {
	tests := []struct {
		num  float64
		want string
	}{
		// one
		// 0x3FFF0000000000000000000000000000 = 1
		{num: 1, want: "0x3FFF0000000000000000000000000000"},
		// smallest number larger than one
		// 0x3FFF0000000000000000000000000001 = 1 + 2^{-112}
		//{num: 1 + math.Exp2(-112), want: "0x3FFF0000000000000000000000000001"},
		// -2
		// 0xC0000000000000000000000000000000 = -2
		{num: -2, want: "0xC0000000000000000000000000000000"},
		// pi
		// 0x4000921FB54442D18469898CC51701B8 = pi
		{num: 3.1415926535897932384626433832795028, want: "0x4000921FB54442D18469898CC51701B8"},
		// 1/3
		// 0x3FFD5555555555555555555555555555 = 1/3
		{num: 0.3333333333333333, want: "0x3FFD5555555555555555555555555555"},
	}

	for _, g := range tests {
		f := FromFloat64(g.num)
		if g.want != f {
			t.Errorf("float64: %v mismatch; expected %v, got %v", g.num, g.want, f)
		}
	}
}
