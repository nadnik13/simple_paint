import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

class LineState extends Equatable {
  final DrawnLine? line;

  const LineState({this.line});

  LineState copyWith({DrawnLine? line}) {
    return LineState(line: line ?? this.line);
  }

  @override
  List<Object?> get props => [line];
}

class LineInitial extends LineState {
  const LineInitial() : super(line: null);
}
