// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

library dogma_codegen.src.codegen.field_generator;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:dogma_codegen/metadata.dart';

import 'comment_generator.dart';
import 'type_generator.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Definition of a function that generates the source code for a field.
///
/// The source code generated is written into the [buffer].
typedef void FieldGenerator(FieldMetadata field, StringBuffer buffer);

/// Definition of a function that generates annotations.
///
/// The generator should test the type of [value] to determine if the annoation
/// declaration should be written to the [buffer].
typedef void AnnotationGenerator(dynamic value, StringBuffer buffer);

/// Generates the source code for the [field] into the [buffer] using the
/// [generator].
///
/// Any annotations that are present on the [field] are passed to the
/// [annotationGenerators].
void generateField(FieldMetadata field,
                   StringBuffer buffer,
                   FieldGenerator generator,
                   List<AnnotationGenerator> annotationGenerators)
{
  // Write the comments out
  generateCodeComment(field.comments, buffer);

  // Write out any annotations
  for (var annotation in field.annotations) {
    for (var annotationGenerator in annotationGenerators) {
      annotationGenerator(annotation, buffer);
    }
  }

  // Write the declaration
  generator(field, buffer);
}

/// Generates the source code for the [fields] into the [buffer].
///
/// The [generator] specifies the function to write the source code for the
/// field. By default it is assumed that this is just a member variable and the
/// [generateMemeberVariable] function is used.
///
/// Any annotations that are present on the [fields] are passed to the
/// [annotationGenerators].
void generateFields(List<FieldMetadata> fields,
                    StringBuffer buffer,
                   {FieldGenerator generator,
                    List<AnnotationGenerator> annotationGenerators})
{
  generator = generateMemberVariables;
  annotationGenerators ??= new List<AnnotationGenerator>();

  for (var field in fields) {
    generateField(
        field,
        buffer,
        generator,
        annotationGenerators
    );
  }
}

/// Generates the source code of the [field] into the [buffer] for a member
/// variable declaration.
///
/// This function does not initialize the member variable in the generated
/// code.
void generateMemberVariables(FieldMetadata field, StringBuffer buffer) {
  buffer.writeln('${generateType(field.type)} ${field.name};');
}

/// Generates the @override annotation into the [buffer] if the [value] is
/// equal to [override].
void generateOverrideAnnotation(dynamic value, StringBuffer buffer) {
  if (value == override) {
    buffer.writeln('@override');
  }
}