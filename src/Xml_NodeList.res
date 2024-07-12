open Webapi
open Belt

type t = Dom.NodeList.t

let asArrayLike: (. t) => array<Xml_Node.t> = Dom.NodeList.toArray

let length: (. t) => int = Dom.NodeList.length

let item = (nl: t, idx: int) => Dom.NodeList.item(nl, idx)

let itemUnsafe = (nl: t , idx: int) => item(nl, idx)->Option.getExn
