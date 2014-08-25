MHTextView
==========

This is a text view that solves a few tasks that cannot be solved using `UILabel` or `UITextView`.
It is not a complete `UITextView` replacement and doesn't support editing or text selection, for
example.

Main features:

* *Optional custom justify.* The default justification implementation "stretches" words early on,
  it increases the letter-spacing. By contrast, the custom justification in `MHTextView` only
  increases the whitespace and leaves the letter-spacing untouched, unless there is only one word
  on a line.

* *Ellipsis on last line.* Optionally adds an ellipsis at the end of the text if it doesn't fit and
  overflows.

* *Custom layouts.* The default layout, `MHDefaultTextViewLayout`, already provides support for
  multiple columns. If you need more fancy layouts you can implement your own. The demo project
  provides examples.

* *Exclusion paths.* You can provide arbitrary `UIBezierPath`s into which the text view is not
  allowed to render (to "cut" holes into your text).

* *Exclusion views.* Similar to exclusion paths, the text view can track other views and use their
  frames as exclusion paths so you don't have to provide the corresponding paths yourself.

* *Top-to-bottom text distribution for multi-column layouts.* Usually, text is distributed by
  completely filling the first column, then proceeding to the next until the text runs out. With
  this setting the text is distributed over the columns in such a way that they all have the same
  height, if possible.

The provided demo project let's you play with all of these settings.


Known issues and limitations
============================

* The ellipsis sometimes removes the last one or two characters of the last word.
* AutoLayout intrinsic content height is only supported for single-column setup when using
  `MHDefaultTextViewLayout`.


License
=======

BSD-style. See [LICENSE file](LICENSE).

