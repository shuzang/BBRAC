// SPDX-License-Identifier:MIT
pragma solidity >0.6.0 <0.8.0;
import "./ABDKMathQuad.sol";

library Utils {
    
    /// @dev stringCompare determine whether the strings are equal, using length + hash comparson to reduce gas consumption
    function stringCompare(string memory a, string memory b) public pure returns (bool) {
        bytes memory _a = bytes(a);
        bytes memory _b = bytes(b);
        if (_a.length != _b.length) {
            return false;
        } else {
            if (_a.length == 1) {
                return _a[0] == _b[0];
            } else {
                return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
            }
        }
    }

    /// @dev exp calculate base^expo, and return the result as a quadruple precision floating point number.
    function exp(bytes16 base, uint expo) public pure returns (bytes16) {
        bytes16 res;
        for (uint i = 0; i < expo; i++) {
            res = ABDKMathQuad.mul(res, base);
        }
        return res;
    }
}