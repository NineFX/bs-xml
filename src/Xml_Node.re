open Xml__;

type t = Dom.node;

let asElement = Webapi.Dom.Element.ofNode;

include NodeLike({
  type nonrec t = t;
});