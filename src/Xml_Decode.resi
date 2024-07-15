type decoder<'a> = Xml_Element.t => 'a

exception DecodeError(string)

// text, name and namespace also fit decoder('a) signature

let text: Xml_Element.t => string

let namespace: Xml_Element.t => option<string>

let name: Xml_Element.t => string

let ok: ('a, Xml_Element.t) => 'a
let error: (string, Xml_Element.t) => string

// require* functions throws DecodeError, can be used in custom decoders

let requireSome: option<'a> => 'a
let requireName: (Xml_Element.t, string) => Xml_Element.t
let requireNamespace: (Xml_Element.t, option<string>) => Xml_Element.t

let attribute: (~namespace: string=?, string, Xml_Element.t) => string

let withName: (string, decoder<'a>, Xml_Element.t) => 'a
let withNamespace: (option<string>, decoder<'a>, Xml_Element.t) => 'a
let optional: (decoder<'a>, Xml_Element.t) => option<'a>

// select* functions are used in 'child' and 'children' decoders

let selectAny: Xml_Element.t => bool
let select: (~namespace: option<string>=?, string, Xml_Element.t) => bool

let child: (Xml_Element.t => bool, decoder<'a>, Xml_Element.t) => 'a
let children: (Xml_Element.t => bool, decoder<'a>, Xml_Element.t) => array<'a>
let map: (decoder<'a>, 'a => 'b, Xml_Element.t) => 'b
let mapOptional: (decoder<option<'a>>, 'a => 'b, Xml_Element.t) => option<'b>
let andThen: (decoder<'a>, 'a => decoder<'b>, Xml_Element.t) => decoder<'b>
let either: (decoder<'a>, decoder<'a>, Xml_Element.t) => 'a
let withDefault: (decoder<'a>, 'a, Xml_Element.t) => 'a
let oneOf: (list<decoder<'a>>, Xml_Element.t) => 'a

let float: string => float
let int: string => int
let date: string => Js.Date.t
let bool: string => bool

let childElements: decoder<array<Xml_Element.t>>
