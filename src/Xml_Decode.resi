type decoder<'a> = Xml_Element.t => 'a

exception DecodeError(string)

// text, name and namespace also fit decoder('a) signature

let text: (. Xml_Element.t) => string

let namespace: (. Xml_Element.t) => option<string>

let name: (. Xml_Element.t) => string

let ok: 'a => decoder<'a>
let error: string => decoder<'a>

// require* functions throws DecodeError, can be used in custom decoders

let requireSome: option<'a> => 'a
let requireName: (Xml_Element.t, string) => Xml_Element.t
let requireNamespace: (Xml_Element.t, option<string>) => Xml_Element.t

let attribute: (~namespace: string=?, string) => decoder<string>

let withName: (string, decoder<'a>) => decoder<'a>
let withNamespace: (option<string>, decoder<'a>) => decoder<'a>
let optional: decoder<'a> => decoder<option<'a>>

// select* functions are used in 'child' and 'children' decoders

let selectAny: Xml_Element.t => bool
let select: (~namespace: option<string>=?, string, Xml_Element.t) => bool

let child: (Xml_Element.t => bool, decoder<'a>) => decoder<'a>
let children: (Xml_Element.t => bool, decoder<'a>) => decoder<array<'a>>
let map: (decoder<'a>, 'a => 'b) => decoder<'b>
let mapOptional: (decoder<option<'a>>, 'a => 'b) => decoder<option<'b>>
let andThen: (decoder<'a>, 'a => decoder<'b>) => decoder<'b>
let either: (decoder<'a>, decoder<'a>) => decoder<'a>
let withDefault: (Xml_Element.t => 'a, 'a) => decoder<'a>
let oneOf: list<decoder<'a>> => decoder<'a>

let float: string => float
let int: string => int
let date: string => Js.Date.t
let bool: string => bool

let childElements: decoder<array<Xml_Element.t>>
