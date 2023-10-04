import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/apis/apis.dart';

part 'apis.api.dart';

@mainApi
class Apis with ApisGen {}
