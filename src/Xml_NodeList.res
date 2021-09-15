open Webapi
open Belt

type t = Dom.NodeList.t

let asArrayLike: t => array<Xml_Node.t> = Dom.NodeList.toArray

let length: t => int = Dom.NodeList.length

let item = (nl, idx) => Dom.NodeList.item(idx, nl)

let itemUnsafe = (nl, idx) => item(nl, idx)->Option.getExn
