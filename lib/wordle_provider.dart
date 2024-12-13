import 'dart:math' as math;
import 'dart:developer' as dev;
import 'package:wordle/shared_pref_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordle/words.dart';
import 'constants.dart';

@immutable
class WordleData{
  final int wordIndex;
  final int column;
  final String word;
  final bool gameOver;
  final bool gameWon;
  final List<List<String>> cellValues;
  final List<List<CellStatus>> cellStatus;
  final List<CellStatus> keyStatus;
  final int coins;

  const WordleData({
    required this.wordIndex,
    required this.column,
    required this.word,
    required this.gameOver,
    required this.gameWon,
    required this.cellValues,
    required this.cellStatus,
    required this.keyStatus,
    required this.coins,
  });

  WordleData copyWith({
    int? wordIndex,
    int? column,
    String? word,
    bool? gameOver,
    bool? gameWon,
    List<List<String>>? cellValues,
    List<List<CellStatus>>? cellStatus,
    List<CellStatus>? keyStatus,
    int? coins,
  }) {
    return WordleData(
      wordIndex : wordIndex ?? this.wordIndex,
      column: column ?? this.column,
      word : word ?? this.word,
      gameOver : gameOver ?? this.gameOver,
      gameWon : gameWon ?? this.gameWon,
      cellValues : cellValues ?? this.cellValues,
      cellStatus : cellStatus ?? this.cellStatus,
      keyStatus: keyStatus ?? this.keyStatus,
      coins: coins ?? this.coins
    );
  }
}

final StateNotifierProvider<WordleLogic, WordleData> wordleLogicProvider =
            StateNotifierProvider<WordleLogic, WordleData>(
        (StateNotifierProviderRef ref)
    {
      return WordleLogic();
    }
    );

class WordleLogic extends StateNotifier<WordleData>{

  WordleLogic() : super(
    WordleData(
      wordIndex : 0,
      column: 0,
      word : allWords[math.Random().nextInt(allWords.length)].toUpperCase(),
      gameOver : false,
      gameWon : false,
      cellValues: List.generate(6, (_) => List.generate(5, (_) => ' ')),
      cellStatus: List.generate(6, (_) => List.generate(5, (_) => CellStatus.notPressed)),
      keyStatus: List.generate(26, (_) => CellStatus.notPressed),
      coins: Prefs.instance.coins,
      // coins: Prefs.instance.coins??1,
    ),
  ) ;

  logValues(){
    // dev.log('gameOver: ${state.gameOver} , gameWon: ${state.gameWon} , column: ${state.column} , wordIndex: ${state.wordIndex}');
    // dev.log(state.cellValues.toString());
    // dev.log(state.keyStatus.toString());
    dev.log(state.word);
  }

  onKeyPressed(String key)async{

    if (state.column == 0 && state.wordIndex == 0 && state.coins == -1){

    }
    if (state.column == 4 && state.cellValues[state.wordIndex][state.column] != ' '){
      return ;
    }
    List<List<String>> newCellValues = state.cellValues;
    newCellValues[state.wordIndex][state.column] = key;
    state = state.copyWith(
      column: state.column < 4 ? state.column + 1 : state.column,
      cellValues: newCellValues,
    );
  }

  clear(){
    if (state.gameOver){
      return;
    }

    if (state.column == 0 && state.cellValues[state.wordIndex][state.column] == ' '){
      return ;
    }

    List<List<String>> newCellValues = state.cellValues;
    newCellValues[state.wordIndex][state.column] = ' ';
    state = state.copyWith(
      column: state.column > 0 ? state.column - 1 : state.column,
      cellValues: newCellValues,
    );
  }

  String submit(){
    if (state.gameOver){
      return '';
    }

    if (state.column == 4 && state.cellValues[state.wordIndex][state.column] == ' '){
      return 'Word length should be 5 letters';
    }

    if (!allWords.contains(state.cellValues[state.wordIndex].join().toLowerCase())){
      return 'Word not found!!!';
    }

    List<List<CellStatus>> newCellStatus = state.cellStatus;
    List<CellStatus> newKeyStatus = state.keyStatus;
    bool newGameOver = false;
    bool newGameWon = false;

    for (int i = 0 ; i < 5 ; i++){
      if (state.cellValues[state.wordIndex][i] == state.word[i]){
        newCellStatus[state.wordIndex][i] = CellStatus.present;
        newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] = CellStatus.present;
      } else if (state.cellValues[state.wordIndex][i].allMatches(state.word).length == 3){
        newCellStatus[state.wordIndex][i] = CellStatus.threeTimes;
        if (newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] != CellStatus.present
        ){
          newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] = CellStatus.threeTimes;
        }
      } else if (state.cellValues[state.wordIndex][i].allMatches(state.word).length == 2) {
        newCellStatus[state.wordIndex][i] = CellStatus.twoTimes;
        if (newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] != CellStatus.threeTimes &&
            newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] != CellStatus.present
        ){
          newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] = CellStatus.twoTimes;
        }
      } else if (state.word.contains(state.cellValues[state.wordIndex][i])){
        newCellStatus[state.wordIndex][i] = CellStatus.wrongPos;
        if (newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] != CellStatus.present &&
            newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] != CellStatus.threeTimes &&
            newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] != CellStatus.twoTimes
        ){
          newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] = CellStatus.wrongPos;
        }
      } else {
        newCellStatus[state.wordIndex][i] = CellStatus.absent;
        newKeyStatus[Keys.fromVal(state.cellValues[state.wordIndex][i]).index] = CellStatus.absent;
      }
    }

    if (state.cellValues[state.wordIndex].join() == state.word){
      newGameOver = true;
      newGameWon = true;
    }

    if (state.wordIndex == 5){
      newGameOver = true;
    }

    if (state.gameWon){
      Prefs.instance.coins = Prefs.instance.coins + 1;
    }

    state = state.copyWith(
      cellStatus: newCellStatus,
      column: newGameOver ? state.column : 0,
      wordIndex: newGameOver ? state.wordIndex : state.wordIndex + 1,
      gameOver: newGameOver,
      gameWon: newGameWon,
      coins: newGameWon ? state.coins+1 : state.coins,
    );

    return newGameWon ? 'GAME WON' :'';
  }

  refresh(){
    state = WordleData(
      wordIndex : 0,
      column: 0,
      word : allWords[math.Random().nextInt(allWords.length)].toUpperCase(),
      gameOver : false,
      gameWon : false,
      cellValues: List.generate(6, (_) => List.generate(5, (_) => ' ')),
      cellStatus: List.generate(6, (_) => List.generate(5, (_) => CellStatus.notPressed)),
      keyStatus: List.generate(26, (_) => CellStatus.notPressed),
      coins: state.coins,
    );
  }

}