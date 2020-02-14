/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "screen.h"
#include "jsa.h"
#include "logging.h"
#include "dart_callbacks.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

void JSScreen::bind(std::unique_ptr<JSContext> &context) {
  auto screen = Object::createFromHostObject(*context, sharedSelf());
  JSA_SET_PROPERTY(*context, context->global(), "screen", screen);
}

void JSScreen::unbind(std::unique_ptr<JSContext> &context) {
  JSA_SET_PROPERTY(*context, context->global(), "screen", Value::undefined());
}

Value JSScreen::get(JSContext &context, const PropNameID &name) {
  auto propertyName = name.utf8(context);

  if (getDartFunc()->getScreen == nullptr) {
    KRAKEN_LOG(ERROR) << "getScreen dart API not register";
    return Value::undefined();
  }

  Screen *screen = getDartFunc()->getScreen();

  if (propertyName == "width" || propertyName == "availWidth") {
    return Value(screen->width);
  } else if (propertyName == "height" || propertyName == "availHeight") {
    return Value(screen->height);
  }

  return Value::undefined();
}

void JSScreen::set(JSContext &, const PropNameID &name, const Value &value) {
  // do nothing
}

std::vector<PropNameID> JSScreen::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> names;
  names.emplace_back(PropNameID::forAscii(context, "width"));
  names.emplace_back(PropNameID::forAscii(context, "height"));
  names.emplace_back(PropNameID::forAscii(context, "availWidth"));
  names.emplace_back(PropNameID::forAscii(context, "availHeight"));
  return names;
}

} // namespace binding
} // namespace kraken