/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "node.h"
#include "style_declaration.h"
#include "bindings/qjs/host_object.h"
#include <unordered_map>

namespace kraken::binding::qjs {

void bindElement(std::unique_ptr<JSContext> &context);

class ElementInstance;
class Element;
using ElementCreator = ElementInstance *(*)(Element *element, const char *tagName);

struct NativeBoundingClientRect {
  double x;
  double y;
  double width;
  double height;
  double top;
  double right;
  double bottom;
  double left;
};

class ElementAttributes : public HostObject {
public:
  ElementAttributes() = delete;
  explicit ElementAttributes(JSContext *context) : HostObject(context, "ElementAttributes") {}
  ~ElementAttributes() {
  };

  JSValue getAttribute(std::string &name);
  JSValue setAttribute(std::string &name, JSValue value);
  bool hasAttribute(std::string &name);
  void removeAttribute(std::string &name);

private:
  std::unordered_map<std::string, JSValue> m_attributes;
};

class Element : public Node {
public:
  Element() = delete;
  explicit Element(JSContext *context): Node(context, "Element") {}

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSValue getBoundingClientRect(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue hasAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue setAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue getAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue removeAttribute(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue toBlob(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue click(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scroll(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue scrollBy(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

  static void defineElement(const std::string& tagName, ElementCreator creator);

  static std::unordered_map<std::string, ElementCreator> elementCreatorMap;

  OBJECT_INSTANCE(Element);

  DEFINE_HOST_CLASS_PROPERTY(15, nodeName, tagName, offsetLeft, offsetTop, offsetWidth, offsetHeight,
                             clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft, scrollHeight,
                             scrollWidth, children);
private:
  ObjectFunction m_getBoundingClientRect{m_context, m_prototypeObject, "getBoundingClientRect", getBoundingClientRect, 0};
  ObjectFunction m_hasAttribute{m_context, m_prototypeObject, "hasAttribute", hasAttribute, 1};
  ObjectFunction m_setAttribute{m_context, m_prototypeObject, "setAttribute", setAttribute, 2};
  ObjectFunction m_getAttribute{m_context, m_prototypeObject, "getAttribute", getAttribute, 2};
  ObjectFunction m_removeAttribute{m_context, m_prototypeObject, "removeAttribute", removeAttribute, 1};
  ObjectFunction m_toBlob{m_context, m_prototypeObject, "toBlob", toBlob, 0};
  ObjectFunction m_click{m_context, m_prototypeObject, "click", click, 0};
  ObjectFunction m_scroll{m_context, m_prototypeObject, "scroll", scroll, 2};
  ObjectFunction m_scrollTo{m_context, m_prototypeObject, "scrollTo", scroll, 2};
  ObjectFunction m_scrollBy{m_context, m_prototypeObject, "scrollBy", scrollBy, 2};
  friend ElementInstance;
};

class ElementInstance : public NodeInstance {
public:
  ElementInstance() = delete;
  ~ElementInstance() override {
  }
  JSValue getStringValueProperty(std::string &name);
  std::string internalGetTextContent() override;
  void internalSetTextContent(JSValue content) override;
//  JSHostObjectHolder<JSElementAttributes> &getAttributes();
//  JSHostClassHolder &getStyle();
//  void setStyle(JSHostClassHolder &style);
//  void setAttributes(JSHostObjectHolder<JSElementAttributes> &attributes);

  std::string tagName();
  std::string getRegisteredTagName();

private:
  explicit ElementInstance(Element *element, const char* tagName, bool shouldAddUICommand);
  void _notifyNodeRemoved(NodeInstance *node) override;
  void _notifyChildRemoved();
  void _notifyNodeInsert(NodeInstance *insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string &name, JSValue &oldId, JSValue &newId);
  void _beforeUpdateId(JSValue &oldId, JSValue &newId);

  const char* m_tagName;
  friend Element;
  StyleDeclarationInstance *m_style{nullptr};
  ElementAttributes *m_attributes{nullptr};

  static JSValue getProperty(QjsContext *ctx, JSValueConst obj, JSAtom atom,
                                 JSValueConst receiver);
  int setProperty(QjsContext *ctx, JSValueConst obj, JSAtom atom,
                      JSValueConst value, JSValueConst receiver, int flags);

  JSClassExoticMethods exoticMethods{
    nullptr,
    nullptr,
    nullptr,
    nullptr,
    nullptr,
    getProperty,
    nullptr
  };
};

class BoundingClientRect : public HostObject {
public:
  BoundingClientRect() = delete;
  explicit BoundingClientRect(JSContext *context, NativeBoundingClientRect *nativeBoundingClientRect): HostObject(context, "BoundingClientRect") {

  };

private:
  NativeBoundingClientRect *m_nativeBoundingClientRect{nullptr};
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_ELEMENT_H