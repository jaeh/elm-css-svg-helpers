module Svg.CssHelpers exposing (withNamespace, Namespace, Helpers)

{-| Helper functions for using elm-css with elm-svg.

@docs withNamespace

@docs Helpers, Namespace
-}

import Css.Helpers exposing (toCssIdentifier, identifierToString)
import Svg exposing (Attribute, Svg)
import Svg.Attributes as Attr
import String


{-| Helpers for working on a given class/id
-}
type alias Helpers class id msg =
    { class : List class -> Attribute msg
    , classList : List ( class, Bool ) -> Attribute msg
    , id : id -> Attribute msg
    }


{-| namespaced helpers for working on a given class/id
-}
type alias Namespace name class id msg =
    { class : List class -> Attribute msg
    , classList : List ( class, Bool ) -> Attribute msg
    , id : id -> Attribute msg
    , name : name
    }


{-| Takes a namespace and returns helper functions for `id`, `class`, and
`classList` which work just like their equivalents in `elm-svg` except that
they accept union types and automatically incorporate the given namespace. Also
note that `class` accepts a `List` instead of a single element; this is so you
can specify multiple classes without having to call `classList` passing tuples
that all end in `True`.

    -- Put this before your view code to specify a namespace.
    { id, class, classList } = withNamespace "homepage"

    view =
        svg [ id Graphic, class [ Fancy ] ] [ text "Hello, World!" ]

    type HomepageIds = Hero | SomethingElse | AnotherId
    type HomepageClasses = Fancy | AnotherClass | SomeOtherClass

The above would generate this DOM element:

    <h1 id="Hero" class="homepage_Fancy">Hello, World!</h1>
-}
withNamespace : name -> Namespace name class id msg
withNamespace name =
    { class = namespacedClass name
    , classList = namespacedClassList name
    , id = toCssIdentifier >> Attr.id
    , name = name
    }


helpers : Helpers class id msg
helpers =
    { class = class
    , classList = classList
    , id = toCssIdentifier >> Attr.id
    }


namespacedClassList : name -> List ( class, Bool ) -> Attribute msg
namespacedClassList name list =
    list
        |> List.filter snd
        |> List.map fst
        |> namespacedClass name


classList : List ( class, Bool ) -> Attribute msg
classList list =
    list
        |> List.filter snd
        |> List.map fst
        |> class


namespacedClass : name -> List class -> Attribute msg
namespacedClass name list =
    list
        |> List.map (identifierToString name)
        |> String.join " "
        |> Attr.class


class : List class -> Attribute msg
class =
    namespacedClass ""

