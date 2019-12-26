/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/style.dart';

/// DimensionMixin impls RenderConstrainedBox to support
/// - width
/// - height
/// - max-width
/// - max-height
/// - min-width
/// - min-height
mixin DimensionMixin on Node {
  RenderConstrainedBox renderConstrainedBox;
  RenderMargin renderMargin;
  RenderPadding renderPadding;
  Padding oldPadding;
  Padding oldMargin;
  SizeConstraints oldConstraints;

  double getDisplayPortedLength(input) {
    if (input == null) return null;
    if (input is num) {
      input = input.toString();
    }
    return Length(input as String).displayPortValue;
  }

  void updateConstraints(Style style, Map<String, Transition> transitionMap) {
    if (renderConstrainedBox != null && style != null) {
      Transition allTransition, widthTransition, heightTransition,
          minWidthTransition, maxWidthTransition, minHeightTransition,
          maxHeightTransition;
      if (transitionMap != null) {
        allTransition = transitionMap['all'];
        widthTransition = transitionMap['width'];
        heightTransition = transitionMap['height'];
        minWidthTransition = transitionMap['min-width'];
        maxWidthTransition = transitionMap['max-width'];
        minHeightTransition = transitionMap['min-height'];
        maxHeightTransition = transitionMap['max-height'];
      }

      SizeConstraints newConstraints = _getConstraints(style);

      if (allTransition != null || widthTransition != null ||
          heightTransition != null || minWidthTransition != null ||
          maxWidthTransition != null || minHeightTransition != null ||
          maxHeightTransition != null) {
        double diffWidth = (newConstraints.width ?? 0.0) - (oldConstraints.width ??
            0.0);
        double diffHeight = (newConstraints.height ??
            0.0) - (oldConstraints.height ?? 0.0);
        double diffMinWidth = (newConstraints.minWidth ??
            0.0) - (oldConstraints.minWidth ?? 0.0);
        double diffMaxWidth = (newConstraints.maxWidth ??
            0.0) - (oldConstraints.maxWidth ?? 0.0);
        double diffMinHeight = (newConstraints.minHeight ??
            0.0) - (oldConstraints.minHeight ?? 0.0);
        double diffMaxHeight = (newConstraints.maxHeight ??
            0.0) - (oldConstraints.maxHeight ?? 0.0);

        SizeConstraints progressConstraints = SizeConstraints(
            oldConstraints.width, oldConstraints.height,
            oldConstraints.minWidth, oldConstraints.maxWidth,
            oldConstraints.minHeight, oldConstraints.maxHeight);

        SizeConstraints baseConstraints = SizeConstraints(
            oldConstraints.width, oldConstraints.height,
            oldConstraints.minWidth, oldConstraints.maxWidth,
            oldConstraints.minHeight, oldConstraints.maxHeight);

        allTransition?.addProgressListener((progress) {
          if (widthTransition == null) {
            progressConstraints.width =
                diffWidth * progress + (baseConstraints.width ?? 0.0);
          }
          if (heightTransition == null) {
            progressConstraints.height =
                diffHeight * progress + (baseConstraints.height ?? 0.0);
          }
          if (minWidthTransition == null) {
            progressConstraints.minWidth =
                diffMinWidth * progress + (baseConstraints.minWidth ?? 0.0);
          }
          if (maxWidthTransition == null) {
            progressConstraints.maxWidth =
                diffMaxWidth * progress + (baseConstraints.maxWidth ?? double.infinity);
          }
          if (minHeightTransition == null) {
            progressConstraints.minHeight =
                diffMinHeight * progress + (baseConstraints.minHeight ?? 0.0);
          }
          if (maxHeightTransition == null) {
            progressConstraints.maxHeight =
                diffMaxHeight * progress + (baseConstraints.maxHeight ?? double.infinity);
          }
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        widthTransition?.addProgressListener((progress) {
          progressConstraints.width =
              diffWidth * progress + (baseConstraints.width ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        heightTransition?.addProgressListener((progress) {
          progressConstraints.height =
              diffHeight * progress + (baseConstraints.height ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        minHeightTransition?.addProgressListener((progress) {
          progressConstraints.minHeight =
              diffWidth * progress + (baseConstraints.minHeight ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        minWidthTransition?.addProgressListener((progress) {
          progressConstraints.minWidth =
              diffWidth * progress + (baseConstraints.minWidth ?? 0.0);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        maxHeightTransition?.addProgressListener((progress) {
          progressConstraints.maxHeight =
              diffWidth * progress + (baseConstraints.maxHeight ?? double.infinity);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
        maxWidthTransition?.addProgressListener((progress) {
          progressConstraints.maxWidth =
              diffWidth * progress + (baseConstraints.maxWidth ?? double.infinity);
          renderConstrainedBox.additionalConstraints =
              progressConstraints.toBoxConstraints();
        });
      } else {
        renderConstrainedBox.additionalConstraints =
            newConstraints.toBoxConstraints();
      }
      oldConstraints = newConstraints;
    }
  }

  RenderObject initRenderConstrainedBox(
      RenderObject renderObject, Style style) {
    if (style != null) {
      oldConstraints = _getConstraints(style);
      return renderConstrainedBox = RenderConstrainedBox(
        additionalConstraints: oldConstraints.toBoxConstraints(),
        child: renderObject,
      );
    } else {
      return renderObject;
    }
  }

  SizeConstraints _getConstraints(Style style) {
    if (style != null) {
      double width = getDisplayPortedLength(style['width']);
      double height = getDisplayPortedLength(style['height']);
      double minHeight = getDisplayPortedLength(style['minHeight']);
      double maxWidth = getDisplayPortedLength(style['maxWidth']);
      double maxHeight = getDisplayPortedLength(style['maxHeight']);
      double minWidth = getDisplayPortedLength(style['minWidth']);

      return SizeConstraints(
          width, height, minWidth, maxWidth, minHeight, maxHeight);
    } else {
      return null;
    }
  }

  static RegExp spaceRegExp = RegExp(r" ");

  List<String> getShorttedProperties(String input) {
    assert(input != null);
    return input.trim().split(spaceRegExp);
  }

  RenderObject initRenderMargin(RenderObject renderObject, Style style) {
    EdgeInsets edgeInsets = getMarginInsetsFromStyle(style);
    return renderMargin = RenderMargin(
      margin: edgeInsets,
      child: renderObject,
    );
  }

  Padding getMarginFromStyle(Style style) {
    double left = 0.0;
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;

    if (style != null) {
      String margin = style['margin'];
      double marginLeft;
      double marginTop;
      double marginRight;
      double marginBottom;
      if (margin != null) {
        List<String> splitedMargin = getShorttedProperties(margin);
        if (splitedMargin.length == 1) {
          marginLeft = marginRight = marginTop =
              marginBottom = getDisplayPortedLength(splitedMargin[0]);
        } else if (splitedMargin.length == 2) {
          marginTop = marginBottom = getDisplayPortedLength(splitedMargin[0]);
          marginLeft = marginRight = getDisplayPortedLength(splitedMargin[1]);
        } else if (splitedMargin.length == 3) {
          marginTop = getDisplayPortedLength(splitedMargin[0]);
          marginRight = marginLeft = getDisplayPortedLength(splitedMargin[1]);
          marginBottom = getDisplayPortedLength(splitedMargin[2]);
        } else if (splitedMargin.length == 4) {
          marginTop = getDisplayPortedLength(splitedMargin[0]);
          marginRight = getDisplayPortedLength(splitedMargin[1]);
          marginBottom = getDisplayPortedLength(splitedMargin[2]);
          marginLeft = getDisplayPortedLength(splitedMargin[3]);
        }
      }

      if (style.contains('marginLeft'))
        marginLeft = getDisplayPortedLength(style['marginLeft']);

      if (style.contains('marginTop'))
        marginTop = getDisplayPortedLength(style['marginTop']);

      if (style.contains('marginRight'))
        marginRight = getDisplayPortedLength(style['marginRight']);

      if (style.contains('marginBottom'))
        marginBottom = getDisplayPortedLength(style['marginBottom']);

      left = marginLeft ?? left;
      top = marginTop ?? top;
      right = marginRight ?? right;
      bottom = marginBottom ?? bottom;
    }
    return Padding(left, top, right, bottom);
  }

  EdgeInsets getMarginInsetsFromStyle(Style style) {
    oldMargin = getMarginFromStyle(style);
    return EdgeInsets.fromLTRB(oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);
  }

  void updateRenderMargin(Style style, [Map<String, Transition> transitionMap]) {
    assert(renderMargin != null);
    if (transitionMap != null) {
      Transition all = transitionMap["all"];
      Transition margin = transitionMap["margin"];
      Transition marginLeft = transitionMap["margin-left"];
      Transition marginRight = transitionMap["margin-right"];
      Transition marginBottom = transitionMap["margin-bottom"];
      Transition marginTop = transitionMap["margin-top"];

      if (all != null ||
          margin != null ||
          marginBottom != null ||
          marginLeft != null ||
          marginRight != null ||
          marginTop != null) {
        Padding newMargin = getMarginFromStyle(style);

        double marginLeftInterval = newMargin.left - oldMargin.left;
        double marginRightInterval = newMargin.right - oldMargin.right;
        double marginTopInterval = newMargin.top - oldMargin.top;
        double marginBottomInterval = newMargin.bottom - oldMargin.bottom;

        Padding progressMargin = Padding(
            oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);
        Padding baseMargin = Padding(
            oldMargin.left, oldMargin.top, oldMargin.right, oldMargin.bottom);

        all?.addProgressListener((progress) {
          if (margin == null) {
            if (marginTop == null) {
              progressMargin.top =
                  progress * marginTopInterval + baseMargin.top;
            }
            if (marginBottom == null) {
              progressMargin.bottom =
                  progress * marginBottomInterval + baseMargin.bottom;
            }
            if (marginLeft == null) {
              progressMargin.left =
                  progress * marginLeftInterval + baseMargin.left;
            }
            if (marginRight == null) {
              progressMargin.right =
                  progress * marginRightInterval + baseMargin.right;
            }
            renderMargin.margin = EdgeInsets.fromLTRB(
                progressMargin.left, progressMargin.top, progressMargin.right,
                progressMargin.bottom);
          }
        });

        margin?.addProgressListener((progress) {
          if (marginTop == null) {
            progressMargin.top =
                progress * marginTopInterval + baseMargin.top;
          }
          if (marginBottom == null) {
            progressMargin.bottom =
                progress * marginBottomInterval + baseMargin.bottom;
          }
          if (marginLeft == null) {
            progressMargin.left =
                progress * marginLeftInterval + baseMargin.left;
          }
          if (marginRight == null) {
            progressMargin.right =
                progress * marginRightInterval + baseMargin.right;
          }
          renderMargin.margin = EdgeInsets.fromLTRB(
              progressMargin.left, progressMargin.top, progressMargin.right,
              progressMargin.bottom);
        });
        marginTop?.addProgressListener((progress) {
          progressMargin.top =
              progress * marginTopInterval + baseMargin.top;
          renderMargin.margin = EdgeInsets.fromLTRB(
              progressMargin.left, progressMargin.top, progressMargin.right,
              progressMargin.bottom);
        });
        marginBottom?.addProgressListener((progress) {
          progressMargin.bottom =
              progress * marginBottomInterval + baseMargin.bottom;
          renderMargin.margin = EdgeInsets.fromLTRB(
              progressMargin.left, progressMargin.top, progressMargin.right,
              progressMargin.bottom);
        });
        marginLeft?.addProgressListener((progress) {
          progressMargin.left =
              progress * marginLeftInterval + baseMargin.left;
          renderMargin.margin = EdgeInsets.fromLTRB(
              progressMargin.left, progressMargin.top, progressMargin.right,
              progressMargin.bottom);
        });
        marginRight?.addProgressListener((progress) {
          progressMargin.right =
              progress * marginRightInterval + baseMargin.right;
          renderMargin.margin = EdgeInsets.fromLTRB(
              progressMargin.left, progressMargin.top, progressMargin.right,
              progressMargin.bottom);
        });
        oldMargin = newMargin;
      } else {
        renderMargin.margin = getMarginInsetsFromStyle(style);
      }
    }
  }

  RenderObject initRenderPadding(RenderObject renderObject, Style style) {
    EdgeInsets edgeInsets = getPaddingInsetsFromStyle(style);
    return renderPadding =
        RenderPadding(padding: edgeInsets, child: renderObject);
  }

  Padding getPaddingFromStyle(Style style) {
    double left = 0.0;
    double top = 0.0;
    double right = 0.0;
    double bottom = 0.0;

    if (style != null) {
      String padding = style['padding'];
      double paddingLeft;
      double paddingTop;
      double paddingRight;
      double paddingBottom;
      if (padding != null) {
        List<String> splitedpadding = getShorttedProperties(padding);
        if (splitedpadding.length == 1) {
          paddingLeft = paddingRight = paddingTop =
              paddingBottom = getDisplayPortedLength(splitedpadding[0]);
        } else if (splitedpadding.length == 2) {
          paddingTop =
              paddingBottom = getDisplayPortedLength(splitedpadding[0]);
          paddingLeft =
              paddingRight = getDisplayPortedLength(splitedpadding[1]);
        } else if (splitedpadding.length == 3) {
          paddingTop = getDisplayPortedLength(splitedpadding[0]);
          paddingRight =
              paddingLeft = getDisplayPortedLength(splitedpadding[1]);
          paddingBottom = getDisplayPortedLength(splitedpadding[2]);
        } else if (splitedpadding.length == 4) {
          paddingTop = getDisplayPortedLength(splitedpadding[0]);
          paddingRight = getDisplayPortedLength(splitedpadding[1]);
          paddingBottom = getDisplayPortedLength(splitedpadding[2]);
          paddingLeft = getDisplayPortedLength(splitedpadding[3]);
        }
      }

      if (style.contains('paddingLeft'))
        paddingLeft = getDisplayPortedLength(style['paddingLeft']);

      if (style.contains('paddingTop'))
        paddingTop = getDisplayPortedLength(style['paddingTop']);

      if (style.contains('paddingRight'))
        paddingRight = getDisplayPortedLength(style['paddingRight']);

      if (style.contains('paddingBottom'))
        paddingBottom = getDisplayPortedLength(style['paddingBottom']);

      left = paddingLeft ?? left;
      top = paddingTop ?? top;
      right = paddingRight ?? right;
      bottom = paddingBottom ?? bottom;
    }

    return Padding(left, top, right, bottom);
  }

  EdgeInsets getPaddingInsetsFromStyle(Style style) {
    oldPadding = getPaddingFromStyle(style);
    return EdgeInsets.fromLTRB(
        oldPadding.left, oldPadding.top, oldPadding.right, oldPadding.bottom);
  }

  void updateRenderPadding(Style style,
      [Map<String, Transition> transitionMap]) {
    assert(renderPadding != null);
    if (transitionMap != null) {
      Transition all = transitionMap["all"];
      Transition padding = transitionMap["padding"];
      Transition paddingLeft = transitionMap["padding-left"];
      Transition paddingRight = transitionMap["padding-right"];
      Transition paddingBottom = transitionMap["padding-bottom"];
      Transition paddingTop = transitionMap["padding-top"];

      if (all != null ||
          padding != null ||
          paddingBottom != null ||
          paddingLeft != null ||
          paddingRight != null ||
          paddingTop != null) {
        Padding newPadding = getPaddingFromStyle(style);

        double paddingLeftInterval = newPadding.left - oldPadding.left;
        double paddingRightInterval = newPadding.right - oldPadding.right;
        double paddingTopInterval = newPadding.top - oldPadding.top;
        double paddingBottomInterval = newPadding.bottom - oldPadding.bottom;

        Padding progressPadding = Padding(
            oldPadding.left, oldPadding.top, oldPadding.right,
            oldPadding.bottom);
        Padding basePadding = Padding(
            oldPadding.left, oldPadding.top, oldPadding.right,
            oldPadding.bottom);

        all?.addProgressListener((progress) {
          if (padding == null) {
            if (paddingTop == null) {
              progressPadding.top =
                  progress * paddingTopInterval + basePadding.top;
            }
            if (paddingBottom == null) {
              progressPadding.bottom =
                  progress * paddingBottomInterval + basePadding.bottom;
            }
            if (paddingLeft == null) {
              progressPadding.left =
                  progress * paddingLeftInterval + basePadding.left;
            }
            if (paddingRight == null) {
              progressPadding.right =
                  progress * paddingRightInterval + basePadding.right;
            }

            renderPadding.padding = EdgeInsets.fromLTRB(
                progressPadding.left, progressPadding.top, progressPadding.right,
                progressPadding.bottom);
          }
        });
        padding?.addProgressListener((progress) {
          if (paddingTop == null) {
            progressPadding.top =
                progress * paddingTopInterval + basePadding.top;
          }
          if (paddingBottom == null) {
            progressPadding.bottom =
                progress * paddingBottomInterval + basePadding.bottom;
          }
          if (paddingLeft == null) {
            progressPadding.left =
                progress * paddingLeftInterval + basePadding.left;
          }
          if (paddingRight == null) {
            progressPadding.right =
                progress * paddingRightInterval + basePadding.right;
          }

          renderPadding.padding = EdgeInsets.fromLTRB(
              progressPadding.left, progressPadding.top, progressPadding.right,
              progressPadding.bottom);
        });
        paddingTop?.addProgressListener((progress) {
          progressPadding.top =
              progress * paddingTopInterval + basePadding.top;
          renderPadding.padding = EdgeInsets.fromLTRB(
              progressPadding.left, progressPadding.top, progressPadding.right,
              progressPadding.bottom);
        });
        paddingBottom?.addProgressListener((progress) {
          progressPadding.bottom =
              progress * paddingBottomInterval + basePadding.bottom;
          renderPadding.padding = EdgeInsets.fromLTRB(
              progressPadding.left, progressPadding.top, progressPadding.right,
              progressPadding.bottom);
        });
        paddingLeft?.addProgressListener((progress) {
          progressPadding.left =
              progress * paddingLeftInterval + basePadding.left;
          renderPadding.padding = EdgeInsets.fromLTRB(
              progressPadding.left, progressPadding.top, progressPadding.right,
              progressPadding.bottom);
        });
        paddingRight?.addProgressListener((progress) {
          progressPadding.right =
              progress * paddingRightInterval + basePadding.right;
          renderPadding.padding = EdgeInsets.fromLTRB(
              progressPadding.left, progressPadding.top, progressPadding.right,
              progressPadding.bottom);
        });
        oldPadding = newPadding;
      } else {
        renderPadding.padding = getPaddingInsetsFromStyle(style);
      }
    }
  }
}

class Padding {
  double left;
  double top;
  double right;
  double bottom;

  Padding(this.left, this.top, this.right, this.bottom);
}

class SizeConstraints {
  double width;
  double height;
  double minWidth;
  double maxWidth;
  double minHeight;
  double maxHeight;

  SizeConstraints(this.width, this.height, this.minWidth, this.maxWidth,
      this.minHeight, this.maxHeight);

  BoxConstraints toBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth ?? width ?? 0.0,
      minHeight: minHeight ?? height ?? 0.0,
      maxWidth: maxWidth ?? width ?? double.infinity,
      maxHeight: maxHeight ?? height ?? double.infinity,
    );
  }
}