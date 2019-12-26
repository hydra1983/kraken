/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:core';
import 'package:flutter/rendering.dart';
import 'package:kraken/element.dart';
import 'package:kraken/style.dart';

abstract class ElementManagerActionDelegate {
  RenderObject root;
  Element rootElement;

  void createElement(List payload);

  void createTextNode(List payload);

  void removeNode(List payload);

  void setProperty(List payload);

  void removeProperty(List payload);

  void insertAdjacentNode(List payload);

  void addEvent(List payload);

  void removeEvent(List payload);

  dynamic method(List payload);
}

class W3CElementManagerActionDelegate implements ElementManagerActionDelegate {
  final int BODY_ID = -1;
  @override
  Element rootElement;

  W3CElementManagerActionDelegate() {
    rootElement = BodyElement(BODY_ID);
    _root =
        RenderDecoratedBox(
          decoration: BoxDecoration(color: WebColor.white),
          child: rootElement.renderObject
        );
    nodeMap[BODY_ID] = rootElement;
  }

  RenderBox _root;
  RenderBox get root => _root;
  Map<int, Node> nodeMap = {};

  void createElement(List<dynamic> payload) {
    PayloadNode node = PayloadNode.fromJson(payload[0]);
    assert(node != null);
    if (nodeMap.containsKey(node.id)) {
      throw Exception('ERROR: can not create element with same id: $node.id');
    }

    Node el;

    switch (node.type) {
      case 'COMMENT':
        el = Comment(node.id);
        break;
      default:
        el = createW3CElement(node);
        break;
    }

    nodeMap[node.id] = el;
  }

  void createTextNode(List<dynamic> payload) {
    PayloadNode node = PayloadNode.fromJson(payload[0]);
    TextNode textNode = TextNode.create(node.id, node.data);
    nodeMap[node.id] = textNode;
  }

  void removeNode(List<dynamic> payload) {
    int targetId = payload[0];
    assert(nodeMap.containsKey(targetId));

    Node target = nodeMap[targetId];
    assert(target != null);

    target?.parentNode?.removeChild(target);
  }

  void setProperty(List<dynamic> payload) {
    int targetId = payload[0];
    String key = payload[1];
    assert(nodeMap.containsKey(targetId));

    dynamic value = payload[2];
    Node target = nodeMap[targetId];
    assert(target != null);

    target.setProperty(key, value);
  }

  void removeProperty(List<dynamic> payload) {
    int targetId = payload[0];
    assert(nodeMap.containsKey(targetId));
    String key = payload[1];

    Node target = nodeMap[targetId];
    assert(target != null);

    target.removeProperty(key);
  }

  /// <!-- beforebegin -->
  /// <p>
  ///   <!-- afterbegin -->
  ///   foo
  ///   <!-- beforeend -->
  /// </p>
  /// <!-- afterend -->
  void insertAdjacentNode(List<dynamic> payload) {
    int targetId = payload[0];
    String position = payload[1];
    int nodeId = payload[2];
    assert(nodeMap.containsKey(targetId));
    assert(nodeMap.containsKey(nodeId));

    Node target = nodeMap[targetId];
    Node newNode = nodeMap[nodeId];

    switch (position) {
      case 'beforebegin':
        target?.parentNode?.insertBefore(newNode, target);
        break;
      case 'afterbegin':
        target.insertBefore(newNode, target.firstChild);
        break;
      case 'beforeend':
        target.appendChild(newNode);
        break;
      case 'afterend':
        if (target.parentNode.lastChild == target) {
          target.parentNode.appendChild(newNode);
        } else {
          target.parentNode.insertBefore(
            newNode,
            target.parentNode
                .childNodes[target.parentNode.childNodes.indexOf(target) + 1],
          );
        }

        break;
    }
    RendererBinding.instance.renderView.performLayout();
  }

  void addEvent(List<dynamic> payload) {
    int targetId = payload[0];
    assert(nodeMap.containsKey(targetId));
    String eventName = payload[1];

    Element target = nodeMap[targetId];
    assert(target != null);

    target.addEvent(eventName);
  }

  void removeEvent(List<dynamic> payload) {
    int targetId = payload[0];
    assert(nodeMap.containsKey(targetId));
    String eventName = payload[1];

    Element target = nodeMap[targetId];
    assert(target != null);

    target.removeEvent(eventName);
  }

  @override
  set root(RenderObject _root) {
    assert(() {
      throw FlutterError(
          'Can not set root to W3CElementManagerActionDelegate.');
    }());
  }

  @override
  dynamic method(List<dynamic> payload) {
    int targetId = payload[0];
    assert(nodeMap.containsKey(targetId));
    String methodName = payload[1];
    List<dynamic> args = payload[2];

    Element target = nodeMap[targetId];
    assert(target != null);

    return target.method(methodName, args);
  }
}

class ElementManager {
  ElementManagerActionDelegate _actionDelegate;
  static ElementManager _managerSingleton = ElementManager._();
  factory ElementManager() => _managerSingleton;

  ElementManager._() {
    _actionDelegate = W3CElementManagerActionDelegate();
  }

  RenderBox getRootRenderObject() {
    return _actionDelegate.root;
  }

  Element getRootElement() {
    return _actionDelegate.rootElement;
  }

  void connect({ bool showPerformanceOverlay = false }) {
    RendererBinding.instance.renderView.child = getRootRenderObject();
    if (showPerformanceOverlay) {
      RenderPerformanceOverlay renderPerformanceOverlay = RenderPerformanceOverlay(optionsMask: 15, rasterizerThreshold: 0);
      _actionDelegate.rootElement.renderLayoutElement.add(renderPerformanceOverlay);
    }
  }

  void disconnect() {
    RendererBinding.instance.renderView.child = null;
    _managerSingleton = ElementManager._();
  }

  dynamic applyAction(String action, List<dynamic> payload) {
    var returnValue;
    switch (action) {
      case 'createElement':
        _actionDelegate.createElement(payload);
        break;
      case 'createTextNode':
        _actionDelegate.createTextNode(payload);
        break;
      case 'insertAdjacentNode':
        _actionDelegate.insertAdjacentNode(payload);
        break;
      case 'removeNode':
        _actionDelegate.removeNode(payload);
        break;
      case 'setProperty':
        _actionDelegate.setProperty(payload);
        break;
      case 'removeProperty':
        _actionDelegate.removeProperty(payload);
        break;
      case 'addEvent':
        _actionDelegate.addEvent(payload);
        break;
      case 'removeEvent':
        _actionDelegate.removeEvent(payload);
        break;
      case 'method':
        returnValue = _actionDelegate.method(payload);
        break;
    }

    return returnValue;
  }
}

class PayloadNode {
  int id;
  String type;
  Map<String, dynamic> props = {};
  List<String> events = [];
  String data;

  PayloadNode.fromJson(Map<String, dynamic> json) {
    List<dynamic> events = json['events'];
    id = json['id'];
    type = json['type'];

    if (json['props'] != null) {
      props = json['props'];
    }

    if (events != null) {
      for (var eventName in events) {
        if (eventName is String) this.events.add(eventName);
      }
    }
    data = json['data'];
  }

  String toString() {
    return 'PayloadNode(id: $id, type: $type, props: $props, events: $events, data: $data)';
  }
}