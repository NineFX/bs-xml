open Webapi;

type t = Dom.NamedNodeMap.t;

let getNamedItem = (map: t, name) => 
  Dom.NamedNodeMap.getNamedItem(name, map);

let getNamedItemNS = (map: t, namespace, localName) => 
  Dom.NamedNodeMap.getNamedItemNS(namespace, localName, map);
