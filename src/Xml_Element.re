open Xml__;

type t = Webapi.Dom.Element.t;

include NodeLike({
  type nonrec t = t;
});

include ElementLike({
  type nonrec t = t;
});

