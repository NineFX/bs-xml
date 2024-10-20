open Webapi

type decoder<'a> = Xml_Element.t => 'a

exception DecodeError(string)

// Element properties with different names

let text = Dom.Element.textContent

let namespace = Dom.Element.namespaceURI

let name = Dom.Element.localName

let ok = (value: 'a, _: Xml_Element.t) => value

let error: 'a = (msg: string, _: Xml_Element.t) => raise(DecodeError(msg))

let requireSome = opt =>
  switch opt {
  | Some(value) => value
  | None => raise(DecodeError("some expected, got none"))
  }

let attribute = (~namespace: option<string>=?, name: string, element: Xml_Element.t) => {
  open Xml_Element
  open Xml_Attribute
  open Xml_NamedNodeMap

  let attrs = element->attributes

  switch namespace {
  | Some(namespace) =>
    switch attrs->getNamedItemNS(namespace, name) {
    | Some(attr) => attr->value
    | None => raise(DecodeError(name ++ " attribute expected"))
    }
  | None =>
    switch attrs->getNamedItem(name) {
    | Some(attr) => attr->value
    | None => raise(DecodeError(name ++ " attribute expected"))
    }
  }
}

let requireName = (element: Xml_Element.t, name: string) => {
  open Xml_Element

  if element->localName != name {
    raise(DecodeError(name ++ (" element expected, got " ++ element->localName)))
  }
  element
}

let withName = (name: string, decoder: decoder<'a>, element: Xml_Element.t) => {
  let _: Xml_Element.t = requireName(element, name)
  decoder(element)
}

let requireNamespace = (element: Xml_Element.t, namespace: option<string>) => {
  open Xml_Element

  if element->namespaceURI != namespace {
    raise(
      DecodeError(
        "namespace '" ++
        (namespace->Option.getOr("") ++
        ("' expected, got '" ++ (element->namespaceURI->Option.getOr("") ++ "'"))),
      ),
    )
  }
  element
}

let withNamespace = (namespace: option<string>, decoder: decoder<'a>, element: Xml_Element.t) => {
  let _: Xml_Element.t = requireNamespace(element, namespace)
  decoder(element)
}

let optional = (decoder: decoder<'a>, element) =>
  try Some(decoder(element)) catch {
  | DecodeError(_) => None
  }

let child = (selector: Xml_Element.t => bool, decoder: decoder<'a>, element) => {
  open Xml_Element
  open Xml_NodeList

  let nodes = element->childNodes

  let found = ref(None)
  let i = ref(0)
  while found.contents->Option.isNone && i.contents < nodes->length {
    let node = nodes->itemUnsafe(i.contents)

    switch node->Xml_Node.asElement {
    | Some(e) =>
      if selector(e) {
        found := Some(decoder(e))
      }
    | None => ()
    }

    i := i.contents + 1
  }

  switch found.contents {
  | Some(found) => found
  | None => raise(DecodeError("child not found"))
  }
}

let selectAny = _ => true

let select = (~namespace as targetNamespace=?, targetName, element) =>
  if targetName == element->name {
    switch targetNamespace {
    | Some(targetNamespace) => targetNamespace == element->namespace
    | None => true
    }
  } else {
    false
  }

let children = (selector: Xml_Element.t => bool, decoder: decoder<'a>, element: Xml_Element.t) => {
  Xml_Element.childNodes(element)
  ->Xml_NodeList.asArrayLike
  ->Array.filterMap(Xml_Node.asElement)
  ->Array.filter(selector)
  ->Array.map(decoder(_))
}

let map = (decoder: decoder<'a>, f: 'a => 'b, elem) => decoder(elem)->f

let mapOptional = (decoder: decoder<option<'a>>, f: 'a => 'b, elem) =>
  decoder(elem)->Option.map(f)

let andThen = (decoder: decoder<'a>, f: 'a => decoder<'b>, elem) =>
  decoder(elem)->f

let either = (left: decoder<'a>, right: decoder<'a>, elem: Xml_Element.t) =>
  try left(elem) catch {
  | DecodeError(_) => right(elem)
  }

let withDefault = (decoder: decoder<'a>, default, elem: Xml_Element.t) =>
  try decoder(elem) catch {
  | DecodeError(_) => default
  }

let oneOf = (decoders: list<decoder<'a>>, elem: Xml_Element.t) => {
  let arr = decoders->List.toArray

  let result = ref(None)

  let i = ref(0)
  while result.contents->Option.isNone && i.contents < arr->Array.length {
    let d = arr->Array.getUnsafe(i.contents)
    let res = try Some(d(elem)) catch {
    | DecodeError(_) => None
    }
    i := i.contents + 1
    result := res
  }
  switch result.contents {
  | Some(result) => result
  | None => raise(DecodeError("no decoder succeeded"))
  }
}

let float = str => {
  let f = str->Float.fromString->Option.getUnsafe
  if f->Float.isFinite {
    f
  } else {
    raise(DecodeError("float expected"))
  }
}

let int = str =>
  try int_of_string(str) catch {
  | Failure(_) => raise(DecodeError("int expected"))
  }

let date = str => {
  let d = str->Date.fromString
  if d->Date.getTime->Float.isNaN {
    raise(DecodeError("date expected"))
  } else {
    d
  }
}

let bool = str =>
  try str->bool_of_string catch {
  | Invalid_argument(_) => raise(DecodeError("bool expected"))
  }

let childElements = elem =>
  elem->Xml_Element.childNodes->Xml_NodeList.asArrayLike->Array.filterMap(Xml_Node.asElement)
