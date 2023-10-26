## Hack

### source
[Smart Contract Programmerのtutorial](https://www.youtube.com/watch?v=4Mm3BCyHtDY&list=PLO5VPQH6OWdWsCgXJT9UuzgbC8SPvTRi5)

### Reentrancy
contract A がcontract B を呼び出すとする。 Reentrancy攻撃により、A が実行を完了する前に B が A をcallbackする。

### Arithmetic Overflow and Underflow
例えばuint8の場合、整数は2^8-1の0から255までしか表現できない。256を超えると、0に戻る。
solidityのversionが0.8.0以上の場合、オーバーフローとアンダーフローは自動的に検出されるようになった。
0.8.0未満の場合は、SafeMathを使う必要がある。

### Self Destruct

コントラクトは、selfdestruct を呼び出すことでブロックチェーンから削除できます。 selfdestruct は、コントラクトに保存されている残りの Ether をすべて指定されたアドレスに送信します。 脆弱性 悪意のあるコントラクトは、selfdestructを使用して任意のコントラクトに Ether を強制的に送信する可能性があります。但し、selfdestruct自体は非推奨で、将来的には廃止される可能性がある。

### Accessing Private Data
private修飾子などは関係なくスマートコントラクト上のすべてのデータは読み取ることができる。

### Unsafe Delegatecall
delegatecallは、他のコントラクトのコードを、現在のコントラクトのコンテキスト内で実行するために使用されます。つまり、コントラクトAがdelegatecallを使用してコントラクトBの関数を呼び出すと、その関数はコントラクトAのストレージ、バランス、および他のコンテキストで実行されます。

delegatecall を使用するときは 2 つのことに留意する必要があります 
1. delegatecall はコンテキスト (ストレージ、呼び出し元など) を保持します。
2. ストレージ レイアウトは、delegatecall を呼び出すコントラクトと呼び出されるコントラクトで同じである必要があります。

### Insecure Source of Randomness
blockhash と block.timestamp でランダム値を生成するのは危険。