// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Contains the [LibraryMetadata] class.
library dogma_codegen.src.metadata.library_metadata;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'class_metadata.dart';
import 'converter_function_metadata.dart';
import 'converter_metadata.dart';
import 'enum_metadata.dart';
import 'field_metadata.dart';
import 'function_metadata.dart';
import 'metadata.dart';
import 'mapper_metadata.dart';
import 'model_metadata.dart';
import 'type_metadata.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Contains metadata for a dart library.
class LibraryMetadata extends Metadata {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The location of the library.
  final Uri uri;
  /// The libraries imported by the library.
  final List<LibraryMetadata> imported;
  /// The libraries exported by the library.
  final List<LibraryMetadata> exported;
  /// The classes contained within the library.
  final List<ClassMetadata> classes;
  /// The functions contained within the library.
  final List<FunctionMetadata> functions;
  /// The fields contained within the library.
  final List<FieldMetadata> fields;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  LibraryMetadata(String name,
                  this.uri,
                 {List<LibraryMetadata> imported,
                  List<LibraryMetadata> exported,
                  List<ClassMetadata> classes,
                  List<FunctionMetadata> functions,
                  List<FieldMetadata> fields})
      : imported = imported ?? <LibraryMetadata>[]
      , exported = exported ?? <LibraryMetadata>[]
      , classes = classes ?? <ClassMetadata>[]
      , functions = functions ?? <FunctionMetadata>[]
      , fields = fields ?? <FieldMetadata>[]
      , super(name);

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  @deprecated
  Iterable<ClassMetadata> get models =>
      classes.where((value) => value is ModelMetadata);

  @deprecated
  Iterable<ClassMetadata> get converters =>
      classes.where((value) => value is ConverterMetadata);

  @deprecated
  Iterable<ClassMetadata> get enumerations =>
      classes.where((value) => value is EnumMetadata);

  @deprecated
  Iterable<ClassMetadata> get mappers =>
      classes.where((value) => value is MapperMetadata);
}

//---------------------------------------------------------------------
// Metadata searching by name
//---------------------------------------------------------------------

typedef List<Metadata> _MetadataList(LibraryMetadata library);

/// Searches the [library] for metadata with the given [name].
Metadata findMetadata(LibraryMetadata library,
                      String name,
                     {bool searchExports: true,
                      bool searchImports: true})
{
  var enumeration = findEnumeration(library, name);

  if (enumeration != null) {
    return enumeration;
  }

  var model = findModel(library, name);

  if (model != null) {
    return model;
  }

  var function = findFunction(library, name);

  if (function != null) {
    return function;
  }

  // Not found
  return null;
}



FunctionMetadata findFunction(LibraryMetadata library,
                              String name,
                             {bool searchImports: true,
                              bool searchExports: true})
    => _findMetadata(library, name, searchImports, searchExports, _functionList);

ModelMetadata findModel(LibraryMetadata library,
                        String name,
                        {bool searchImports: true,
                         bool searchExports: true})
    => _findMetadata(library, name, searchImports, searchExports, _modelList);

EnumMetadata findEnumeration(LibraryMetadata library,
                             String name,
                            {bool searchImports: true,
                             bool searchExports: true})
    => _findMetadata(library, name, searchImports, searchExports, _enumerationList);

Metadata _findMetadata(LibraryMetadata library,
                       String name,
                       bool searchImports,
                       bool searchExports,
                       _MetadataList list)
{
  for (var metadata in list(library)) {
    if (metadata.name == name) {
      return metadata;
    }
  }

  if (searchImports) {
    for (var import in library.imported) {
      var metadata = _findMetadata(import, name, searchImports, searchExports, list);

      if (metadata != null) {
        return metadata;
      }
    }
  }

  if (searchExports) {
    for (var export in library.exported) {
      var metadata = _findMetadata(export, name, searchImports, searchExports, list);

      if (metadata != null) {
        return metadata;
      }
    }
  }

  // Not found
  return null;
}

/// Gets the list of [ModelMetadata] from the [library].
List<ClassMetadata> _modelList(LibraryMetadata library) =>
    library.models.toList();
/// Gets the list of [EnumMetadata] from the [library].
List<ClassMetadata> _enumerationList(LibraryMetadata library) =>
    library.enumerations.toList();
/// Gets the list of [FunctionMetadata] from the [library].
List<FunctionMetadata> _functionList(LibraryMetadata library) =>
    library.functions;

//---------------------------------------------------------------------
// Metadata searching by type
//---------------------------------------------------------------------

/// Searches the [library] for a decode function of the given [type].
FunctionMetadata findDecodeFunctionByType(LibraryMetadata library,
                                          TypeMetadata type,
                                         {bool searchImports: true,
                                          bool searchExports: true})
{
  for (var function in library.functions) {
     if ((function is ConverterFunctionMetadata) &&
         (function.isDefaultDecoder) &&
         (function.modelType == type)) {
      return function;
    }
  }

  // Not found
  return null;
}

/// Searches the [library] for an encode function of the given [type].
FunctionMetadata findEncodeFunctionByType(LibraryMetadata library,
                                          TypeMetadata type,
                                         {bool searchImports: true,
                                          bool searchExports: true})
{
  for (var function in library.functions) {
    if ((function is ConverterFunctionMetadata) &&
        (function.isDefaultEncoder) &&
        (function.modelType == type)) {
      return function;
    }
  }

  // Not found
  return null;
}

/// Searches the [library] for all model decoders of the given [type].
List<ConverterMetadata> findAllModelDecodersByType(LibraryMetadata library,
                                                   TypeMetadata type,
                                                  {bool searchImports: true,
                                                   bool searchExports: true})
{
  return [];
}

/// Searches the [library] for all model encoders of the given [type].
List<ConverterMetadata> findAllModelEncodersByType(LibraryMetadata library,
                                                   TypeMetadata type,
                                                  {bool searchImports: true,
                                                   bool searchExports: true})
{
  return [];
}
