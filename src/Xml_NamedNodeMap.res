open Webapi

type t = Dom.NamedNodeMap.t

let getNamedItem = (map: t, name) => Dom.NamedNodeMap.getNamedItem(map, name)

let getNamedItemNS = (map: t, namespace, localName) =>
  Dom.NamedNodeMap.getNamedItemNS(map, namespace, localName)
