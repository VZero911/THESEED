// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

/// @author philogy <https://github.com/philogy>
/// @dev Code generated automatically by script.
library safeconsole {
    uint256 constant CONSOLE_ADDR = 0x000000000000000000000000000000000000000000636F6e736F6c652e6c6f67;

    // Credit to [0age](https://twitter.com/z0age/status/1654922202930888704) and [0xdapper](https://github.com/foundry-rs/forge-std/pull/374)
    // for the view-to-pure log trick.
    function _sendLogPayload(uint256 offset, uint256 size) private pure {
        function(uint256, uint256) internal view fnIn = _sendLogPayloadView;
        function(uint256, uint256) internal pure pureSendLogPayload;
        assembly ("memory-safe") {
            pureSendLogPayload := fnIn
        }
        pureSendLogPayload(offset, size);
    }

    function _sendLogPayloadView(uint256 offset, uint256 size) private view {
        assembly ("memory-safe") {
            pop(staticcall(gas(), CONSOLE_ADDR, offset, size, 0x0, 0x0))
        }
    }

    function _memcopy(uint256 fromOffset, uint256 toOffset, uint256 length) private pure {
        function(uint256, uint256, uint256) internal view fnIn = _memcopyView;
        function(uint256, uint256, uint256) internal pure pureMemcopy;
        assembly ("memory-safe") {
            pureMemcopy := fnIn
        }
        pureMemcopy(fromOffset, toOffset, length);
    }

    function _memcopyView(uint256 fromOffset, uint256 toOffset, uint256 length) private view {
        assembly ("memory-safe") {
            pop(staticcall(gas(), 0x4, fromOffset, length, toOffset, length))
        }
    }

    function logMemory(uint256 offset, uint256 length) internal pure {
        if (offset >= 0x60) {
            // Sufficient memory before slice to prepare call header.
            bytes32 m0;
            bytes32 m1;
            bytes32 m2;
            assembly ("memory-safe") {
                m0 := mload(sub(offset, 0x60))
                m1 := mload(sub(offset, 0x40))
                m2 := mload(sub(offset, 0x20))
                // Selector of `log(bytes)`.
                mstore(sub(offset, 0x60), 0x0be77f56)
                mstore(sub(offset, 0x40), 0x20)
                mstore(sub(offset, 0x20), length)
            }
            _sendLogPayload(offset - 0x44, length + 0x44);
            assembly ("memory-safe") {
                mstore(sub(offset, 0x60), m0)
                mstore(sub(offset, 0x40), m1)
                mstore(sub(offset, 0x20), m2)
            }
        } else {
            // Insufficient space, so copy slice forward, add header and reverse.
            bytes32 m0;
            bytes32 m1;
            bytes32 m2;
            uint256 endOffset = offset + length;
            assembly ("memory-safe") {
                m0 := mload(add(endOffset, 0x00))
                m1 := mload(add(endOffset, 0x20))
                m2 := mload(add(endOffset, 0x40))
            }
            _memcopy(offset, offset + 0x60, length);
            assembly ("memory-safe") {
                // Selector of `log(bytes)`.
                mstore(add(offset, 0x00), 0x0be77f56)
                mstore(add(offset, 0x20), 0x20)
                mstore(add(offset, 0x40), length)
            }
            _sendLogPayload(offset + 0x1c, length + 0x44);
            _memcopy(offset + 0x60, offset, length);
            assembly ("memory-safe") {
                mstore(add(endOffset, 0x00), m0)
                mstore(add(endOffset, 0x20), m1)
                mstore(add(endOffset, 0x40), m2)
            }
        }
    }

    function log(address p0) internal pure {
        bytes32 m0;
        bytes32 m1;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            // Selector of `log(address)`.
            mstore(0x00, 0x2c2ecbc2)
            mstore(0x20, p0)
        }
        _sendLogPayload(0x1c, 0x24);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
        }
    }

    function log(bool p0) internal pure {
        bytes32 m0;
        bytes32 m1;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            // Selector of `log(bool)`.
            mstore(0x00, 0x32458eed)
            mstore(0x20, p0)
        }
        _sendLogPayload(0x1c, 0x24);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
        }
    }

    function log(uint256 p0) internal pure {
        bytes32 m0;
        bytes32 m1;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            // Selector of `log(uint256)`.
            mstore(0x00, 0xf82c50f1)
            mstore(0x20, p0)
        }
        _sendLogPayload(0x1c, 0x24);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
        }
    }

    function log(bytes32 p0) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(string)`.
            mstore(0x00, 0x41304fac)
            mstore(0x20, 0x20)
            writeString(0x40, p0)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, address p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(address,address)`.
            mstore(0x00, 0xdaf0d4aa)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(address p0, bool p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(address,bool)`.
            mstore(0x00, 0x75b605d3)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(address p0, uint256 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(address,uint256)`.
            mstore(0x00, 0x8309e8a8)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(address p0, bytes32 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,string)`.
            mstore(0x00, 0x759f86bb)
            mstore(0x20, p0)
            mstore(0x40, 0x40)
            writeString(0x60, p1)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(bool,address)`.
            mstore(0x00, 0x853c4849)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(bool p0, bool p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(bool,bool)`.
            mstore(0x00, 0x2a110e83)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(bool p0, uint256 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(bool,uint256)`.
            mstore(0x00, 0x399174d3)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(bool p0, bytes32 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,string)`.
            mstore(0x00, 0x8feac525)
            mstore(0x20, p0)
            mstore(0x40, 0x40)
            writeString(0x60, p1)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(uint256 p0, address p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(uint256,address)`.
            mstore(0x00, 0x69276c86)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(uint256 p0, bool p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(uint256,bool)`.
            mstore(0x00, 0x1c9d7eb3)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(uint256 p0, uint256 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            // Selector of `log(uint256,uint256)`.
            mstore(0x00, 0xf666715a)
            mstore(0x20, p0)
            mstore(0x40, p1)
        }
        _sendLogPayload(0x1c, 0x44);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
        }
    }

    function log(uint256 p0, bytes32 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(uint256,string)`.
            mstore(0x00, 0x643fd0df)
            mstore(0x20, p0)
            mstore(0x40, 0x40)
            writeString(0x60, p1)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bytes32 p0, address p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(string,address)`.
            mstore(0x00, 0x319af333)
            mstore(0x20, 0x40)
            mstore(0x40, p1)
            writeString(0x60, p0)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bytes32 p0, bool p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(string,bool)`.
            mstore(0x00, 0xc3b55635)
            mstore(0x20, 0x40)
            mstore(0x40, p1)
            writeString(0x60, p0)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bytes32 p0, uint256 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(string,uint256)`.
            mstore(0x00, 0xb60e72cc)
            mstore(0x20, 0x40)
            mstore(0x40, p1)
            writeString(0x60, p0)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bytes32 p0, bytes32 p1) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(string,string)`.
            mstore(0x00, 0x4b5c4277)
            mstore(0x20, 0x40)
            mstore(0x40, 0x80)
            writeString(0x60, p0)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,address,address)`.
            mstore(0x00, 0x018c84c2)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, address p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,address,bool)`.
            mstore(0x00, 0xf2a66286)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, address p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,address,uint256)`.
            mstore(0x00, 0x17fe6185)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, address p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(address,address,string)`.
            mstore(0x00, 0x007150be)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(address p0, bool p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,bool,address)`.
            mstore(0x00, 0xf11699ed)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, bool p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,bool,bool)`.
            mstore(0x00, 0xeb830c92)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, bool p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,bool,uint256)`.
            mstore(0x00, 0x9c4f99fb)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, bool p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(address,bool,string)`.
            mstore(0x00, 0x212255cc)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(address p0, uint256 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,uint256,address)`.
            mstore(0x00, 0x7bc0d848)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, uint256 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,uint256,bool)`.
            mstore(0x00, 0x678209a8)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, uint256 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(address,uint256,uint256)`.
            mstore(0x00, 0xb69bcaf6)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(address p0, uint256 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(address,uint256,string)`.
            mstore(0x00, 0xa1f2e8aa)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(address p0, bytes32 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(address,string,address)`.
            mstore(0x00, 0xf08744e8)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(address p0, bytes32 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(address,string,bool)`.
            mstore(0x00, 0xcf020fb1)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(address p0, bytes32 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(address,string,uint256)`.
            mstore(0x00, 0x67dd6ff1)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(address p0, bytes32 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(address,string,string)`.
            mstore(0x00, 0xfb772265)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, 0xa0)
            writeString(0x80, p1)
            writeString(0xc0, p2)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bool p0, address p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,address,address)`.
            mstore(0x00, 0xd2763667)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, address p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,address,bool)`.
            mstore(0x00, 0x18c9c746)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, address p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,address,uint256)`.
            mstore(0x00, 0x5f7b9afb)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, address p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(bool,address,string)`.
            mstore(0x00, 0xde9a9270)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bool p0, bool p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,bool,address)`.
            mstore(0x00, 0x1078f68d)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, bool p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,bool,bool)`.
            mstore(0x00, 0x50709698)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, bool p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,bool,uint256)`.
            mstore(0x00, 0x12f21602)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, bool p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(bool,bool,string)`.
            mstore(0x00, 0x2555fa46)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bool p0, uint256 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,uint256,address)`.
            mstore(0x00, 0x088ef9d2)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, uint256 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,uint256,bool)`.
            mstore(0x00, 0xe8defba9)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, uint256 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(bool,uint256,uint256)`.
            mstore(0x00, 0x37103367)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(bool p0, uint256 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(bool,uint256,string)`.
            mstore(0x00, 0xc3fc3970)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bool p0, bytes32 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(bool,string,address)`.
            mstore(0x00, 0x9591b953)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bool p0, bytes32 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(bool,string,bool)`.
            mstore(0x00, 0xdbb4c247)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bool p0, bytes32 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(bool,string,uint256)`.
            mstore(0x00, 0x1093ee11)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bool p0, bytes32 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(bool,string,string)`.
            mstore(0x00, 0xb076847f)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, 0xa0)
            writeString(0x80, p1)
            writeString(0xc0, p2)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(uint256 p0, address p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,address,address)`.
            mstore(0x00, 0xbcfd9be0)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, address p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,address,bool)`.
            mstore(0x00, 0x9b6ec042)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, address p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,address,uint256)`.
            mstore(0x00, 0x5a9b5ed5)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, address p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(uint256,address,string)`.
            mstore(0x00, 0x63cb41f9)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(uint256 p0, bool p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,bool,address)`.
            mstore(0x00, 0x35085f7b)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, bool p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,bool,bool)`.
            mstore(0x00, 0x20718650)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, bool p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,bool,uint256)`.
            mstore(0x00, 0x20098014)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, bool p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(uint256,bool,string)`.
            mstore(0x00, 0x85775021)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(uint256 p0, uint256 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,uint256,address)`.
            mstore(0x00, 0x5c96b331)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, uint256 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,uint256,bool)`.
            mstore(0x00, 0x4766da72)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, uint256 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            // Selector of `log(uint256,uint256,uint256)`.
            mstore(0x00, 0xd1ed7a3c)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
        }
        _sendLogPayload(0x1c, 0x64);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
        }
    }

    function log(uint256 p0, uint256 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(uint256,uint256,string)`.
            mstore(0x00, 0x71d04af2)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x60)
            writeString(0x80, p2)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(uint256 p0, bytes32 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(uint256,string,address)`.
            mstore(0x00, 0x7afac959)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(uint256 p0, bytes32 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(uint256,string,bool)`.
            mstore(0x00, 0x4ceda75a)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(uint256 p0, bytes32 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(uint256,string,uint256)`.
            mstore(0x00, 0x37aa7d4c)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, p2)
            writeString(0x80, p1)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(uint256 p0, bytes32 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(uint256,string,string)`.
            mstore(0x00, 0xb115611f)
            mstore(0x20, p0)
            mstore(0x40, 0x60)
            mstore(0x60, 0xa0)
            writeString(0x80, p1)
            writeString(0xc0, p2)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, address p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,address,address)`.
            mstore(0x00, 0xfcec75e0)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, address p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,address,bool)`.
            mstore(0x00, 0xc91d5ed4)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, address p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,address,uint256)`.
            mstore(0x00, 0x0d26b925)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, address p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(string,address,string)`.
            mstore(0x00, 0xe0e9ad4f)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, 0xa0)
            writeString(0x80, p0)
            writeString(0xc0, p2)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, bool p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,bool,address)`.
            mstore(0x00, 0x932bbb38)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, bool p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,bool,bool)`.
            mstore(0x00, 0x850b7ad6)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, bool p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,bool,uint256)`.
            mstore(0x00, 0xc95958d6)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, bool p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(string,bool,string)`.
            mstore(0x00, 0xe298f47d)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, 0xa0)
            writeString(0x80, p0)
            writeString(0xc0, p2)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, uint256 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,uint256,address)`.
            mstore(0x00, 0x1c7ec448)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, uint256 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,uint256,bool)`.
            mstore(0x00, 0xca7733b1)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, uint256 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            // Selector of `log(string,uint256,uint256)`.
            mstore(0x00, 0xca47c4eb)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, p2)
            writeString(0x80, p0)
        }
        _sendLogPayload(0x1c, 0xa4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
        }
    }

    function log(bytes32 p0, uint256 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(string,uint256,string)`.
            mstore(0x00, 0x5970e089)
            mstore(0x20, 0x60)
            mstore(0x40, p1)
            mstore(0x60, 0xa0)
            writeString(0x80, p0)
            writeString(0xc0, p2)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, bytes32 p1, address p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(string,string,address)`.
            mstore(0x00, 0x95ed0195)
            mstore(0x20, 0x60)
            mstore(0x40, 0xa0)
            mstore(0x60, p2)
            writeString(0x80, p0)
            writeString(0xc0, p1)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, bytes32 p1, bool p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(string,string,bool)`.
            mstore(0x00, 0xb0e0f9b5)
            mstore(0x20, 0x60)
            mstore(0x40, 0xa0)
            mstore(0x60, p2)
            writeString(0x80, p0)
            writeString(0xc0, p1)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, bytes32 p1, uint256 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            // Selector of `log(string,string,uint256)`.
            mstore(0x00, 0x5821efa1)
            mstore(0x20, 0x60)
            mstore(0x40, 0xa0)
            mstore(0x60, p2)
            writeString(0x80, p0)
            writeString(0xc0, p1)
        }
        _sendLogPayload(0x1c, 0xe4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
        }
    }

    function log(bytes32 p0, bytes32 p1, bytes32 p2) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        bytes32 m9;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            m9 := mload(0x120)
            // Selector of `log(string,string,string)`.
            mstore(0x00, 0x2ced7cef)
            mstore(0x20, 0x60)
            mstore(0x40, 0xa0)
            mstore(0x60, 0xe0)
            writeString(0x80, p0)
            writeString(0xc0, p1)
            writeString(0x100, p2)
        }
        _sendLogPayload(0x1c, 0x124);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
            mstore(0x120, m9)
        }
    }

    function log(address p0, address p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,address,address)`.
            mstore(0x00, 0x665bf134)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,address,bool)`.
            mstore(0x00, 0x0e378994)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,address,uint256)`.
            mstore(0x00, 0x94250d77)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,address,address,string)`.
            mstore(0x00, 0xf808da20)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,bool,address)`.
            mstore(0x00, 0x9f1bc36e)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,bool,bool)`.
            mstore(0x00, 0x2cd4134a)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,bool,uint256)`.
            mstore(0x00, 0x3971e78c)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,address,bool,string)`.
            mstore(0x00, 0xaa6540c8)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,uint256,address)`.
            mstore(0x00, 0x8da6def5)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,uint256,bool)`.
            mstore(0x00, 0x9b4254e2)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, uint256 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,address,uint256,uint256)`.
            mstore(0x00, 0xbe553481)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, address p1, uint256 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,address,uint256,string)`.
            mstore(0x00, 0xfdb4f990)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, bytes32 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,address,string,address)`.
            mstore(0x00, 0x8f736d16)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, bytes32 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,address,string,bool)`.
            mstore(0x00, 0x6f1a594e)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, bytes32 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,address,string,uint256)`.
            mstore(0x00, 0xef1cefe7)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, address p1, bytes32 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,address,string,string)`.
            mstore(0x00, 0x21bdaf25)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, 0xc0)
            writeString(0xa0, p2)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bool p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,address,address)`.
            mstore(0x00, 0x660375dd)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,address,bool)`.
            mstore(0x00, 0xa6f50b0f)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,address,uint256)`.
            mstore(0x00, 0xa75c59de)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,bool,address,string)`.
            mstore(0x00, 0x2dd778e6)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bool p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,bool,address)`.
            mstore(0x00, 0xcf394485)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,bool,bool)`.
            mstore(0x00, 0xcac43479)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,bool,uint256)`.
            mstore(0x00, 0x8c4e5de6)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,bool,bool,string)`.
            mstore(0x00, 0xdfc4a2e8)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bool p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,uint256,address)`.
            mstore(0x00, 0xccf790a1)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,uint256,bool)`.
            mstore(0x00, 0xc4643e20)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, uint256 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,bool,uint256,uint256)`.
            mstore(0x00, 0x386ff5f4)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, bool p1, uint256 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,bool,uint256,string)`.
            mstore(0x00, 0x0aa6cfad)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bool p1, bytes32 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,bool,string,address)`.
            mstore(0x00, 0x19fd4956)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bool p1, bytes32 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,bool,string,bool)`.
            mstore(0x00, 0x50ad461d)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bool p1, bytes32 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,bool,string,uint256)`.
            mstore(0x00, 0x80e6a20b)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bool p1, bytes32 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,bool,string,string)`.
            mstore(0x00, 0x475c5c33)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, 0xc0)
            writeString(0xa0, p2)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, uint256 p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,address,address)`.
            mstore(0x00, 0x478d1c62)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,address,bool)`.
            mstore(0x00, 0xa1bcc9b3)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,address,uint256)`.
            mstore(0x00, 0x100f650e)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,uint256,address,string)`.
            mstore(0x00, 0x1da986ea)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, uint256 p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,bool,address)`.
            mstore(0x00, 0xa31bfdcc)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,bool,bool)`.
            mstore(0x00, 0x3bf5e537)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,bool,uint256)`.
            mstore(0x00, 0x22f6b999)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,uint256,bool,string)`.
            mstore(0x00, 0xc5ad85f9)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, uint256 p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,uint256,address)`.
            mstore(0x00, 0x20e3984d)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,uint256,bool)`.
            mstore(0x00, 0x66f1bc67)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(address,uint256,uint256,uint256)`.
            mstore(0x00, 0x34f0e636)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(address p0, uint256 p1, uint256 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,uint256,uint256,string)`.
            mstore(0x00, 0x4a28c017)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, uint256 p1, bytes32 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,uint256,string,address)`.
            mstore(0x00, 0x5c430d47)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, uint256 p1, bytes32 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,uint256,string,bool)`.
            mstore(0x00, 0xcf18105c)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, uint256 p1, bytes32 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,uint256,string,uint256)`.
            mstore(0x00, 0xbf01f891)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, uint256 p1, bytes32 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,uint256,string,string)`.
            mstore(0x00, 0x88a8c406)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, 0xc0)
            writeString(0xa0, p2)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,address,address)`.
            mstore(0x00, 0x0d36fa20)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,address,bool)`.
            mstore(0x00, 0x0df12b76)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,address,uint256)`.
            mstore(0x00, 0x457fe3cf)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,string,address,string)`.
            mstore(0x00, 0xf7e36245)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, 0xc0)
            writeString(0xa0, p1)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,bool,address)`.
            mstore(0x00, 0x205871c2)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,bool,bool)`.
            mstore(0x00, 0x5f1d5c9f)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,bool,uint256)`.
            mstore(0x00, 0x515e38b6)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,string,bool,string)`.
            mstore(0x00, 0xbc0b61fe)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, 0xc0)
            writeString(0xa0, p1)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,uint256,address)`.
            mstore(0x00, 0x63183678)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,uint256,bool)`.
            mstore(0x00, 0x0ef7e050)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, uint256 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(address,string,uint256,uint256)`.
            mstore(0x00, 0x1dc8e1b8)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, p3)
            writeString(0xa0, p1)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(address p0, bytes32 p1, uint256 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,string,uint256,string)`.
            mstore(0x00, 0x448830a8)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, p2)
            mstore(0x80, 0xc0)
            writeString(0xa0, p1)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, bytes32 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,string,string,address)`.
            mstore(0x00, 0xa04e2f87)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, 0xc0)
            mstore(0x80, p3)
            writeString(0xa0, p1)
            writeString(0xe0, p2)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, bytes32 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,string,string,bool)`.
            mstore(0x00, 0x35a5071f)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, 0xc0)
            mstore(0x80, p3)
            writeString(0xa0, p1)
            writeString(0xe0, p2)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, bytes32 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(address,string,string,uint256)`.
            mstore(0x00, 0x159f8927)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, 0xc0)
            mstore(0x80, p3)
            writeString(0xa0, p1)
            writeString(0xe0, p2)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(address p0, bytes32 p1, bytes32 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        bytes32 m9;
        bytes32 m10;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            m9 := mload(0x120)
            m10 := mload(0x140)
            // Selector of `log(address,string,string,string)`.
            mstore(0x00, 0x5d02c50b)
            mstore(0x20, p0)
            mstore(0x40, 0x80)
            mstore(0x60, 0xc0)
            mstore(0x80, 0x100)
            writeString(0xa0, p1)
            writeString(0xe0, p2)
            writeString(0x120, p3)
        }
        _sendLogPayload(0x1c, 0x144);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
            mstore(0x120, m9)
            mstore(0x140, m10)
        }
    }

    function log(bool p0, address p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,address,address)`.
            mstore(0x00, 0x1d14d001)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,address,bool)`.
            mstore(0x00, 0x46600be0)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,address,uint256)`.
            mstore(0x00, 0x0c66d1be)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,address,address,string)`.
            mstore(0x00, 0xd812a167)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, address p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,bool,address)`.
            mstore(0x00, 0x1c41a336)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,bool,bool)`.
            mstore(0x00, 0x6a9c478b)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,bool,uint256)`.
            mstore(0x00, 0x07831502)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,address,bool,string)`.
            mstore(0x00, 0x4a66cb34)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, address p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,uint256,address)`.
            mstore(0x00, 0x136b05dd)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,uint256,bool)`.
            mstore(0x00, 0xd6019f1c)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, uint256 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,address,uint256,uint256)`.
            mstore(0x00, 0x7bf181a1)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, address p1, uint256 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,address,uint256,string)`.
            mstore(0x00, 0x51f09ff8)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, address p1, bytes32 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,address,string,address)`.
            mstore(0x00, 0x6f7c603e)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, address p1, bytes32 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,address,string,bool)`.
            mstore(0x00, 0xe2bfd60b)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, address p1, bytes32 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,address,string,uint256)`.
            mstore(0x00, 0xc21f64c7)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, address p1, bytes32 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(bool,address,string,string)`.
            mstore(0x00, 0xa73c1db6)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, 0xc0)
            writeString(0xa0, p2)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(bool p0, bool p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,address,address)`.
            mstore(0x00, 0xf4880ea4)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,address,bool)`.
            mstore(0x00, 0xc0a302d8)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,address,uint256)`.
            mstore(0x00, 0x4c123d57)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,bool,address,string)`.
            mstore(0x00, 0xa0a47963)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, bool p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,bool,address)`.
            mstore(0x00, 0x8c329b1a)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,bool,bool)`.
            mstore(0x00, 0x3b2a5ce0)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,bool,uint256)`.
            mstore(0x00, 0x6d7045c1)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,bool,bool,string)`.
            mstore(0x00, 0x2ae408d4)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, bool p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,uint256,address)`.
            mstore(0x00, 0x54a7a9a0)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,uint256,bool)`.
            mstore(0x00, 0x619e4d0e)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, uint256 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,bool,uint256,uint256)`.
            mstore(0x00, 0x0bb00eab)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, bool p1, uint256 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,bool,uint256,string)`.
            mstore(0x00, 0x7dd4d0e0)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, bool p1, bytes32 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,bool,string,address)`.
            mstore(0x00, 0xf9ad2b89)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, bool p1, bytes32 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,bool,string,bool)`.
            mstore(0x00, 0xb857163a)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, bool p1, bytes32 p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,bool,string,uint256)`.
            mstore(0x00, 0xe3a9ca2f)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, p3)
            writeString(0xa0, p2)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, bool p1, bytes32 p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        bytes32 m7;
        bytes32 m8;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            m7 := mload(0xe0)
            m8 := mload(0x100)
            // Selector of `log(bool,bool,string,string)`.
            mstore(0x00, 0x6d1e8751)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, 0x80)
            mstore(0x80, 0xc0)
            writeString(0xa0, p2)
            writeString(0xe0, p3)
        }
        _sendLogPayload(0x1c, 0x104);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
            mstore(0xe0, m7)
            mstore(0x100, m8)
        }
    }

    function log(bool p0, uint256 p1, address p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,address,address)`.
            mstore(0x00, 0x26f560a8)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, address p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,address,bool)`.
            mstore(0x00, 0xb4c314ff)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, address p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,address,uint256)`.
            mstore(0x00, 0x1537dc87)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, address p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,uint256,address,string)`.
            mstore(0x00, 0x1bb3b09a)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, uint256 p1, bool p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,bool,address)`.
            mstore(0x00, 0x9acd3616)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, bool p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,bool,bool)`.
            mstore(0x00, 0xceb5f4d7)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, bool p2, uint256 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,bool,uint256)`.
            mstore(0x00, 0x7f9bbca2)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, bool p2, bytes32 p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        bytes32 m5;
        bytes32 m6;
        assembly ("memory-safe") {
            function writeString(pos, w) {
                let length := 0
                for {} lt(length, 0x20) { length := add(length, 1) } { if iszero(byte(length, w)) { break } }
                mstore(pos, length)
                let shift := sub(256, shl(3, length))
                mstore(add(pos, 0x20), shl(shift, shr(shift, w)))
            }
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            m5 := mload(0xa0)
            m6 := mload(0xc0)
            // Selector of `log(bool,uint256,bool,string)`.
            mstore(0x00, 0x9143dbb1)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, 0x80)
            writeString(0xa0, p3)
        }
        _sendLogPayload(0x1c, 0xc4);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
            mstore(0xa0, m5)
            mstore(0xc0, m6)
        }
    }

    function log(bool p0, uint256 p1, uint256 p2, address p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80)
            // Selector of `log(bool,uint256,uint256,address)`.
            mstore(0x00, 0x00dd87b9)
            mstore(0x20, p0)
            mstore(0x40, p1)
            mstore(0x60, p2)
            mstore(0x80, p3)
        }
        _sendLogPayload(0x1c, 0x84);
        assembly ("memory-safe") {
            mstore(0x00, m0)
            mstore(0x20, m1)
            mstore(0x40, m2)
            mstore(0x60, m3)
            mstore(0x80, m4)
        }
    }

    function log(bool p0, uint256 p1, uint256 p2, bool p3) internal pure {
        bytes32 m0;
        bytes32 m1;
        bytes32 m2;
        bytes32 m3;
        bytes32 m4;
        assembly ("memory-safe") {
            m0 := mload(0x00)
            m1 := mload(0x20)
            m2 := mload(0x40)
            m3 := mload(0x60)
            m4 := mload(0x80
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
 =_½sáªåœZa6¾t¿òFˆN8Èôi 0µ Z«‰