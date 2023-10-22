## Hack

### source
[Smart Contract Programmerのtutorial](https://www.youtube.com/watch?v=4Mm3BCyHtDY&list=PLO5VPQH6OWdWsCgXJT9UuzgbC8SPvTRi5)

### Reentrancy
契約 A が契約 B を呼び出すとします。 再入性エクスプロイトにより、A が実行を完了する前に B が A にコールバックできるようになります。

### Arithmetic Overflow and Underflow
solidityのversionが0.8.0以上の場合、オーバーフローとアンダーフローは自動的に検出されるようになった。
0.8.0未満の場合は、SafeMathを使う必要がある。