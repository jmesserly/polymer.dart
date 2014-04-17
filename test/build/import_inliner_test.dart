// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library polymer.test.build.import_inliner_test;

import 'package:polymer/src/build/common.dart';
import 'package:polymer/src/build/import_inliner.dart';
import 'package:unittest/compact_vm_config.dart';
import 'package:unittest/unittest.dart';

import 'common.dart';

void main() {
  useCompactVMConfiguration();
  var phases = [[new ImportInliner(new TransformOptions())]];
  testPhases('no changes', phases, {
      'a|web/test.html': '<!DOCTYPE html><html></html>',
    }, {
      'a|web/test.html': '<!DOCTYPE html><html></html>',
      'a|web/test.html.scriptUrls': '[]',
    });

  testPhases('empty import', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="">' // empty href
          '</head></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import">'         // no href
          '</head></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body></body></html>',
      'a|web/test.html.scriptUrls': '[]',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body></body></html>',
      'a|web/test2.html.scriptUrls': '[]',
    });

  testPhases('shallow, no elements', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2.html">'
          '</head></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body></body></html>',
      'a|web/test.html.scriptUrls': '[]',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head></html>',
      'a|web/test2.html.scriptUrls': '[]',
    });

  testPhases('shallow, elements, one import', phases,
    {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2.html">'
          '</head></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>2</polymer-element></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '</body></html>',
      'a|web/test.html.scriptUrls': '[]',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>2</polymer-element></html>',
      'a|web/test2.html.scriptUrls': '[]',
    });

  testPhases('no transformation outside web/', phases,
    {
      'a|lib/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2.html">'
          '</head></html>',
      'a|lib/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>2</polymer-element></html>',
    }, {
      'a|lib/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2.html">'
          '</head></html>',
      'a|lib/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>2</polymer-element></html>',
    });

  testPhases('shallow, elements, many', phases,
    {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2.html">'
          '<link rel="import" href="test3.html">'
          '</head></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>2</polymer-element></html>',
      'a|web/test3.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>3</polymer-element></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>3</polymer-element>'
          '</body></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>2</polymer-element></html>',
      'a|web/test3.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>3</polymer-element></html>',
    });

  testPhases('deep, elements, one per file', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2.html">'
          '</head></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="assets/b/test3.html">'
          '</head><body><polymer-element>2</polymer-element></html>',
      'b|asset/test3.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="../../packages/c/test4.html">'
          '</head><body><polymer-element>3</polymer-element></html>',
      'c|lib/test4.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>4</polymer-element></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>4</polymer-element>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>2</polymer-element></body></html>',
      'a|web/test2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>4</polymer-element>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>2</polymer-element></body></html>',
      'b|asset/test3.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="../../packages/c/test4.html">'
          '</head><body><polymer-element>3</polymer-element></html>',
      'c|lib/test4.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>4</polymer-element></html>',
    });

  testPhases('deep, elements, many imports', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test2a.html">'
          '<link rel="import" href="test2b.html">'
          '</head></html>',
      'a|web/test2a.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test3a.html">'
          '<link rel="import" href="test3b.html">'
          '</head><body><polymer-element>2a</polymer-element></body></html>',
      'a|web/test2b.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test4a.html">'
          '<link rel="import" href="test4b.html">'
          '</head><body><polymer-element>2b</polymer-element></body></html>',
      'a|web/test3a.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>3a</polymer-element></body></html>',
      'a|web/test3b.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>3b</polymer-element></body></html>',
      'a|web/test4a.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>4a</polymer-element></body></html>',
      'a|web/test4b.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>4b</polymer-element></body></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3a</polymer-element>'
          '<polymer-element>3b</polymer-element>'
          '<polymer-element>2a</polymer-element>'
          '<polymer-element>4a</polymer-element>'
          '<polymer-element>4b</polymer-element>'
          '<polymer-element>2b</polymer-element>'
          '</body></html>',
      'a|web/test2a.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3a</polymer-element>'
          '<polymer-element>3b</polymer-element>'
          '<polymer-element>2a</polymer-element>'
          '</body></html>',
      'a|web/test2b.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>4a</polymer-element>'
          '<polymer-element>4b</polymer-element>'
          '<polymer-element>2b</polymer-element>'
          '</body></html>',
      'a|web/test3a.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3a</polymer-element>'
          '</body></html>',
      'a|web/test3b.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3b</polymer-element>'
          '</body></html>',
      'a|web/test4a.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>4a</polymer-element>'
          '</body></html>',
      'a|web/test4b.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>4b</polymer-element>'
          '</body></html>',
    });

  testPhases('imports cycle, 1-step lasso', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_2.html">'
          '</head><body><polymer-element>1</polymer-element></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head><body><polymer-element>2</polymer-element></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element></body></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element></body></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>1</polymer-element>'
          '<polymer-element>2</polymer-element></body></html>',
    });

  testPhases('imports cycle, 1-step lasso, scripts too', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_2.html">'
          '</head><body><polymer-element>1</polymer-element>'
          '<script src="s1"></script></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head><body><polymer-element>2</polymer-element>'
          '<script src="s2"></script></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<script src="s2"></script>'
          '<polymer-element>1</polymer-element>'
          '<script src="s1"></script></body></html>',
      'a|web/test.html.scriptUrls': '[]',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<script src="s2"></script>'
          '<polymer-element>1</polymer-element>'
          '<script src="s1"></script></body></html>',
      'a|web/test_1.html.scriptUrls': '[]',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>1</polymer-element>'
          '<script src="s1"></script>'
          '<polymer-element>2</polymer-element>'
          '<script src="s2"></script></body></html>',
      'a|web/test_2.html.scriptUrls': '[]',
    });

  testPhases('imports cycle, 1-step lasso, Dart scripts too', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_2.html">'
          '</head><body><polymer-element>1</polymer-element>'
          '<script type="application/dart" src="s1.dart"></script></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head><body><polymer-element>2'
          '<script type="application/dart" src="s2.dart"></script>'
          '</polymer-element>'
          '</html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element>'
          '</body></html>',
      'a|web/test.html.scriptUrls': '[["a","web/s2.dart"],["a","web/s1.dart"]]',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element>'
          '<script type="application/dart" src="s1.dart"></script>'
          '</body></html>',
      'a|web/test_1.html.scriptUrls':
          '[["a","web/s2.dart"]]',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>1</polymer-element>'
          '<polymer-element>2'
          '<script type="application/dart" src="s2.dart"></script>'
          '</polymer-element>'
          '</body></html>',
      'a|web/test_2.html.scriptUrls':
          '[["a","web/s1.dart"]]',
    });

  testPhases('imports with Dart script after JS script', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head><body>'
          '<foo>42</foo><bar-baz></bar-baz>'
          '<polymer-element>1'
          '<script src="s1.js"></script>'
          '<script type="application/dart" src="s1.dart"></script>'
          '</polymer-element>'
          'FOO</body></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<foo>42</foo><bar-baz></bar-baz>'
          '<polymer-element>1'
          '<script src="s1.js"></script>'
          '</polymer-element>'
          'FOO</body></html>',
      'a|web/test.html.scriptUrls': '[["a","web/s1.dart"]]',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<foo>42</foo><bar-baz></bar-baz>'
          '<polymer-element>1'
          '<script src="s1.js"></script>'
          '<script type="application/dart" src="s1.dart"></script>'
          '</polymer-element>'
          'FOO</body></html>',
      'a|web/test_1.html.scriptUrls': '[]',
    });

  testPhases('imports cycle, 2-step lasso', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_2.html">'
          '</head><body><polymer-element>1</polymer-element></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_3.html">'
          '</head><body><polymer-element>2</polymer-element></html>',
      'a|web/test_3.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head><body><polymer-element>3</polymer-element></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element></body></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element></body></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>1</polymer-element>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>2</polymer-element></body></html>',
      'a|web/test_3.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>2</polymer-element>'
          '<polymer-element>1</polymer-element>'
          '<polymer-element>3</polymer-element></body></html>',
    });

  testPhases('imports cycle, self cycle', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '</head><body><polymer-element>1</polymer-element></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>1</polymer-element></body></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>1</polymer-element></body></html>',
    });

  testPhases('imports DAG', phases, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_1.html">'
          '<link rel="import" href="test_2.html">'
          '</head></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_3.html">'
          '</head><body><polymer-element>1</polymer-element></body></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '<link rel="import" href="test_3.html">'
          '</head><body><polymer-element>2</polymer-element></body></html>',
      'a|web/test_3.html':
          '<!DOCTYPE html><html><head>'
          '</head><body><polymer-element>3</polymer-element></body></html>',
    }, {
      'a|web/test.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>1</polymer-element>'
          '<polymer-element>2</polymer-element></body></html>',
      'a|web/test_1.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>1</polymer-element></body></html>',
      'a|web/test_2.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3</polymer-element>'
          '<polymer-element>2</polymer-element></body></html>',
      'a|web/test_3.html':
          '<!DOCTYPE html><html><head>'
          '</head><body>'
          '<polymer-element>3</polymer-element></body></html>',
    });
}
