## Hack

### source
[Smart Contract Programmerのtutorial](https://www.youtube.com/watch?v=4Mm3BCyHtDY&list=PLO5VPQH6OWdWsCgXJT9UuzgbC8SPvTRi5)

### Reentrancy
contract A がcontract B を呼び出すとする。 Reentrancy攻撃により、A が実行を完了する前に B が A をcallbackする。

### Arithmetic Overflow and Underflow
例えばuint8の場合、整数は2^8-1の0から255までしか表現できない。256を超えると、0に戻る。
solidityのversionが0.8.0以上の場合、オーバーフローとアンダーフローは自動的に検出されるようになった。
0.8.0未満の場合は、SafeMathを使う必要がある。