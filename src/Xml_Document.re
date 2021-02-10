open Xml__;
open Webapi;

type t = Dom.Document.t;

include NodeLike({
  type nonrec t = t;
});

[@bs.send] [@bs.return nullable]
external querySelector: (t, string) => option(Xml_Element.t) = "querySelector";