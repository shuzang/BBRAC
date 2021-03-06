package utils

import (
	"strconv"
	"strings"

	"github.com/mewmew/float/binary128"
)

// ToFloat64 convert 128bits IEEE 754 floating-point number in base2 to decimal
func ToFloat64(hex string) float64 {
	a, b := hex[2:18], hex[18:]
	numa, _ := strconv.ParseUint(a, 16, 64)
	numb, _ := strconv.ParseUint(b, 16, 64)
	res, _ := binary128.NewFromBits(numa, numb).Float64()
	return res
}

// FromFloat64 convert x to a nearest quadruple precision floating-point number,
// then returns the string representation of x in base16
func FromFloat64(x float64) string {
	var res string
	f, _ := binary128.NewFromFloat64(x)
	a, b := f.Bits() // 128bits, a is first 64bits, b is second bits
	if b != 0 {
		res = strconv.FormatUint(a, 16) + strconv.FormatUint(b, 16)
	} else {
		res = strconv.FormatUint(a, 16) + strconv.FormatUint(b, 16) + "000000000000000"
	}
	return "0x" + strings.ToUpper(res)
}
