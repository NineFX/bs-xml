@val @module("./expect") external expectToEqual: ('a, 'a) => unit = "expectToEqual"
@val @module("./expect") external expectToEqualAny: ('a, 'b) => unit = "expectToEqual"
