import 'package:meta/meta.dart';
import 'package:momento_booth/views/base/build_context_abstractor.dart';
import 'package:momento_booth/views/base/build_context_accessor.dart';

abstract class ScreenViewModelBase with BuildContextAbstractor {

  @override
  final BuildContextAccessor contextAccessor;

  ScreenViewModelBase({
    required this.contextAccessor,
  });

  @mustCallSuper
  void dispose() {}
  
}
