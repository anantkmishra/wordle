import 'package:flutter/material.dart';

enum Keys {
  q('Q'), w('W'), e('E'), r('R'), t('T'), y('Y'), u('U'), i('I'), o('O'), p('P'),
      a('A'), s('S'), d('D'), f('F'), g('G'), h('H'), j('J'), k('K'), l('L'),
          z('Z'), x('X'), c('C'), v('V'), b('B'), n('N'), m('M');

  final String val;
  const Keys(this.val);

  static Keys fromVal (String d){
    return values.firstWhere((v) => v.val == d, orElse: () => Keys.q);
  }

  // 'A','B','C','D','E',
  // 'F','G','H','I','J',
  // 'K','L','M','N','O',
  // 'P','Q','R','S','T',
  // 'U','V','W','X','Y',
  // 'Z',
}

final List<Color> bgColor = [
  const Color(0xFF000000),//absent
  const Color(0xFFEE4444),//not present
  const Color(0xFF4488FF),//wrong pos
  const Color(0xFF44AA44),//present
  const Color(0xFFEEAA22),//twoTimes
  const Color(0xFFB66D3B),//threeTimes
  const Color(0xFF263238),
  const Color(0xFFFFFFFF),
];

enum CellStatus {notPressed, absent, wrongPos, present, twoTimes, threeTimes}
