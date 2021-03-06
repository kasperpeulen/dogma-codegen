// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Functions for handling uri paths.
library dogma_codegen.path;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:path/path.dart' as p;

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

final Uri currentPathUri = p.toUri(p.current);

/// The current path running the application.
///
/// Parses the current path using the path based on the environment and then
/// converts to a posix style. This is done to ensure that paths are handled
/// consistently as all path operations will be done using the posix
/// implementation held in path.
final String currentPath = currentPathUri.toFilePath(windows: false);

Uri join(dynamic value, {dynamic base}) {
  base ??= currentPath;

  if (base is Uri) {
    base = base.toFilePath(windows: false);
  }

  if (value is String) {
    value = p.posix.joinAll(p.split(value));
  }

  var joined = p.posix.join(base, value);

  return p.posix.toUri(joined);
}

String relative(dynamic value, {dynamic from}) {
  from ??= currentPath;

  // Turn into a file path
  from = _filePath(from);
  value = _filePath(value);

  // Convert from into the dirname
  from = _isDirectory(from) ? from : p.posix.dirname(from);

  return p.posix.relative(value, from: from);
}

bool isWithin(dynamic parent, dynamic child) {
  // Turn into a file path
  parent = _filePath(parent);
  child = _filePath(child);

  return p.posix.isWithin(parent, child);
}

String dirname(dynamic value) {
  value = _filePath(value);

  return p.posix.dirname(value);
}

String basenameWithoutExtension(dynamic value) {
  value = _filePath(value);

  return p.posix.basenameWithoutExtension(value);
}

Uri libraryPath(String value) {
  // Split based on the .
  var split = value.split('.').sublist(1);

  var base = _isInLib(split[0])
      ? p.posix.join(currentPath, 'lib')
      : currentPath;

  // Add .dart to the last value
  split[split.length - 1] += '.dart';

  return p.posix.toUri(p.posix.join(base, p.posix.joinAll(split)));
}

String libraryName(String package, dynamic path) {
  path = _filePath(path);

  // Get the relative path
  var relative = p.posix.relative(path, from: currentPath);
  var withoutExtension = p.posix.withoutExtension(relative);

  // Split the path
  var split = p.posix.split(withoutExtension);

  // Check if the value is in lib
  if (_isInLib(split[0])) {
    split = split.sublist(1);
  }

  // Append the package name at the front
  split = <String>[package]..addAll(split);

  return split.join('.');
}

/// Converts the [value] into a file path.
String _filePath(dynamic value) =>
    value is Uri ? value.toFilePath(windows: false) : value;

bool _isInLib(String value) =>
    value != 'example' &&
    value != 'test' &&
    value != 'bin' &&
    value != 'tool';

bool _isDirectory(String value) => p.posix.withoutExtension(value) == value;
