type t

@send
external parseFromString: (t, string, string) => Xml_Document.t = "parseFromString"

let parse: (t, string, string) => Belt.Result.t<Xml_Element.t, string>

let parseXml: (t, string) => Belt.Result.t<Xml_Element.t, string>

let parseHtml: (t, string) => Belt.Result.t<Xml_Element.t, string>

// constructor, avoid external
let make: unit => t
