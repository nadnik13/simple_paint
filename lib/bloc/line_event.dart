import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

abstract class LineEvent extends Equatable {
  const LineEvent();

  @override
  List<Object> get props => [];
}

class UpdateLineEvent extends LineEvent {
  final DrawnLine line;
  const UpdateLineEvent({required this.line});

  @override
  List<Object> get props => [line];
}

class ClearLineEvent extends LineEvent {
  const ClearLineEvent();
}
