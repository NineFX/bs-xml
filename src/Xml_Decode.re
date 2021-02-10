open Belt;
open Webapi;

type decoder('a) = Xml_Element.t => 'a;

exception DecodeError(string);

// Element properties with different names

let text = Dom.Element.textContent;

let namespace = Dom.Element.namespaceURI;

let name = Dom.Element.localName;

let ok = (value: 'a, _: Xml_Element.t) => value;

let error: 'a =
  (msg: string, _: Xml_Element.t) => {
    raise(DecodeError(msg));
  };

let requireSome = opt => {
  switch (opt) {
  | Some(value) => value
  | None => raise(DecodeError("some expected, got none"))
  };
};

let attribute =
    (
      name: string,
      ~namespace: option(string)=?,
      element: Xml_Element.t,
    ) => {
  open Xml_Element;
  open Xml_Attribute;
  open Xml_NamedNodeMap;

  let attrs = element->attributes;

  switch (namespace) {
  | Some(namespace) =>
    switch (attrs->getNamedItemNS(namespace, name)) {
    | Some(attr) => attr->value
    | None => raise(DecodeError(name ++ " attribute expected"))
    }
  | None =>
    switch (attrs->getNamedItem(name)) {
    | Some(attr) => attr->value
    | None => raise(DecodeError(name ++ " attribute expected"))
    }
  };
};

let requireName = (element: Xml_Element.t, name: string) => {
  open Xml_Element;

  if (element->localName != name) {
    raise(
      DecodeError(name ++ " element expected, got " ++ element->localName),
    );
  };
  element;
};

let withName = (name: string, decoder: decoder('a), element: Xml_Element.t) => {
  let _: Xml_Element.t = requireName(element, name);
  decoder(element);
};

let requireNamespace = (element: Xml_Element.t, namespace: option(string)) => {
  open Xml_Element;

  if (element->namespaceURI != namespace) {
    raise(
      DecodeError(
        "namespace '"
        ++ namespace->Belt.Option.getWithDefault("")
        ++ "' expected, got '"
        ++ element->namespaceURI->Belt.Option.getWithDefault("")
        ++ "'",
      ),
    );
  };
  element;
};

let withNamespace =
    (namespace: option(string), decoder: decoder('a), element: Xml_Element.t) => {
  let _: Xml_Element.t = requireNamespace(element, namespace);
  decoder(element);
};

let optional = (decoder: decoder('a), element) =>
  try (Some(decoder(element))) {
  | DecodeError(_) => None
  };

let child = (selector: Xml_Element.t => bool, decoder: decoder('a), element) => {
  open Xml_Element;
  open Xml_NodeList;

  let nodes = element->childNodes;

  let found = ref(None);
  let i = ref(0);
  while ((found^)->Option.isNone && i^ < nodes->length) {
    let node = nodes->itemUnsafe(i^);

    switch (node->Xml_Node.asElement) {
    | Some(e) =>
      if (selector(e)) {
        found := Some(decoder(e));
      }
    | None => ()
    };

    i := i^ + 1;
  };

  switch (found^) {
  | Some(found) => found
  | None => raise(DecodeError("child not found"))
  };
};

let selectAny = _ => true;

let select = (targetName, ~namespace as targetNamespace=?, element) =>
  if (targetName == element->name) {
    switch (targetNamespace) {
    | Some(targetNamespace) => targetNamespace == element->namespace
    | None => true
    };
  } else {
    false;
  };

let children =
    (
      selector: Xml_Element.t => bool,
      decoder: decoder('a),
      element: Xml_Element.t,
    ) => {
  open Xml_Element;
  open Xml_NodeList;
  let children = element->childNodes;
  let result: array('a) = [||];

  for (i in 0 to children->length - 1) {
    let node = children->itemUnsafe(i);

    switch (node->Xml_Node.asElement) {
    | Some(e) =>
      if (selector(e)) {
        result |> Js.Array.push(decoder(e)) |> ignore;
      }

    | None => ()
    };
  };

  result;
};

let map = (decoder: decoder('a), f: 'a => 'b, elem) => {
  decoder(elem)->f;
};

let mapOptional = (decoder: decoder(option('a)), f: 'a => 'b, elem) => {
  decoder(elem)->Belt.Option.map(f);
};

let andThen = (decoder: decoder('a), f: 'a => decoder('b), elem) => {
  let a = decoder(elem);
  f(a, elem);
};

let either = (left: decoder('a), right: decoder('a), elem: Xml_Element.t) =>
  try (left(elem)) {
  | DecodeError(_) => right(elem)
  };

let withDefault = (decoder, default, elem: Xml_Element.t) =>
  try (decoder(elem)) {
  | DecodeError(_) => default
  };

let oneOf = (decoders: list(decoder('a)), elem: Xml_Element.t) => {
  let arr = decoders->List.toArray;

  let result = ref(None);

  let i = ref(0);
  while ((result^)->Option.isNone && i^ < arr->Array.length) {
    let d = arr->Js.Array.unsafe_get(i^);
    let res =
      try (Some(d(elem))) {
      | DecodeError(_) => None
      };
    i := i^ + 1;
    result := res;
  };
  switch (result^) {
  | Some(result) => result
  | None => raise(DecodeError("no decoder succeeded"))
  };
};

let float = str => {
  let f = str->Js.Float.fromString;
  if (f->Js.Float.isFinite) {
    f;
  } else {
    raise(DecodeError("float expected"));
  };
};

let int = str =>
  try (int_of_string(str)) {
  | Failure(_) => raise(DecodeError("int expected"))
  };

let date = str => {
  let d = str->Js.Date.fromString;
  if (d->Js.Date.getTime->Js.Float.isNaN) {
    raise(DecodeError("date expected"));
  } else {
    d;
  };
};

let bool = str =>
  try (str->bool_of_string) {
  | Invalid_argument(_) =>
    raise(DecodeError("bool expected"))
  };

let childElements = elem => {
  elem
  ->Xml_Element.childNodes
  ->Xml_NodeList.asArrayLike
  ->Belt.Array.keepMap(Xml_Node.asElement);
};
