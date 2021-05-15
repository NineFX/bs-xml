open Webapi

module NodeLike = (
  M: {
    type t
  },
) => Dom.Node.Impl(M)

module ElementLike = (
  M: {
    type t
  },
) => Dom.Element.Impl(M)
