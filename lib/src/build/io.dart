// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Utility functions for file I/O when generating files.
library dogma_codegen.src.build.io;

//---------------------------------------------------------------------
// Standard libraries
//---------------------------------------------------------------------

import 'dart:async';
import 'dart:io';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

import 'package:dogma_codegen/codegen.dart';
import 'package:dogma_codegen/metadata.dart';
import 'package:dogma_codegen/template.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Creates a directory at the given [path] and returns whether it was created.
///
/// The function determines if the directory is present on the disk and if not
/// goes through the process of creating it.
Future<bool> createDirectory(String path) async {
  var directory = new Directory(path);

  if (!await directory.exists()) {
    await directory.create(recursive: true);

    // Was not present
    return false;
  } else {
    // Was present
    return true;
  }
}

/// Determines whether the file was generated by the codegen library.
Future<bool> isGeneratedFile(Uri uri) => _isGeneratedFile(_getFile(uri));

/// Determines whether a file can be generated at the [uri].
Future<bool> canGenerateFileAt(Uri uri) async {
  var file = _getFile(uri);

  return await file.exists()
      ? _isGeneratedFile(file)
      : true;
}

/// Gets the
File _getFile(Uri uri) {
  var path = uri.toFilePath();

  return new File(path);
}

Future<bool> _isGeneratedFile(File file) async {
  var lines = await file.readAsLines();

  return isGeneratedSource(lines);
}

/// Writes the root [library] to disk.
///
/// This is used to handle root libraries which just export libraries.
Future<Null> writeRootLibrary(LibraryMetadata library) =>
    _writeLibrary(library, generateRootLibrary);

/// Writes the [library] of models to disk.
Future<Null> writeModelsLibrary(LibraryMetadata library) =>
    _writeLibrary(library, generateModelsLibrary);

/// Writes the [library] of unmodifiable model views to disk.
Future<Null> writeUnmodifiableModelViewsLibrary(LibraryMetadata library) =>
    _writeLibrary(library, generateUnmodifiableModelViewsLibrary);

/// Writes the [library] of converters to disk.
Future<Null> writeConvertersLibrary(LibraryMetadata library) =>
    _writeLibrary(library, generateConvertersLibrary);

/// Writes the [library] of mappers to disk.
Future<Null> writeMappersLibrary(LibraryMetadata library) =>
    _writeLibrary(library, generateMappersLibrary);

/// Writes the [library] to disk using the [generator].
Future<Null> _writeLibrary(LibraryMetadata library, LibraryGenerator generator) async {
  var file = new File(library.uri.toFilePath());

  // Determine if the file was generated
  if (await file.exists()) {
    var lines = await file.readAsLines();

    if (!isGeneratedSource(lines)) {
      return;
    }
  }

  await file.writeAsString(generator(library));
}
