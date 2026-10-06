// Package imports:
import 'package:logger/logger.dart';

final _logger = Logger();

void logError(dynamic msg, [dynamic e, StackTrace? s]) =>
    _logger.e(msg, error: e, stackTrace: s);

void logInfo(dynamic msg, [dynamic e, StackTrace? s]) =>
    _logger.i(msg, error: e, stackTrace: s);

// void logError(dynamic msg, [dynamic e, StackTrace? s]) => _logger.e(msg, error:e,stackTrace: s);

// void logInfo(dynamic msg, [dynamic e, StackTrace? s]) => _logger.i(msg, error:e,stackTrace:s);

