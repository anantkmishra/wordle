import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordle/constants.dart';
import 'package:wordle/wordle_provider.dart';
import 'shared_pref_service.dart';
// import 'dart:developer' as dev;

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Wordle',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    WordleData data = ref.watch(wordleLogicProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('WORDLE', style: TextStyle(color: bgColor[7], fontWeight: FontWeight.w900),),
        backgroundColor: bgColor[0],
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: (){ref.read(wordleLogicProvider.notifier).logValues();},
              child: const Text('LOG', style: TextStyle(color: Colors.white),),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: bgColor[7],),
            tooltip: 'REFRESH',
            onPressed: ref.read(wordleLogicProvider.notifier).refresh,
          ),
        ],
      ),
      backgroundColor: bgColor[6],
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFFFFFF00),),
                  Text(data.coins.toString(), style: TextStyle(color: bgColor[5], fontWeight: FontWeight.w900),),
                  const Spacer(),
                  colorCodes(),
                ],
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              children: List.generate(6, (row) {
                return Row(
                  children: List.generate(5, (index) {
                    return Container(
                      height: 50,//row == data.wordIndex ? 50 : 30,
                      width: MediaQuery.of(context).size.width / 5 - 20,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: bgColor[data.cellStatus[row][index].index],
                          borderRadius: BorderRadius.circular(5),
                          border: row == data.wordIndex && index == data.column
                              ? Border.all(color: bgColor[7], width: 5)//current cell
                              : row == data.wordIndex
                                ? Border.all(color: bgColor[7] , width: 2) //current row
                                : Border.all(color: bgColor[6], //all other cells
                          ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        data.cellValues[row][index],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: bgColor[7], fontWeight: FontWeight.w800),
                      )
                    );
                  }),
                );
              }),
            ),
            const SizedBox(height: 20,),
        
            //KEYBOARD
            Visibility(
              visible: !data.gameOver,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MaterialButton(
                      onPressed: () {
                        ref.read(wordleLogicProvider.notifier).onKeyPressed(Keys.values[index].val);
                      },
                      color: bgColor[(data.keyStatus[index]).index],
                      minWidth: 15,
                      height: 50,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(10),
                      textColor: bgColor[7],
                      child: Text(Keys.values[index].val),
                    ),
                  );
                }),
              ),
            ),
            Visibility(
              visible: !data.gameOver,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(9, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MaterialButton(
                      onPressed: () {
                        ref.read(wordleLogicProvider.notifier).onKeyPressed(Keys.values[10+index].val);
                      },
                      color: bgColor[(data.keyStatus[10+index]).index],
                      minWidth: 15,
                      height: 50,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(10),
                      textColor: Colors.white,
                      child: Text(Keys.values[10+index].val),
                    ),
                  );
                }),
              ),
            ),
            Visibility(
              visible: !data.gameOver,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(9, (index) {
                  if (index == 0){
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: MaterialButton(
                        onPressed: (){
                          String msg = ref.read(wordleLogicProvider.notifier).submit();

                          if (msg.isNotEmpty){
                            if (msg == 'GAME WON'){
                              showDialog(
                                barrierDismissible: false,
                                  context: context,
                                  builder: (context){
                                return Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: Icon(Icons.close, color: bgColor[7], size: 40,),
                                        onPressed:(){
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    Image.asset('assets/congrats.gif'),
                                    Text(
                                      'CONGRATULATIONS',
                                      style: TextStyle(
                                          color: bgColor[7], fontWeight: FontWeight.w600, fontSize: 30, decoration: TextDecoration.none),
                                    ),
                                    Text(
                                      'YOU WON',
                                      style: TextStyle(
                                          color: bgColor[7], fontWeight: FontWeight.w600, fontSize: 20, decoration: TextDecoration.none),
                                    ),
                                    const SizedBox(height: 20,),
                                    TextButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                          ref.read(wordleLogicProvider.notifier).refresh;
                                        },
                                        style: TextButton.styleFrom(
                                            side: BorderSide(color: bgColor[7])
                                        ),
                                        child: Text('Play Again', style: TextStyle(color: bgColor[7], fontSize: 20, fontWeight: FontWeight.w300),)
                                    )
                                  ],
                                );
                              });
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:  Text(msg),
                                // backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                dismissDirection: DismissDirection.up,
                                showCloseIcon: true,
                                closeIconColor: const Color(0xFFFFFFFF),
                                margin: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height - 100,
                                  left: 10,
                                  right: 10,
                                ),
                              ),
                            );
                          }
                        },
                        color: Colors.black,
                        minWidth: 15,
                        height: 50,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(10),
                        textColor: Colors.white,
                        child: const Text('Submit'),
                      ),
                    );
                  }
        
                  if (index == 8){
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: MaterialButton(
                        onPressed: ref.read(wordleLogicProvider.notifier).clear,
                        color: Colors.black,
                        minWidth: 15,
                        height: 50,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(10),
                        textColor: Colors.white,
                        child: const Icon(Icons.backspace_outlined),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: MaterialButton(
                      onPressed: () {
                        ref.read(wordleLogicProvider.notifier).onKeyPressed(Keys.values[18+index].val);
                      },
                      color:bgColor[(data.keyStatus[18+index]).index],
                      minWidth: 15,
                      height: 50,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.all(10),
                      textColor: Colors.white,
                      child: Text(Keys.values[18+index].val),
                    ),
                  );
                }),
              ),
            ),
            Visibility(
              visible: data.gameOver,
              child : Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.gameWon ? bgColor[3] : bgColor[1],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    Text(
                      data.gameWon
                          ? 'Congratulations, You have Won.'
                          : ":( You didn't get it, \nThe word was ${data.word}\nBetter Luck Next Time.",
                      style: TextStyle(fontSize: 20, color: bgColor[7]),
                    ),
                    TextButton(
                        onPressed: ref.read(wordleLogicProvider.notifier).refresh,
                        style: TextButton.styleFrom(
                          side: BorderSide(color: bgColor[0])
                        ),
                        child: Text('Play Again', style: TextStyle(color: bgColor[0], fontSize: 20, fontWeight: FontWeight.w300),)
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget colorCodes(){
    return PopupMenuButton<CellStatus>(
      icon: Row(
        children: [
          Icon(Icons.arrow_drop_down, color: bgColor[7],),
          Text('Color Codes', style: TextStyle(color: bgColor[7])),
        ],
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<CellStatus>>[
        PopupMenuItem<CellStatus>(
          value: CellStatus.notPressed,
          child: Row(
            children: [
              Icon(Icons.circle, color: bgColor[CellStatus.notPressed.index],),
              const Text('NOT PRESSED / EMPTY'),
            ],
          ),
        ),
        PopupMenuItem<CellStatus>(
          value: CellStatus.absent,
          child:
          Row(
            children: [
              Icon(Icons.circle, color: bgColor[CellStatus.absent.index],),
              const Text('NOT PRESENT'),
            ],
          ),
        ),
        PopupMenuItem<CellStatus>(
          value: CellStatus.wrongPos,
          child:
          Row(
            children: [
              Icon(Icons.circle, color: bgColor[CellStatus.wrongPos.index],),
              const Text('PRESENT BUT WRONG POSITION'),
            ],
          ),
        ),
        PopupMenuItem<CellStatus>(
          value: CellStatus.present,
          child:
          Row(
            children: [
              Icon(Icons.circle, color: bgColor[CellStatus.present.index],),
              const Text('CORRECT POSITION'),
            ],
          ),
        ),
        PopupMenuItem<CellStatus>(
          value: CellStatus.twoTimes,
          child:
          Row(
            children: [
              Icon(Icons.circle, color: bgColor[CellStatus.twoTimes.index],),
              const Text('TWO TIMES IN WORD'),
            ],
          ),
        ),
        PopupMenuItem<CellStatus>(
          value: CellStatus.threeTimes,
          child:
          Row(
            children: [
              Icon(Icons.circle, color: bgColor[CellStatus.threeTimes.index],),
              const Text('THREE TIMES IN WORD'),
            ],
          ),
        ),
      ],
    );
  }

}